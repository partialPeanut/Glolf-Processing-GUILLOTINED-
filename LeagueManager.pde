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
