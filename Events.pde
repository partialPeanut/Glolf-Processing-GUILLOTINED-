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
  EventPhase nextPhase() { return EventPhase.FIRST_PLAYER; }
  String toText() { return "Next up: Hole Number " + holeNumber + "."; }
}



class EventPlayerUp implements GlolfEvent {
  PlayState playState = new PlayState();
  Player player;

  EventPlayerUp(PlayState ps, Player p) {
    playState = ps;
    player = p;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return EventPhase.STROKE_TYPE; }
  String toText() { return "First to glolf: " + Format.playerToName(player); }
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
    else return EventPhase.HOLE_FINISH;
  }
  String toText() {
    switch(outcome.type) {
      case ACE: return "Hole in one!!";
      case SINK: return "They sink it for a " + Format.intToBird(strokesOverPar) + ".";
      case FLY:
        if (fromTerrain != toTerrain) return "The ball " + fromTerrain.leavingText + " and flies " + distance + " gallons, landing " + toTerrain.arrivingText + ".";
        else return "The ball flies " + distance + " gallons, staying " + toTerrain.arrivingText + ".";
      case WHIFF: return "They barely tap the ball!";
      case NOTHING: default: return "Nothing happens.";
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
    winners = w;
  }
  
  PlayState playState() { return playState; }
  EventPhase nextPhase() { return EventPhase.VOID; }
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
