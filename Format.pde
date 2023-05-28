static class Format {
  static final String DEFAULT = "---";
  
  static String upperFirst(String s) {
    return s.substring(0,1).toUpperCase() + s.substring(1);
  }
  
  static String playerToName(Player p) {
    if (p == null) return DEFAULT;
    else if (p.suffixes.size() == 0) return p.firstName + " " + p.lastName;
    else return p.firstName + " " + p.lastName + " " + p.suffixes.join(" ");
  }
  
  static String modsToBrief(ArrayList<Mod> mods) {
    if (mods.size() == 0) return "None";
    else {
      String text = "";
      boolean first = true;
      for (Mod m : mods) {
        if (!first) text += ", ";
        else first = false;
        text += m.brief;
      }
      return text;
    }
  }

  static String intToStrokes(int strokes) {
    if (strokes < 0) return DEFAULT;
    else return "" + strokes;
  }
  static String intToScore(int score) { return "" + score; }
  static String intToName(int num) {
    switch(num) {
      case 0: return "zero";
      case 1: return "one";
      case 2: return "two";
      case 3: return "three";
      case 4: return "four";
      case 5: return "five";
      case 6: return "six";
      case 7: return "seven";
      case 8: return "eight";
      case 9: return "nine";
      case 10: return "ten";
      default: return "a lot of";
    }
  }

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
    if (strokesOverPar < -5) return "MegaBird";
    switch(strokesOverPar) {
      case -5: return "Peregrine";
      case -4: return "Condor";
      case -3: return "Albatross";
      case -2: return "Eagle";
      case -1: return "Birdie";
      case 0: return "Par";
      case 1: return "Bogey";
      case 2: return "Double Bogey";
      case 3: return "Triple Bogey";
      case 4: return "OverBogey";
      case 5: return "SuperBogey";
      case 6: return "HyperBogey";
      case 7: return "UltraBogey";
      case 8: return "KiloBogey";
      case 9: return "MegaBogey";
      case 10: return "GigaBogey";
      case 11: return "TeraBogey";
      case 12: return "PetaBogey";
      case 13: return "ExaBogey";
      case 14: return "ZettaBogey";
      case 15: return "YottaBogey";
      case 16: return "FinalBogey";
      default: return "BeyondBogey";
    }
  }
}
