interface Weather {
  boolean procCheck(GlolfEvent le);
  void doEffect(GlolfEvent le);
}

// Switches the positions of two players in the lineup
class TempestWeather implements Weather {
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
    
    leagueManager.interruptWith(new EventTempestSwap(newPlayState, aBall.player, bBall.player, le.nextPhase()));
  }
}
