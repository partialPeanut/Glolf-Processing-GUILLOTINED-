class LeagueManager {
  GlolfEvent lastEvent;
  
  // Interruptions are FIFO
  ArrayList<GlolfEvent> interruptions = new ArrayList<GlolfEvent>();
  
  GlolfEvent nextEvent() {
    if (interruptions.size() > 0) {
      lastEvent = interruptions.get(0);
      interruptions.remove(0);
      
      if (lastEvent instanceof EventPlayerReplace) {
        EventPlayerReplace epr = (EventPlayerReplace)lastEvent;
        playerManager.killPlayer(epr.playerA);
        tourneyManager.replacePlayer(epr.playerA, epr.playerB);
      }
    }
    else {
      GlolfEvent le = feed.lastEvent();
      switch (le.nextPhase()) {
        default: lastEvent = tourneyManager.nextEvent();
      }
    }
    
    return lastEvent;
  }
  
  void interruptWith(GlolfEvent e) { interruptions.add(0,e); }
  
  void quantumSquid(Ball ball) {
    Player oldPlayer = ball.player;
    playerManager.erasePlayer(oldPlayer);
    Player up = playerManager.addPlayerClone(oldPlayer);
    Player down = playerManager.addPlayerClone(oldPlayer);
    
    playerManager.setSuffix(up, "UP");
    playerManager.setSuffix(down, "DOWN");
    playerManager.entanglePlayers(up, down);
    
    PlayState squidPlayState = new PlayState(feed.lastEvent().playState());
    
    for (Ball b : squidPlayState.balls) {
      if (b.player == oldPlayer) {
        b.player = up;
        Ball downBall = new Ball(ball);
        downBall.player = down;
        
        squidPlayState.balls.add(squidPlayState.balls.indexOf(b)+1, downBall);
        break;
      }
    }
    
    tourneyManager.replacePlayer(ball.player, up, down);
    
    interruptWith(new EventQuantumSquid(squidPlayState, oldPlayer, up, down, feed.lastEvent().nextPhase()));
  }
  
  void killPlayerDuringTourney() {
    Player playerToKill = tourneyManager.tourney.randomPlayer();
    Player newPlayer = playerManager.addNewPlayer();
    PlayState replacedPlayState = new PlayState(feed.lastEvent().playState());
    for (Ball b : replacedPlayState.balls) {
      if (b.player == playerToKill) {
        b.player = newPlayer;
      }
    }
    
    interruptWith(new EventPlayerReplace(replacedPlayState, playerToKill, newPlayer, feed.lastEvent().nextPhase()));
  }
}
