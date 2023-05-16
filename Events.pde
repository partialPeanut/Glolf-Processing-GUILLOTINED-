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
    String text = "It is time to topple the bourgeoisie. ";
    for (int i = 0; i < theRich.size(); i++) {
      if (i > 0) {
        text += (theRich.size() > 2 ? "," : "") + " " + (i == theRich.size()-1 ? "and " : "");
      }
      text += Format.playerToName(theRich.get(i));
    }
    text += " will face the guillotine. " + nfc(totalSins) + " $ins are redistributed to the people.";
    return text;
  }
}


class EventQuantumSquid implements GlolfEvent {
  PlayState playState = new PlayState();
  Player oldPlayer, playerUp, playerDown;
  EventPhase nextPhase;

  EventQuantumSquid(PlayState ps, Player o, Player u, Player d, EventPhase np) {
    playState = ps;
    oldPlayer = o;
    playerUp = u;
    playerDown = d;
    nextPhase = np;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return nextPhase; }
  String toText() {
    return "Waves crash. Bonds destabilize. " + Format.playerToName(oldPlayer) + " splits into their component spins.";
  }
}

class EventQuantumUnsquid implements GlolfEvent {
  PlayState playState = new PlayState();
  Player oldPlayer, restoredPlayer;
  EventPhase nextPhase;

  EventQuantumUnsquid(PlayState ps, Player o, Player r, EventPhase np) {
    playState = ps;
    oldPlayer = o;
    restoredPlayer = r;
    nextPhase = np;
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

  EventMirageSwap(PlayState ps, Player a, Player b, EventPhase np) {
    playState = ps;
    playerA = a;
    playerB = b;
    nextPhase = np;
  }
  
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

  EventTempestSwap(PlayState ps, Player a, Player b, EventPhase np) {
    playState = ps;
    playerA = a;
    playerB = b;
    nextPhase = np;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return nextPhase; }
  String toText() {
    return "Chaotic winds blow. " + Format.playerToName(playerA) + " and " + Format.playerToName(playerB) + " switch places.";
  }
}



class EventTourneyStart implements GlolfEvent {
  PlayState playState = new PlayState();
  
  EventTourneyStart(Tourney t) { playState.tourney = t; }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return EventPhase.HOLE_SETUP; }
  String toText() { return "GLOLF!! BY ANY MEANS NECESSARY."; }
}



class EventHoleSetup implements GlolfEvent {
  PlayState playState = new PlayState();
  int holeNumber;

  EventHoleSetup(PlayState ps, int hn) {
    playState = ps;
    holeNumber = hn+1;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return EventPhase.UP_TOP; }
  String toText() { return "Next up: Hole Number " + holeNumber + "."; }
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
    strokesOverPar = in.currentBall.stroke+1 - in.hole.par;
    last = end;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() {
    if (!last) return EventPhase.STROKE_TYPE;
    else return EventPhase.UP_TOP;
  }
  String toText() {
    String pre = "";
    if (strokeType == StrokeType.TEE && player.mods.contains(Mod.HARMONIZED)) {
      pre = "Worlds harmonize. The best of two outcomes is chosen. ";
    }
    switch(outcome.type) {
      case ACE: return pre + "Hole in one!!";
      case SINK: return pre + "They sink it for a " + Format.intToBird(strokesOverPar) + ".";
      case FLY:
        if (fromTerrain != toTerrain) return pre + "The ball " + fromTerrain.leavingText + " and flies " + distance + " gallons, landing " + toTerrain.arrivingText;
        else return pre + "The ball flies " + distance + " gallons, staying " + toTerrain.arrivingText;
      case WHIFF: return pre + "They barely tap the ball!";
      case NOTHING: default: return pre + "Nothing happens.";
    }
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
  boolean end;

  EventTourneyReward(PlayState ps, ArrayList<Player> w, int pl, int p, boolean e) {
    playState = ps; 
    winners = w;
    place = pl;
    prize = p;
    end = e;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() {
    if (!end) return EventPhase.TOURNEY_REWARD;
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

class EventTourneyConclude implements GlolfEvent {
  PlayState playState = new PlayState();

  EventTourneyConclude(PlayState ps) { playState = ps; }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return EventPhase.VOID; }
  String toText() { return playState.tourney.tourneyName + " has concluded."; }
}
