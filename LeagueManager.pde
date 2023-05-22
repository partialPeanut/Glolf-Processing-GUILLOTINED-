class LeagueManager {
  GlolfEvent lastEvent;
  
  // Interruptions are FIFO
  ArrayList<GlolfEvent> interruptions = new ArrayList<GlolfEvent>();
  
  GlolfEvent nextEvent() {
    if (interruptions.size() > 0) {
      lastEvent = interruptions.get(0);
      interruptions.remove(0);
      
      if (lastEvent instanceof EventAggression)         { lastEvent = doEventAggression(lastEvent); }
      else if (lastEvent instanceof EventGuillotine)    { lastEvent = doEventGuillotine(lastEvent); }
      else if (lastEvent instanceof EventPlayerReplace) { lastEvent = doEventPlayerReplace(lastEvent); }
      else if (lastEvent instanceof EventWormBattle)    { lastEvent = doEventWormBattle(lastEvent); }
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
  
  EventAggression doEventAggression(GlolfEvent le) {
    EventAggression ea = (EventAggression)le;
    PlayState lastPS = feed.lastEvent().playState();
    ea.playState = lastPS.balls == null ? new PlayState() : new PlayState(lastPS);
    ea.nextPhase = feed.lastEvent().nextPhase();
    
    Ball knockedBall = ea.playState.ballOf(ea.knockedPlayer);
    knockedBall.distance += random(1,5)*ea.knockingPlayer.yeetness;
    knockedBall.terrain = Calculation.calculatePostRollTerrain(ea.playState, knockedBall);
    
    return ea;
  }
  
  EventGuillotine doEventGuillotine(GlolfEvent le) {
    EventGuillotine eg = (EventGuillotine)le;
    PlayState lastPS = feed.lastEvent().playState();
    eg.playState = lastPS.balls == null ? new PlayState() : new PlayState(lastPS);
    eg.nextPhase = feed.lastEvent().nextPhase();
    
    ArrayList<Player> theRich = eg.theRich;
    for (Player r : theRich) { killPlayer(r, eg.playState); }
    
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
    
    return eg;
  }
  
  EventPlayerReplace doEventPlayerReplace(GlolfEvent le) {
    EventPlayerReplace epr = (EventPlayerReplace)le;
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
    
    return epr;
  }
  
  EventWormBattle doEventWormBattle(GlolfEvent le) {
    EventWormBattle wb = (EventWormBattle)le;
    PlayState lastPS = feed.lastEvent().playState();
    wb.playState = lastPS.balls == null ? new PlayState() : new PlayState(lastPS);
    wb.nextPhase = feed.lastEvent().nextPhase();
    
    float winChance = Slope.loggy(0, 1, wb.ball.player.scrappiness);
    if (random(1) < winChance) {
      wb.won = true;
      tourneyManager.holeControl.orgasm(wb.playState, wb.ball);
    }
    else {
      wb.won = false;
      wb.ball.reset(wb.playState.hole.realLength);
    }
    
    return wb;
  }
  
  void quantumSquid(Ball ball) {
    Player oldPlayer = ball.player;
    
    if (oldPlayer.mods.contains(Mod.ENTANGLED)) {
      Player bestie = playerManager.entangledWith(oldPlayer);
      playerManager.removeMod(bestie, Mod.ENTANGLED);
      playerManager.applyMod(bestie, Mod.HARMONIZED);
      playerManager.detanglePlayer(bestie);
      playerManager.removeSuffix(bestie, "UP");
      playerManager.removeSuffix(bestie, "DOWN");
      
      PlayState unsquidPlayState = erasePlayer(oldPlayer, new PlayState(feed.lastEvent().playState()));
      interruptWith(new EventQuantumUnsquid(unsquidPlayState, oldPlayer, bestie, feed.lastEvent().nextPhase()));
    }
    else {
      playerManager.erasePlayer(oldPlayer);
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
  
  PlayState removeFromPlay(Player p, PlayState ps) {
    if (tourneyManager.hasPlayer(p)) { tourneyManager.removePlayer(p); }
    if (ps.balls != null) { ps.balls.remove(ps.ballOf(p)); }
    return ps;
  }
  PlayState killPlayer(Player p, PlayState ps) {
    playerManager.killPlayer(p);
    return removeFromPlay(p, ps);
  }
  PlayState erasePlayer(Player p, PlayState ps) {
    playerManager.erasePlayer(p);
    return removeFromPlay(p, ps);
  }
  void killPlayerDuringTourney() {
    Player playerToKill = tourneyManager.tourney.randomPlayer();
    Player newPlayer = playerManager.addNewPlayer();
    
    interruptWith(new EventPlayerReplace(playerToKill, newPlayer));
  }
}
