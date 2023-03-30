// Tourney: 18 courses of stroke play, sudden death on tie
// Save backup before play
// Save on each step
// Save backup and stop after every course

class TourneyManager {
  Tourney tourney;
  int currentHole;
  HoleControl holeControl;
  GlolfEvent lastEvent;
  GlolfEvent nextEvent = null;

  IntDict currentScores = new IntDict();
  
  int end = 1;

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
        
        end = 1;
        
        lastEvent = new EventTourneyFinish(le.playState(), winners);
        holeVisualizer.setHole(null);
        break;
      case TOURNEY_REWARD:
        currentScores.sortValues();
        
        int numPlaces = 3;
        int firstScore = -100;
        int secondScore = -100;
        int thirdScore = -100;
        for (int s : currentScores.values()) {
          if (firstScore == -100) firstScore = s;
          else if (secondScore == -100 && s > firstScore) secondScore = s;
          else if (thirdScore == -100 && s > firstScore && s > secondScore) thirdScore = s;
        }
        ArrayList<Player> firstWinners = new ArrayList<Player>();
        ArrayList<Player> secondWinners = new ArrayList<Player>();
        ArrayList<Player> thirdWinners = new ArrayList<Player>();
        for (String id : currentScores.keys()) {
          if (currentScores.get(id) == firstScore) firstWinners.add(playerManager.getPlayer(id));
          else if (currentScores.get(id) == secondScore) secondWinners.add(playerManager.getPlayer(id));
          else if (currentScores.get(id) == thirdScore) thirdWinners.add(playerManager.getPlayer(id));
          else break;
        }
        if (secondWinners.size() == 0) numPlaces = 1;
        else if (thirdWinners.size() == 0) numPlaces = 2;
        lastEvent = new EventTourneyReward(le.playState(), firstWinners, 1, (tourney.prizeMoney/firstWinners.size()), end);
        end--;
        break;
      case TOURNEY_CONCLUDE:
        lastEvent = new EventTourneyConclude(le.playState());
        stopTime();
        break;
      default:
        lastEvent = holeControl.nextEvent();
        break;
    }
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
    else holeControl.undoEvent(e);
  }
  
  void replacePlayer(Player a, Player b) {
    tourney.players.remove(a);
    tourney.players.add(b);
    
    currentScores.set(b.id, currentScores.get(a.id));
    currentScores.remove(a.id);
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
