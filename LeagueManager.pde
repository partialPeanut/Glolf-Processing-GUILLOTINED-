class LeagueManager {
  GlolfEvent lastEvent;
  
  // Interruptions are FIFO
  ArrayList<GlolfEvent> interruptions = new ArrayList<GlolfEvent>();
  
  GlolfEvent nextEvent() {
    if (interruptions.size() > 0) {
      lastEvent = interruptions.get(0);
      interruptions.remove(0);
      
           if (lastEvent instanceof EventAggression)     { lastEvent = doEventAggression(lastEvent); }
      else if (lastEvent instanceof EventGuillotine)     { lastEvent = doEventGuillotine(lastEvent); }
      else if (lastEvent instanceof EventKomodoAttack)   { lastEvent = doEventKomodoAttack(lastEvent); }
      else if (lastEvent instanceof EventKomodoKill)     { lastEvent = doEventKomodoKill(lastEvent); }
      else if (lastEvent instanceof EventMirageSwap)     { lastEvent = doEventMirageSwap(lastEvent); }
      else if (lastEvent instanceof EventPlayerReplace)  { lastEvent = doEventPlayerReplace(lastEvent); }
      else if (lastEvent instanceof EventQuantumSquid)   { lastEvent = doEventQuantumSquid(lastEvent); }
      else if (lastEvent instanceof EventQuantumUnsquid) { lastEvent = doEventQuantumUnsquid(lastEvent); }
      else if (lastEvent instanceof EventTempestSwap)    { lastEvent = doEventTempestSwap(lastEvent); }
      else if (lastEvent instanceof EventWormBattle)     { lastEvent = doEventWormBattle(lastEvent); }
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
  
  PlayState removeFromPlay(Player p, PlayState ps) {
    if (tourneyManager.hasPlayer(p)) { tourneyManager.removePlayer(p); }
    if (ps.balls != null) { ps.balls.remove(ps.ballOf(p)); }
    return ps;
  }
  PlayState killPlayer(Player p, PlayState ps) {
    playerManager.killPlayer(p);
    if (tourneyManager.hasPlayer(p)) { tourneyManager.killedPlayers.add(p); }
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
