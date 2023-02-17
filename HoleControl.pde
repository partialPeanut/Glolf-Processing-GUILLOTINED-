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
  Hole hole;
  boolean justSunk = true;
  int currentBall = 0;
  StrokeType nextStrokeType;

  HoleControl(Hole h) { hole = h; }
  
  GlolfEvent nextEvent() {
    GlolfEvent lastEvent = feed.lastEvent();
    PlayState playState = lastEvent.playState();
    PlayState newPlayState;
    switch(lastEvent.nextPhase()) {
      case FIRST_PLAYER:
        justSunk = true;
        lastEvent = new EventPlayerUp(playState, playState.currentPlayer());
        return lastEvent;
        
      case STROKE_TYPE:
        if (!justSunk) currentBall++;
        if (currentBall >= playState.balls.size() || playState.balls.get(currentBall).sunk) currentBall = 0;
        justSunk = false;
        
        newPlayState = new PlayState(playState, currentBall);
        
        nextStrokeType = Calculation.calculateStrokeType(newPlayState);
        if (nextStrokeType != StrokeType.NOTHING) newPlayState.currentBall.stroke++;
        lastEvent = new EventStrokeType(newPlayState, newPlayState.currentPlayer(), nextStrokeType);
        return lastEvent;
        
      case STROKE_OUTCOME:
        StrokeOutcome so = Calculation.calculateStrokeOutcome(playState, nextStrokeType);
        
        newPlayState = new PlayState(playState);
        Ball ball = newPlayState.currentBall;
        
        switch(so.type) {
          case ACE:
          case SINK:
            orgasm(newPlayState, ball);
            break;
          case FLY:
          case WHIFF:
            if (!so.newTerrain.outOfBounds) {
              if (so.distance > ball.distance) ball.past = !ball.past;
              ball.distance = Calculation.newDistToHole(ball.distance, so.distance, so.angle);
              ball.terrain = so.newTerrain;
            }
            break;
          case NOTHING: break;
        }
        boolean last = true;
        for (Ball b : newPlayState.balls) if (!b.sunk) last = false;
        lastEvent = new EventStrokeOutcome(newPlayState, playState, so, nextStrokeType, ball.distance, last);
        return lastEvent;
        
      default:
        lastEvent = new EventVoid();
        return lastEvent;
    }
  }
  
  void undoEvent(GlolfEvent e) {
    PlayState playState = e.playState();
    if (e instanceof EventStrokeType) {
      currentBall = (currentBall+playState.balls.size()-1) % playState.balls.size();
    }
  }
  
  void orgasm(PlayState ps, Ball b) {
    b.sunk();
    b.distance = 0;
    b.terrain = Terrain.HOLE;
    ps.balls.remove(b);
    ps.balls.add(b);
    justSunk = true;
  }
}
