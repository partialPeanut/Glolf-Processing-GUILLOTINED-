class PlayState {
  Ball ball;
  Hole hole;
  Tourney tourney;
  
  PlayState(Ball b, Hole h, Tourney t) {
    ball = new Ball(b);
    hole = h;
    tourney = t;
  }

  ArrayList<Effect> getAllEffects() {
    ArrayList<Effect> effects = new ArrayList<Effect>();
    effects.addAll(ball.player.mods);
    effects.addAll(hole.mods);
    effects.addAll(tourney.mods);
    return effects;
  }

  float totalMod(FactorType ft) {
    float mod = 1;
    for (Effect e : getAllEffects()) {
      if (e instanceof ModifyEffect && e.procCheck(this)) {
        ModifyEffect me = (ModifyEffect)e;
        mod *= me.changeFactor(ft, this);
      }
    }
    return mod;
  }
}
