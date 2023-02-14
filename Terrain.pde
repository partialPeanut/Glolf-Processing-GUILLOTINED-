static class Terrain {
  // In order: tee, drive, approach, chip, putt
  private static final float[] OOB_SMOOTH = { 0,0,0,0,0 };
  private static final float[] WHZ_SMOOTH = { 0,0,0,0,0 };
  private static final float[] HLE_SMOOTH = { 0,0,0,0,0 };
  private static final float[] TEE_SMOOTH = { 1.2, 1.0, 0.8, 0.6, 0.1 };
  private static final float[] RGH_SMOOTH = { 0.0, 0.9, 0.9, 0.8, 0.6 };
  private static final float[] GRN_SMOOTH = { 0.0, 1.0, 1.0, 1.0, 1.0 };
  private static final float[] BNK_SMOOTH = { 0.0, 0.2, 0.2, 0.6, 0.1 };
  
  static final Terrain OUT_OF_BOUNDS = new Terrain("goes back in bounds",    "out of bounds",      OOB_SMOOTH, true);
  static final Terrain TEE =           new Terrain("leaves the tee",         "perfectly on a tee", TEE_SMOOTH, false);
  static final Terrain ROUGH =         new Terrain("jumps from the rough",   "in the rough",       RGH_SMOOTH, false);
  static final Terrain GREEN =         new Terrain("leaves the green",       "in the green",       GRN_SMOOTH, false);
  static final Terrain BUNKER =        new Terrain("leaves the sand bunker", "in a sand bunker",   BNK_SMOOTH, false);
  static final Terrain WATER_HAZARD =  new Terrain("goes back in bounds",    "in a water hazard",  WHZ_SMOOTH, true);
  static final Terrain HOLE =          new Terrain("jumps out of the hole",  "in the hole",        HLE_SMOOTH, false);

  // The ball [leaves the sand bunker] and flies X gallons, landing [in a water hazard].
  String leavingText;
  String arrivingText;

  float[] smoothness;
  boolean outOfBounds;

  Terrain(String l, String a, float[] s, boolean o) {
    leavingText = l;
    arrivingText = a;

    smoothness = s;
    outOfBounds = o;
  }
}
