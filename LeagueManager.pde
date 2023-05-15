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
    
    if (oldPlayer.mods.contains(Mod.ENTANGLED)) {
      Player bestie = playerManager.entangledWith(oldPlayer);
      playerManager.removeMod(bestie, Mod.ENTANGLED);
      playerManager.applyMod(bestie, Mod.HARMONIZED);
      playerManager.removeSuffix(bestie, "UP");
      playerManager.removeSuffix(bestie, "DOWN");
      
      PlayState unsquidPlayState = new PlayState(feed.lastEvent().playState());
      unsquidPlayState.balls.remove(unsquidPlayState.ballOf(oldPlayer));
      
      interruptWith(new EventQuantumUnsquid(unsquidPlayState, oldPlayer, bestie, feed.lastEvent().nextPhase()));
    }
    else {
      Player up = playerManager.addPlayerClone(oldPlayer);
      Player down = playerManager.addPlayerClone(oldPlayer);
      
      playerManager.appendSuffix(up, "UP");
      playerManager.appendSuffix(down, "DOWN");
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
