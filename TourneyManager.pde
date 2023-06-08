// Tourney: 18 courses of stroke play, sudden death on tie
// Save backup before play
// Save on each step
// Save backup and stop after every course

class TourneyManager {
  Tourney tourney;
  int currentCourse;
  int currentHole;
  HoleControl holeControl;
  GlolfEvent lastEvent;
  GlolfEvent nextEvent = null;
  
  ArrayList<Player> killedPlayers = new ArrayList<Player>();

  IntDict currentScores = new IntDict();
  ArrayList<ArrayList<Player>> winners = new ArrayList<ArrayList<Player>>();
  int rewardPlace = 1;

  // Generate a new tourney
  TourneyManager(Tourney t) {
    newTourney(t);
  }
  
  void newTourney(Tourney t) {
    tourney = t;
    killedPlayers.clear();
    currentScores.clear();
    for (Player p : t.players) currentScores.set(p.id, 0);
    winners.clear();
    currentCourse = 0;
    currentHole = 0;
    generateNewHole();
    
    feed.addEvent(new EventVoid());
  }
  void restartTourney() { newTourney(tourney); }
  void newRandomTourney(ArrayList<Player> ps, int courses, int hpc) { newTourney(new Tourney(ps,courses,hpc)); }
  
  // Create control for next hole
  void generateNewHole() { holeControl = new HoleControl(currentHole()); }

  GlolfEvent nextEvent() {
    GlolfEvent le = feed.lastEvent();
    switch (le.nextPhase()) {
      case VOID:
        lastEvent = new EventVoid();
        break;
        
      case TOURNEY_START:
        lastEvent = new EventTourneyStart(tourney);
        break;
        
      case COURSE_START:
        lastEvent = new EventCourseStart(le.playState(), currentCourse);
        break;
        
      case WEATHER_REPORT:
        lastEvent = new EventWeatherReport(le.playState(), currentCourse().weather);
        break;
        
      case HOLE_SETUP:
        ArrayList<Ball> balls = new ArrayList<Ball>();
        for (Player p : tourney.players) { balls.add(new Ball(p, currentHole().realLength)); }
        
        lastEvent = new EventHoleSetup(new PlayState(balls, 0, currentHole(), currentCourse(), tourneyManager.tourney), currentHole, currentHole().wildlife != Wildlife.NONE);
        holeDisplayer.setHole(currentHole());
        generateNewHole();
        break;
        
      case WILDLIFE_REPORT:
        lastEvent = new EventWildlifeReport(le.playState(), currentHole().wildlife);
        break;
        
      case HOLE_FINISH:
        playerManager.poisonCounters.clear();
        
        float totalStrokes = 0;
        for (Ball b : le.playState().balls) {
          tourneyManager.currentScores.add(b.player.id, b.stroke);
          totalStrokes += b.stroke;
        }
        float avg = totalStrokes/le.playState().balls.size();
        if (statCollection) {
          Hole hole = le.playState().hole;
          sizeAndDataPar.put(hole.realLength, avg);
          sizeAndEstimatedPar.put(hole.realLength, hole.par);
        }
        
        boolean endOfCourse = (currentHole == currentCourse().holes.size()-1);
        lastEvent = new EventHoleFinish(le.playState(), currentHole, endOfCourse);
        currentHole++;
        break;
        
      case COURSE_FINISH:
        boolean endOfTourney = (currentCourse == tourney.courses.size()-1);
        lastEvent = new EventCourseFinish(le.playState(), currentCourse, endOfTourney);
        currentCourse++;
        currentHole = 0;
        break;
        
      case TOURNEY_FINISH:
        currentScores.sortValues();
        
        IntList bestScores = new IntList(-1,-1,-1);
        for (int s : currentScores.values()) {
          if (bestScores.get(0) == -1 || bestScores.get(0) == s) bestScores.set(0,s);
          else if (bestScores.get(1) == -1 || bestScores.get(1) == s) bestScores.set(1,s);
          else if (bestScores.get(2) == -1 || bestScores.get(2) == s) bestScores.set(2,s);
          else break;
        }
        
        winners.add(new ArrayList<Player>());
        winners.add(new ArrayList<Player>());
        winners.add(new ArrayList<Player>());
        
        for (String id : currentScores.keys()) {
          if (currentScores.get(id) == bestScores.get(0)) winners.get(0).add(playerManager.getPlayer(id));
          else if (currentScores.get(id) == bestScores.get(1)) winners.get(1).add(playerManager.getPlayer(id));
          else if (currentScores.get(id) == bestScores.get(2)) winners.get(2).add(playerManager.getPlayer(id));
          else break;
        }
        
        lastEvent = new EventTourneyFinish(le.playState(), winners.get(0));
        holeDisplayer.setHole(null);
        break;
        
      case TOURNEY_REWARD:
        ArrayList<Player> batch = winners.get(rewardPlace-1);
        int batchPrize = floor(tourney.prizeMoney * pow(2,1-rewardPlace) / batch.size());
        
        for (Player p : batch) { playerManager.giveSins(p, batchPrize); }
        
        boolean end = winners.size() == rewardPlace || winners.get(rewardPlace).size() == 0;
        lastEvent = new EventTourneyReward(le.playState(), batch, rewardPlace, batchPrize, end, killedPlayers.size() > 0);
        
        if (end) rewardPlace = 1;
        else rewardPlace++;
        break;
        
      case MEMORIAM:
        lastEvent = new EventMemoriam(le.playState(), killedPlayers);
        break;
        
      case TOURNEY_CONCLUDE:
        lastEvent = new EventTourneyConclude(le.playState());
        stopTime();
        break;
        
      default:
        lastEvent = holeControl.nextEvent();
        if (currentCourse().weather.procCheck()) {
          GlolfEvent weatherEvent = null;
          switch (currentCourse().weather) {
            case MIRAGE:  weatherEvent = new EventMirageSwap(); break;
            case TEMPEST: weatherEvent = new EventTempestSwap(); break;
            default: break;
          }
          if (weatherEvent != null) leagueManager.interruptWith(weatherEvent);
        }
        break;
    }
    
    return lastEvent;
  }
  
  void undoEvent(GlolfEvent e) {
    if (e instanceof EventTourneyStart) {}
    else if (e instanceof EventHoleSetup) {
      currentHole = max(currentHole-1, 0);
      holeDisplayer.setHole(feed.lastLastEvent().playState().hole);
      holeControl = new HoleControl(feed.lastLastEvent().playState().hole);
    }
    else if (e instanceof EventHoleFinish) { currentHole--; }
    else if (e instanceof EventCourseFinish) {
      currentCourse--;
      currentHole = currentCourse().holes.size()-1;
    }
    else holeControl.undoEvent(e);
  }
  
  boolean hasPlayer(Player p) { return currentScores.hasKey(p.id); }
  void addPlayer(Player p, int score) {
    tourney.players.add(p);
    currentScores.set(p.id, score);
  }
  void replacePlayer(Player a, Player b) {
    addPlayer(b, currentScores.get(a.id));
    removePlayer(a);
  }
  void replacePlayer(Player o, Player a, Player b) {
    addPlayer(a, currentScores.get(o.id));
    addPlayer(b, currentScores.get(o.id));
    removePlayer(o);
  }
  void removePlayer(Player p) {
    tourney.players.remove(p);
    currentScores.remove(p.id);
  }
  
  Course currentCourse() { return tourney.courses.get(currentCourse); }
  Hole currentHole() { return currentCourse().holes.get(currentHole); }
  
  Player currentPlayer() { return feed.lastEvent().playState().currentPlayer(); }
  int currentScoreOf(Player player) { return currentScores.get(player.id); }
  int currentStrokeOf(Player player) { return feed.lastEvent().playState().currentStrokeOf(player); }

  IntDict playersByScores() {
    currentScores.sortValues();
    return currentScores;
  }
}
