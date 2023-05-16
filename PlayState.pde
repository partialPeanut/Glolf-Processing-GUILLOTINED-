class PlayState {
  ArrayList<Ball> balls = null;
  Ball currentBall = null;
  Hole hole = null;
  Tourney tourney = null;
  
  PlayState() {}
  PlayState(ArrayList<Ball> bs, int cbi, Hole h, Tourney t) {
    balls = new ArrayList<Ball>();
    for (Ball b : bs) balls.add(new Ball(b));
    
    if (cbi >= 0) currentBall = balls.get(cbi);
    else currentBall = balls.get(0);
    hole = h;
    tourney = t;
  }
  PlayState(PlayState ps) { this(ps.balls, ps.balls.indexOf(ps.currentBall), ps.hole, ps.tourney); }
  PlayState(PlayState ps, int cbi) { this(ps.balls, cbi, ps.hole, ps.tourney); }
  
  Player currentPlayer() {
    if (currentBall == null) return null;
    else return currentBall.player;
  }
  
  Ball ballOf(Player player) {
    if (balls == null) return null;
    for (Ball b : balls) if (b.player == player) return b;
    return null;
  }
  int currentStrokeOf(Player player) {
    if (balls == null) return -1;
    for (Ball b : balls) if (b.player == player) return b.stroke;
    return -1;
  }
  
  IntDict playersAndStrokes() {
    if (balls == null) return null;
    IntDict pas = new IntDict();
    for (Ball b : balls) {
      if (b.sunk) pas.set(b.player.id, -b.stroke);
      else pas.set(b.player.id, b.stroke);
    }
    return pas;
  }

  ArrayList<Mod> getAllEffects() {
    ArrayList<Mod> effects = new ArrayList<Mod>();
    if (currentPlayer() != null) effects.addAll(currentPlayer().mods);
    if (hole != null) effects.addAll(hole.mods);
    if (tourney != null) effects.addAll(tourney.mods);
    return effects;
  }
  
  ArrayList<Ball> activeBalls() {
    ArrayList<Ball> activeBalls = new ArrayList<Ball>();
    for (Ball b : balls) {
      if (!b.sunk) activeBalls.add(b);
    }
    return activeBalls;
  }
  Ball randomActiveBall() {
    ArrayList<Ball> activeBalls = activeBalls();
    
    if (activeBalls.size() == 0) return null;
    else return activeBalls.get(int(random(activeBalls.size())));
  }
}
