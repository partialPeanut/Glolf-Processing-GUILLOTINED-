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
        PlayState lastPS = feed.lastEvent().playState();
        epr.playState = lastPS.balls == null ? new PlayState() : new PlayState(lastPS);
        epr.nextPhase = feed.lastEvent().nextPhase();
        
        playerManager.killPlayer(epr.playerA);
        tourneyManager.replacePlayer(epr.playerA, epr.playerB);
        for (Ball b : epr.playState.balls) {
          if (b.player == epr.playerA) {
            b.player = epr.playerB;
          }
        }
        
        lastEvent = epr;
      }
      
      else if (lastEvent instanceof EventGuillotine) {
        EventGuillotine eg = (EventGuillotine)lastEvent;
        PlayState lastPS = feed.lastEvent().playState();
        eg.playState = lastPS.balls == null ? new PlayState() : new PlayState(lastPS);
        eg.nextPhase = feed.lastEvent().nextPhase();
        
        ArrayList<Player> theRich = eg.theRich;
        for (Player r : theRich) {
          playerManager.killPlayer(r);
          if (tourneyManager.hasPlayer(r)) {
            tourneyManager.removePlayer(r);
            eg.playState.balls.remove(eg.playState.ballOf(r));
          }
        }
        
        int sinsEach = floor(eg.totalSins / playerManager.livePlayers.size());
        for (Player p : playerManager.livePlayers) {
          playerManager.giveSins(p, sinsEach);
        }
        
        if (playerManager.hasRich()) {
          ArrayList<Player> newRich = playerManager.bourgeoisie();
          int ts = 0;
          for (Player r : newRich) { ts += r.networth; }
          interruptWith(new EventGuillotine(newRich, ts));
        }
        
        lastEvent = eg;
      }
    }
    else {
      GlolfEvent le = feed.lastEvent();
      switch (le.nextPhase()) {
        default: lastEvent = tourneyManager.nextEvent();
      }
      
      if (playerManager.hasRich()) {
        ArrayList<Player> theRich = playerManager.bourgeoisie();
        int ts = 0;
        for (Player r : theRich) { ts += r.networth; }
        interruptWith(new EventGuillotine(theRich, ts));
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
      playerManager.detanglePlayer(bestie);
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
    
    interruptWith(new EventPlayerReplace(playerToKill, newPlayer));
  }
}
