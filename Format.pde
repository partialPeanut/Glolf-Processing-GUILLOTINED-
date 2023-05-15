static class Format {
  static final String DEFAULT = "---";
  
  static String playerToName(Player p) {
    if (p == null) return DEFAULT;
    else if (p.suffix == "") return p.firstName + " " + p.lastName;
    else return p.firstName + " " + p.lastName + " " + p.suffix;
  }

  static String intToStrokes(int strokes) {
    if (strokes < 0) return DEFAULT;
    else return "" + strokes;
  }
  static String intToScore(int score) { return "" + score; }

  static String strokeType(StrokeType st) {
    switch(st) {
      case TEE: return "tee";
      case DRIVE: return "drive";
      case CHIP: return "chip";
      case PUTT: return "putt";
      default: return "stroke";
    }
  }

  static String intToBird(int strokesOverPar) {
    if (strokesOverPar < -4) return "MegaBird";
    switch(strokesOverPar) {
      case -4: return "Condor";
      case -3: return "Albatross";
      case -2: return "Eagle";
      case -1: return "Birdie";
      case 0: return "Par";
      case 1: return "Bogey";
      case 2: return "Double Bogey";
      case 3: return "Triple Bogey";
      default: return "OverBogey";
    }
  }
}
