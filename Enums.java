enum DisplayType {
  PLAYER_STATS,
  COURSE_STATS,
  HOLE_SCORES,
  TOURNEY_SCORES
}

enum EventPhase {
  VOID,
  PLAYER_DEATH,
  PLAYER_BIRTH,
  TOURNEY_START,
  COURSE_START,
  WEATHER_REPORT,
  HOLE_SETUP,
  WILDLIFE_REPORT,
  UP_TOP,
  STROKE_TYPE,
  STROKE_OUTCOME,
  HOLE_FINISH,
  COURSE_FINISH,
  TOURNEY_FINISH,
  TOURNEY_REWARD,
  MEMORIAM,
  TOURNEY_CONCLUDE
}

enum StrokeType {
  TEE,
  DRIVE,
  APPROACH,
  CHIP,
  PUTT,
  NOTHING
}

enum StrokeOutcomeType {
  ACE,
  SINK,
  FLY,
  WHIFF,
  NOTHING
}

enum ModType {
  PLAYER_ONLY     (true,  false, false, false),
  HOLE_OR_COURSE  (false, true,  true,  false),
  TOURNEY_ONLY    (false, false, false, true);
  
  boolean playerAllowed, holeAllowed, courseAllowed, tourneyAllowed;
  ModType(boolean pa, boolean ha, boolean ca, boolean ta) {
    playerAllowed = pa;
    holeAllowed = ha;
    courseAllowed = ca;
    tourneyAllowed = ta;
  }
}

enum Mod {
  AGGRESSIVE   ("AGRO", ModType.PLAYER_ONLY,    0.20, 0.8),
  SEMI_AQUATIC ("AQUA", ModType.PLAYER_ONLY,    0.20, 0.8),
  
  ENTANGLED    ("ETNG", ModType.PLAYER_ONLY,    0.00, 1.0),
  HARMONIZED   ("HRMZ", ModType.PLAYER_ONLY,    0.00, 1.0),
  POISONED     ("PSND", ModType.PLAYER_ONLY,    0.00, 1.0),
  
  COASTAL      ("CSTL", ModType.HOLE_OR_COURSE, 0.00, 1.0),
  // Proc chance - chance to autosummon mosquitoes // Val0 - Multiplier to mosquito frequency // Val1 - Multiplier to mosquito damage
  SWAMPLAND    ("SWMP", ModType.HOLE_OR_COURSE, 0.10, 0.5, 1.5, 5.0);
  
  String brief;
  ModType modType;
  double pickChance, procChance;
  double[] vals;
  
  Mod(String b, ModType mt, double k) {
    brief = b;
    modType = mt;
    pickChance = k;
  }
  Mod(String b, ModType mt, double k, double r) {
    this(b,mt,k);
    procChance = r;
  }
  Mod(String b, ModType mt, double k, double r, double... vs) {
    this(b,mt,k,r);
    vals = vs;
  }
}

enum Terrain {
  // In order: tee, drive, approach, chip, putt
  // The ball [leaves the sand bunker] and flies X gallons, landing [in a water hazard.]
  OUT_OF_BOUNDS ("goes back in bounds",    "out of bounds.",            0xFF005000, new double[]{ 0,0,0,0,0 }, true),
  WORM_PIT      ("escapes the worm pit",   "in a sand worm's pit!",     0xFFFFC107, new double[]{ 0,0,0,0,0 }, false),
  WATER_HAZARD  ("goes back in bounds",    "in a water hazard.",        0xFF03A9F4, new double[]{ 0,0,0,0,0 }, true),
  HOLE          ("jumps out of the hole",  "in the hole.",              0xFFA0A0A0, new double[]{ 0,0,0,0,0 }, false),
  TEE           ("leaves the tee",         "perfectly on a tee.",       0xFFA0A0A0, new double[]{ 1.2, 1.0, 0.8, 0.6, 0.1 }, false),
  ROUGH         ("jumps from the rough",   "in the rough.",             0xFF007800, new double[]{ 0.0, 0.9, 0.9, 0.8, 0.6 }, false),
  GREEN         ("leaves the green",       "in the green.",             0xFF00A000, new double[]{ 0.0, 1.0, 1.0, 1.0, 1.0 }, false),
  BUNKER        ("leaves the sand bunker", "in a sand bunker.",         0xFFFFC107, new double[]{ 0.0, 0.2, 0.2, 0.6, 0.1 }, false),
  WATER_FLOAT   ("splashes away",          "safely in a water hazard.", 0xFF03A9F4, new double[]{ 0.0, 0.1, 0.1, 0.3, 0.1 }, false);

  String leavingText;
  String arrivingText;
  int tColor;
  double[] smoothness;
  boolean outOfBounds;

  Terrain(String l, String a, int c, double[] s, boolean o) {
    leavingText = l;
    arrivingText = a;
    tColor = c;
    smoothness = s;
    outOfBounds = o;
  }
}

enum Weather {
  MIRAGE  ("Mirage",  "Irrelevance and Falsehoods.", 0xFFEA6BE6, 0.04),
  TEMPEST ("Tempest", "Progression and Regression.", 0xFF1281C3, 0.04);
  
  String name;
  String report;
  int col;
  double procChance;
  
  Weather(String n, String r, int c, double pc) {
    name = n;
    report = r;
    col = c;
    procChance = pc;
  }
  
  boolean procCheck() { return clode_origin.Calculation.sRandom(0,1) < procChance; }
}

enum Wildlife {
  NONE     ("None",           "No critters on this hole.",                                            6, 1.00),
  MOSQUITO ("Mosquitoes",     "Mosquitoes in the skies! Players, hope you brought bug spray.",        1, 0.50, 0.01),
  KOMODO   ("Komodo Dragons", "Komodo dragons in the shadows. Players, keep your antibiotics handy!", 1, 0.04),
  WORM     ("Sand Worms",     "Worms in the sand! Players, be wary of those bunkers.",                2, 0.40);
  
  String name;
  String reportText;
  double pickWeight, procChance, val1;
  
  Wildlife(String n, String rt, double pw, double pc) {
    name = n;
    reportText = rt;
    pickWeight = pw;
    procChance = pc;
  }
  Wildlife(String n, String rt, double pw, double pc, double v1) {
    this(n,rt,pw,pc);
    val1 = v1;
  }
}
