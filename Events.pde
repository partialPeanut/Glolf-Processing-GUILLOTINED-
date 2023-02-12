// Events always describe things that have *just been done*. For example, the next player event being shown means that the next player has just been called up.
interface GlolfEvent {
  static final String defaultEventText = "---";

  EventPhase nextPhase();
  String toText();
}



class EventVoid implements GlolfEvent {
  EventPhase nextPhase() { return EventPhase.TOURNEY_START; }
  String toText() { return defaultEventText; }
}



class EventTourneyStart implements GlolfEvent {
  EventPhase nextPhase() { return EventPhase.HOLE_SETUP; }
  String toText() { return "Play ball!!"; }
}



class EventHoleSetup implements GlolfEvent {
  int holeNumber;
  Hole hole;

  EventHoleSetup(int hn, Hole h) {
    holeNumber = hn;
    hole = h;
  }

  EventPhase nextPhase() { return EventPhase.STROKE_TYPE; }
  String toText() { return "Next up: Hole number " + holeNumber + "."; }
}



class EventStrokeType implements GlolfEvent {
  Player player;
  StrokeType type;

  EventStrokeType(Player p, StrokeType st) {
    player = p;
    type = st;
  }

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
  Player player;
  StrokeOutcome outcome;
  Terrain fromTerrain;
  Terrain toTerrain;
  float distance;
  int strokesOverPar;
  boolean last;

  EventStrokeOutcome(PlayState in, StrokeOutcome out) {
    player = in.ball.player;
    outcome = out;
    fromTerrain = in.ball.terrain;
    toTerrain = out.newTerrain;
    distance = out.distance;
    strokesOverPar = in.ball.stroke+1 - in.hole.par;
    last = false;
  }
  EventStrokeOutcome(PlayState in, StrokeOutcome out, boolean end) {
    this(in, out);
    last = end;
  }

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
  int holeNumber;
  Hole hole;
  boolean last;

  EventHoleFinish(int hn, Hole h) {
    holeNumber = hn;
    hole = h;
    last = false;
  }
  EventHoleFinish(int hn, Hole h, boolean end) {
    this(hn, h);
    last = end;
  }

  EventPhase nextPhase() {
    if (!last) return EventPhase.HOLE_SETUP;
    else return EventPhase.TOURNEY_FINISH;
  }
  String toText() { return "That was hole number " + holeNumber + "."; }
}



class EventTourneyFinish implements GlolfEvent {
  ArrayList<Player> winners;

  EventTourneyFinish(ArrayList<Player> w) {
    winners = w;
  }

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
