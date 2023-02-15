// Tourney: 18 courses of stroke play, sudden death on tie
// Save backup before play
// Save on each step
// Save backup and stop after every course

class TourneyManager {
  Tourney tourney;
  int currentHole;
  HoleControl holeControl;
  GlolfEvent lastEvent;

  IntDict currentScores = new IntDict();

  // Generate a new tourney
  TourneyManager(Tourney t) {
    newTourney(t);
  }
  
  void newTourney(Tourney t) {
    tourney = t;
    for (Player p : t.players) currentScores.set(p.id, 0);
    currentHole = 0;
    generateNewHole();
    
    feed.addEvent(new EventVoid());
    resumeTime();
  }
  void restartTourney() { newTourney(tourney); }
  void newRandomTourney(ArrayList<Player> ps, int holes) { newTourney(new Tourney(ps,holes)); }
  
  // Create control for next hole
  void generateNewHole() {
    holeControl = new HoleControl(currentHole());
  }

  GlolfEvent nextEvent() {
    GlolfEvent le = feed.lastEvent();
    switch (le.nextPhase()) {
      case VOID:
        lastEvent = new EventVoid();
        break;
      case TOURNEY_START:
        lastEvent = new EventTourneyStart(tourney);
        break;
      case HOLE_SETUP:
        ArrayList<Ball> balls = new ArrayList<Ball>();
        for (Player p : tourney.players) { balls.add(new Ball(p, currentHole().realLength)); }
        
        lastEvent = new EventHoleSetup(new PlayState(balls, 0, currentHole(), tourneyManager.tourney), currentHole);
        holeVisualizer.setHole(tourney.holes.get(currentHole));
        generateNewHole();
        break;
      case HOLE_FINISH:
        for (Ball b : le.playState().balls) {
          tourneyManager.currentScores.add(b.player.id, b.stroke);
        }
        boolean last = (currentHole == tourney.holes.size()-1);
        lastEvent = new EventHoleFinish(le.playState(), currentHole, last);
        currentHole++;
        break;
      case TOURNEY_FINISH:
        currentScores.sortValues();
        
        int bestScore = 0;
        for (int s : currentScores.values()) {
          bestScore = s;
          break;
        }
        
        ArrayList<Player> winners = new ArrayList<Player>();
        for (String id : currentScores.keys()) {
          if (currentScores.get(id) != bestScore) break;
          else winners.add(playerManager.getPlayer(id));
        }
        lastEvent = new EventTourneyFinish(le.playState(), winners);
        holeVisualizer.setHole(null);
        stopTime();
        break;
      default:
        lastEvent = holeControl.nextEvent();
        break;
    }
    feed.addEvent(lastEvent);
    println(lastEvent.toText());
    return lastEvent;
  }
  
  void undoEvent(GlolfEvent e) {
    if (e instanceof EventTourneyStart) {}
    else if (e instanceof EventHoleSetup) {
      currentHole = max(currentHole-1, 0);
      holeVisualizer.setHole(feed.lastLastEvent().playState().hole);
      holeControl = new HoleControl(feed.lastLastEvent().playState().hole);
    }
    else if (e instanceof EventHoleFinish) {}
  }
  
  Hole currentHole() { return tourney.holes.get(currentHole); }
  
  Player currentPlayer() { return feed.lastEvent().playState().currentPlayer(); }
  int currentScoreOf(Player player) { return currentScores.get(player.id); }
  int currentStrokeOf(Player player) { return feed.lastEvent().playState().currentStrokeOf(player); }

  IntDict playersByScores() {
    currentScores.sortValues();
    return currentScores;
  }
}
