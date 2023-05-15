interface Weather {
  String name();
  boolean procCheck(GlolfEvent le);
  void doEffect(GlolfEvent le);
}

// Switches the positions of two players in the lineup
class WeatherMirage implements Weather {
  String name() { return "Mirage"; }
  static final color col = #EA6BE6;
  
  float chance = 0.1;
  boolean procCheck(GlolfEvent le) { return random(0,1) < chance; }
  
  void doEffect(GlolfEvent le) {
    PlayState newPlayState = new PlayState(le.playState());
    
    Ball aBall = newPlayState.randomActiveBall();
    Ball bBall = newPlayState.randomActiveBall();
    
    if (aBall == null || bBall == null) return;
    
    int aIndex = newPlayState.balls.indexOf(aBall);
    int bIndex = newPlayState.balls.indexOf(bBall);
    
    newPlayState.balls.set(aIndex, bBall);
    newPlayState.balls.set(bIndex, aBall);
    
    leagueManager.interruptWith(new EventMirageSwap(newPlayState, aBall.player, bBall.player, le.nextPhase()));
  }
}

// Switches the positions of two players on the course
class WeatherTempest implements Weather {
  String name() { return "Tempest"; }
  static final color col = #1281C3;
  
  float chance = 0.1;
  boolean procCheck(GlolfEvent le) { return random(0,1) < chance; }
  
  void doEffect(GlolfEvent le) {
    PlayState newPlayState = new PlayState(le.playState());
    
    Ball aBall = newPlayState.randomActiveBall();
    Ball bBall = newPlayState.randomActiveBall();
    
    if (aBall == null || bBall == null || (aBall.terrain == Terrain.TEE && bBall.terrain == Terrain.TEE)) return;
    
    Ball aBallCopy = new Ball(aBall);
    aBall.teleportTo(bBall);
    bBall.teleportTo(aBallCopy);
    
    if (aBall == bBall) { leagueManager.quantumSquid(aBall); }
    
    leagueManager.interruptWith(new EventTempestSwap(newPlayState, aBall.player, bBall.player, le.nextPhase()));
  }
}
