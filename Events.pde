// Events always describe things that have *just been done*. For example, the next player event being shown means that the next player has just been called up.
interface GlolfEvent {
  static final String defaultEventText = "---";
  
  PlayState playState();
  EventPhase nextPhase();
  String toText();
}



class EventVoid implements GlolfEvent {
  PlayState playState() { return new PlayState(); }
  EventPhase nextPhase() { return EventPhase.TOURNEY_START; }
  String toText() { return defaultEventText; }
}


class EventNoEvent implements GlolfEvent {
  PlayState playState() { return new PlayState(); }
  EventPhase nextPhase() { return EventPhase.TOURNEY_START; }
  String toText() { return "WARPED CONDITIONS COLLIDE. PLAY MUST STOP. NO EVENT POSSIBLE."; }
}


class EventPlayerReplace implements GlolfEvent {
  PlayState playState;
  Player playerA, playerB;
  EventPhase nextPhase;

  EventPlayerReplace(Player a, Player b) {
    playerA = a;
    playerB = b;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return nextPhase; }
  String toText() {
    return "Contract Terminated. " + Format.playerToName(playerA) + " rots. " + Format.playerToName(playerB) + " emerges from the ground to take their place.";
  }
}


class EventGuillotine implements GlolfEvent {
  PlayState playState = new PlayState();
  ArrayList<Player> theRich;
  int totalSins;
  EventPhase nextPhase;

  EventGuillotine(ArrayList<Player> r, int ts) {
    theRich = r;
    totalSins = ts;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return nextPhase; }
  String toText() {
    String text = "It is time to topple the bourgeoisie. The League has been weighed down by their sins. ";
    for (int i = 0; i < theRich.size(); i++) {
      if (i > 0) {
        text += (theRich.size() > 2 ? "," : "") + " " + (i == theRich.size()-1 ? "and " : "");
      }
      text += Format.playerToName(theRich.get(i));
    }
    text += " will face the guillotine.";
    return text;
  }
}


class EventQuantumSquid implements GlolfEvent {
  PlayState playState = new PlayState();
  Ball oldBall;
  Player playerUp, playerDown;
  EventPhase nextPhase;

  EventQuantumSquid(Ball ob) {
    oldBall = ob;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return nextPhase; }
  String toText() {
    return "Waves crash. Bonds destabilize. " + Format.playerToName(oldBall.player) + " splits into their component spins.";
  }
}

class EventQuantumUnsquid implements GlolfEvent {
  PlayState playState = new PlayState();
  Player oldPlayer, restoredPlayer;
  EventPhase nextPhase;

  EventQuantumUnsquid(Player o) {
    oldPlayer = o;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return nextPhase; }
  String toText() {
    return "Up and down collapse. Waves align. " + Format.playerToName(restoredPlayer) + " harmonizes.";
  }
}



class EventMirageSwap implements GlolfEvent {
  PlayState playState = new PlayState();
  Player playerA, playerB;
  EventPhase nextPhase;
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return nextPhase; }
  String toText() {
    if (playerA != playerB) return "Illusions dance. " + Format.playerToName(playerA) + " and " + Format.playerToName(playerB) + " confuse their turns.";
    else return "Illusions dance. " + Format.playerToName(playerA) + " gets confused.";
  }
}



class EventTempestSwap implements GlolfEvent {
  PlayState playState = new PlayState();
  Player playerA, playerB;
  EventPhase nextPhase;
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return nextPhase; }
  String toText() {
    return "Chaotic winds blow. " + Format.playerToName(playerA) + " and " + Format.playerToName(playerB) + " switch places.";
  }
}



class EventTourneyStart implements GlolfEvent {
  PlayState playState = new PlayState();
  Tourney tourney;
  
  EventTourneyStart(Tourney t) {
    playState.tourney = t;
    tourney = t;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return EventPhase.WEATHER_REPORT; }
  String toText() {
    return "Wlecome to " + tourney.tourneyName + "!\n" +
           tourney.players.size() + " players, " + tourney.holes.size() + " holes, and " + nfc(tourney.prizeMoney) + " $ins up for grabs!" +
           "\nGLOLF!! BY ANY MEANS NECESSARY.";
  }
}

class EventWeatherReport implements GlolfEvent {
  PlayState playState = new PlayState();
  Weather weather;
  
  EventWeatherReport(PlayState ps, Weather w) {
    playState = ps;
    weather = w;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return EventPhase.HOLE_SETUP; }
  String toText() { return "This tournament's forecast predicts: " + weather.report + "."; }
}



class EventHoleSetup implements GlolfEvent {
  PlayState playState = new PlayState();
  int holeNumber;

  EventHoleSetup(PlayState ps, int hn) {
    playState = ps;
    holeNumber = hn+1;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return EventPhase.WILDLIFE_REPORT; }
  String toText() { return "Next up: Hole Number " + holeNumber + "."; }
}



class EventWildlifeReport implements GlolfEvent {
  PlayState playState = new PlayState();
  Wildlife wildlife;

  EventWildlifeReport(PlayState ps, Wildlife wl) {
    playState = ps;
    wildlife = wl;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return EventPhase.UP_TOP; }
  String toText() { return "Wildlife Report: " + wildlife.reportText; }
}



class EventUpTop implements GlolfEvent {
  PlayState playState = new PlayState();
  boolean holeOver;

  EventUpTop(PlayState ps, boolean end) {
    playState = ps;
    holeOver = end;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() {
    if (!holeOver) return EventPhase.STROKE_TYPE;
    else return EventPhase.HOLE_FINISH;
  }
  String toText() {
    if (!holeOver) return "The cycle begins anew.";
    else return "The cycle ends, for now.";
  }
}



class EventStrokeType implements GlolfEvent {
  PlayState playState = new PlayState();
  Player player;
  StrokeType type;

  EventStrokeType(PlayState ps, Player p, StrokeType st) {
    playState = ps;
    player = p;
    type = st;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return EventPhase.STROKE_OUTCOME; }
  String toText() {
    switch(type) {
      case TEE: return Format.playerToName(player) + " tees off.";
      case DRIVE: return Format.playerToName(player) + " goes for a drive.";
      case APPROACH: return Format.playerToName(player) + " approaches...";
      case CHIP: return Format.playerToName(player) + " gears up for a chip.";
      case PUTT: return Format.playerToName(player) + " lines up for a putt.";
      case NOTHING: return Format.playerToName(player) + " does nothing.";
      default: return Format.playerToName(player) + " does nothing.";
    }
  }
}



class EventStrokeOutcome implements GlolfEvent {
  PlayState playState = new PlayState();
  Player player;
  Ball lastBall;
  StrokeType strokeType;
  StrokeOutcome outcome;
  Terrain fromTerrain;
  Terrain toTerrain;
  float distance;
  float fromDistance;
  float toDistance;
  int strokesOverPar;
  boolean last;

  EventStrokeOutcome(PlayState ps, PlayState in, StrokeOutcome out, StrokeType st, float td, boolean end) {
    playState = ps;
    player = in.currentBall.player;
    lastBall = in.currentBall;
    strokeType = st;
    outcome = out;
    fromTerrain = in.currentBall.terrain;
    toTerrain = out.newTerrain;
    distance = out.distance;
    fromDistance = in.currentBall.distance;
    toDistance = td;
    strokesOverPar = in.currentBall.stroke - in.hole.par;
    last = end;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() {
    if (!last) return EventPhase.STROKE_TYPE;
    else return EventPhase.UP_TOP;
  }
  String toText() {
    String text = "";
    if (strokeType == StrokeType.TEE && player.mods.contains(Mod.HARMONIZED)) {
      text = "Worlds harmonize. The best of two outcomes is chosen. ";
    }
    switch(outcome.type) {
      case ACE: text += "Hole in one!!"; break;
      case SINK: text += "They sink it for a " + Format.intToBird(strokesOverPar) + "."; break;
      case FLY:
        if (fromTerrain != toTerrain) text += "The ball " + fromTerrain.leavingText + " and flies " + distance + " gallons, landing " + toTerrain.arrivingText;
        else text += "The ball flies " + distance + " gallons, staying " + toTerrain.arrivingText;
        break;
      case WHIFF: text += "They barely tap the ball!"; break;
      case NOTHING: default: text += "Nothing happens."; break;
    }
    if (playerManager.poisonCounters.hasKey(player.id)) {
      int turnsTilDeath = playerManager.poisonCounters.get(player.id) + 1;
      switch(outcome.type) {
        case ACE:
        case SINK:
          text += " The prey escapes, and is cured of poison.";
          break;
        case FLY:
        case WHIFF:
        case NOTHING:
        default:
          if (turnsTilDeath == 0) text += " Lizards hiss.";
          else text += " " + Format.upperFirst(Format.intToName(turnsTilDeath)) + " stroke" + (turnsTilDeath == 1 ? "" : "s") + " until the predators strike.";
          break;
      }
    }
    return text;
  }
}


class EventKomodoAttack implements GlolfEvent {
  PlayState playState = new PlayState();
  Player player;
  EventPhase nextPhase;

  EventKomodoAttack(Player p) {
    player = p;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return nextPhase; }
  String toText() {
    return Format.playerToName(player) + " is attacked my komodo dragons and is poisoned!";
  }
}


class EventKomodoKill implements GlolfEvent {
  PlayState playState = new PlayState();
  Player player;
  EventPhase nextPhase;

  EventKomodoKill(Player p) {
    player = p;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return nextPhase; }
  String toText() {
    return "Too slow. The komodos feast on " + Format.playerToName(player) + ".";
  }
}


class EventWormBattle implements GlolfEvent {
  PlayState playState = new PlayState();
  Ball ball;
  boolean won;
  EventPhase nextPhase;

  EventWormBattle(Ball b) {
    ball = b;
    won = false;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return nextPhase; }
  String toText() {
    if (won) return Format.playerToName(ball.player) + " scrappily knocks the worm unconscious! With the worm gone, the ball rolls into the wormhole for a " + (ball.stroke == 1 ? "hole in one!" : Format.intToBird(ball.stroke - playState.hole.par)) + "!";
    else return Format.playerToName(ball.player) + "'s ball is eaten by the worm! They'll have to start at the beginning.";
  }
}


class EventAggression implements GlolfEvent {
  PlayState playState = new PlayState();
  Player knockingPlayer, knockedPlayer;
  EventPhase nextPhase;

  EventAggression(Player ram, Player rammed) {
    knockingPlayer = ram;
    knockedPlayer = rammed;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return nextPhase; }
  String toText() {
    return Format.playerToName(knockingPlayer) + " gets aggressive! " + Format.playerToName(knockedPlayer) + "'s ball is knocked away from the hole!";
  }
}


class EventHoleFinish implements GlolfEvent {
  PlayState playState = new PlayState();
  int holeNumber;
  Hole hole;
  boolean last;

  EventHoleFinish(PlayState ps, int hn, boolean end) {
    playState = ps;
    holeNumber = hn+1;
    last = end;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() {
    if (!last) return EventPhase.HOLE_SETUP;
    else return EventPhase.TOURNEY_FINISH;
  }
  String toText() { return "That was Hole Number " + holeNumber + "."; }
}



class EventTourneyFinish implements GlolfEvent {
  PlayState playState = new PlayState();
  ArrayList<Player> winners;

  EventTourneyFinish(PlayState ps, ArrayList<Player> w) {
    playState = ps; 
    winners = w;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return EventPhase.TOURNEY_REWARD; }
  String toText() {
    String text = "The tournament is over!! Congratulations to the winner" + (winners.size() > 1 ? "s" : "") + ": ";
    for (int i = 0; i < winners.size(); i++) {
      if (i > 0) {
        text += (winners.size() > 2 ? "," : "") + " " + (i == winners.size()-1 ? "and " : "");
      }
      text += Format.playerToName(winners.get(i));
    }
    text += "!!";
    return text;
  }
}

class EventTourneyReward implements GlolfEvent {
  PlayState playState = new PlayState();
  ArrayList<Player> winners;
  int place;
  int prize;
  boolean end, memoriam;

  EventTourneyReward(PlayState ps, ArrayList<Player> w, int pl, int p, boolean e, boolean m) {
    playState = ps; 
    winners = w;
    place = pl;
    prize = p;
    end = e;
    memoriam = m;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() {
    if (!end) return EventPhase.TOURNEY_REWARD;
    else if (memoriam) return EventPhase.MEMORIAM;
    else return EventPhase.TOURNEY_CONCLUDE;
  }
  String toText() {
    String text = "The " + getPlace() + " place ";
    if (winners.size() > 1) text += "winners receive " + nfc(prize) + " $ins each: ";
    else text += "winner receives " + nfc(prize) + " $ins: ";
    
    for (int i = 0; i < winners.size(); i++) {
      if (i > 0) text += (winners.size() > 2 ? "," : "") + " " + (i == winners.size()-1 ? "and " : "");
      text += Format.playerToName(winners.get(i));
    }
    text += ".";
    return text;
  }
  String getPlace() {
      switch (place) {
        case 1: return "1st";
        case 2: return "2nd";
        case 3: return "3rd";
        default: return "Nth";
      }
  }
}

class EventMemoriam implements GlolfEvent {
  PlayState playState = new PlayState();
  ArrayList<Player> theDead;

  EventMemoriam(PlayState ps, ArrayList<Player> d) {
    playState = ps;
    theDead = new ArrayList<Player>(d);
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return EventPhase.TOURNEY_CONCLUDE; }
  String toText() {
    String text = "We dedicate this tournament to those lost to Death's clutches: ";
    for (int i = 0; i < theDead.size(); i++) {
      if (i > 0) {
        text += (theDead.size() > 2 ? "," : "") + " " + (i == theDead.size()-1 ? "and " : "");
      }
      text += Format.playerToName(theDead.get(i));
    }
    text += ". May they ace forever in the All Holes Halls.";
    return text;
  }
}

class EventTourneyConclude implements GlolfEvent {
  PlayState playState = new PlayState();

  EventTourneyConclude(PlayState ps) { playState = ps; }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return EventPhase.VOID; }
  String toText() { return playState.tourney.tourneyName + " has concluded."; }
}
