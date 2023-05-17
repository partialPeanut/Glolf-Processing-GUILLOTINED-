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
  HOLE_SETUP,
  UP_TOP,
  STROKE_TYPE,
  STROKE_OUTCOME,
  HOLE_FINISH,
  TOURNEY_FINISH,
  TOURNEY_REWARD,
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

enum Mod {
  AGGRESSIVE ("AGRO", 0.20, 1.0),
  AQUATIC    ("AQUA", 0.20, 1.0),
  ENTANGLED  ("ETNG", 0.00, 1.0),
  HARMONIZED ("HRMZ", 0.00, 1.0);
  
  String brief;
  double pickChance;
  double procChance;
  Mod(String b, double k, double c) {
    brief = b;
    pickChance = k;
    procChance = c;
  }
}

enum Terrain {
  // In order: tee, drive, approach, chip, putt
  // The ball [leaves the sand bunker] and flies X gallons, landing [in a water hazard.]
  OUT_OF_BOUNDS ("goes back in bounds",    "out of bounds.",            0xFF005000, new double[]{ 0,0,0,0,0 }, true),
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
