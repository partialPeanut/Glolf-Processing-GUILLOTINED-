// Runs singular holes
// a. Pick an order the players go in
// 1. Introductory message when hole starts
// 2. The players do a round of glolfin
//   i.   On tee, check for ace
//   ii.  Decide the type of hit
//   iii. Do a hit (of weed)
//   iv.  Do a hit (of glolf)
//   v.   The ball go somewhere
// 3. Players that have orgasmed are removed from the order
// 4. Repeat rounds until everyone has came

class HoleControl {
  int currentBall;
  ArrayList<Ball> balls;
  ArrayList<Ball> activeBalls;
  Hole hole;
  PlayState playState;
  StrokeType nextStrokeType;

  HoleControl(ArrayList<Player> ps, Hole h, GlolfEvent le) {
    balls = new ArrayList<Ball>();
    for (Player p : ps) {
      balls.add(new Ball(p, h.realLength));
    }
    activeBalls = new ArrayList<Ball>(balls);
    hole = h;
    currentBall = 0;
  }
  
  GlolfEvent nextEvent() {
    GlolfEvent lastEvent = feed.lastEvent();
    switch(lastEvent.nextPhase()) {
      case FIRST_PLAYER:
        playState = new PlayState(currentBall(), hole, tourney);
        holeVisualizer.setPlayState(playState);
        lastEvent = new EventPlayerUp(currentPlayer());
        return lastEvent;
        
      case NEXT_PLAYER:
        currentBall = (currentBall+1) % activeBalls.size();
        if (currentBall == 0) {
          startRound();
        }
        playState = new PlayState(currentBall(), hole, tourney);
        holeVisualizer.setPlayState(playState);
        lastEvent = new EventPlayerUp(currentPlayer());
        return lastEvent;
        
      case STROKE_TYPE:
        nextStrokeType = Calculation.calculateStrokeType(playState);
        if (nextStrokeType != StrokeType.NOTHING) currentBall().stroke++;
        lastEvent = new EventStrokeType(currentPlayer(), nextStrokeType);
        return lastEvent;
        
      case STROKE_OUTCOME:
        StrokeOutcome so = Calculation.calculateStrokeOutcome(playState, nextStrokeType);
        switch(so.type) {
          case ACE:
          case SINK:
            orgasm(currentBall());
            break;
          case FLY:
          case WHIFF:
            if (!so.newTerrain.outOfBounds) {
              currentBall().distance = Calculation.newDistToHole(currentBall().distance, so.distance, so.angle);
              currentBall().terrain = so.newTerrain;
            }
            break;
          case NOTHING: break;
        }
        boolean last = true;
        for (Ball b : activeBalls) if (!b.sunk) last = false;
        lastEvent = new EventStrokeOutcome(playState, so, last);
        playState = new PlayState(currentBall(), hole, tourney);
        holeVisualizer.setPlayState(playState);
        return lastEvent;
        
      default:
        lastEvent = new EventVoid();
        return lastEvent;
    }
  }
  
  void startRound() {
    activeBalls.removeIf(b -> (b.sunk));
  }
  
  void orgasm(Ball b) {
    b.sunk();
    b.distance = 0;
    b.terrain = Terrain.HOLE;
    balls.remove(b);
    balls.add(b);
  }
  
  Ball currentBall() { return activeBalls.get(currentBall); }
  Player currentPlayer() { return activeBalls.get(currentBall).player; }

  int currentStrokeOf(Player player) {
    for (Ball b : balls) {
      if (b.player == player) return b.stroke;
    }
    return -1;
  }

  IntDict playersAndStrokes() {
    IntDict pas = new IntDict();
    for (Ball b : balls) {
      if (b.sunk) pas.set(b.player.id, -b.stroke);
      else pas.set(b.player.id, b.stroke);
    }
    return pas;
  }
}
