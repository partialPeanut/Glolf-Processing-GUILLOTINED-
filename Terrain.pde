static class Terrain {
  // In order: tee, drive, approach, chip, putt
  private static final float[] OOB_SMOOTH = { 0,0,0,0,0 };
  private static final float[] WHZ_SMOOTH = { 0,0,0,0,0 };
  private static final float[] HLE_SMOOTH = { 0,0,0,0,0 };
  private static final float[] TEE_SMOOTH = { 1.2, 1.0, 0.8, 0.6, 0.1 };
  private static final float[] RGH_SMOOTH = { 0.0, 0.9, 0.9, 0.8, 0.6 };
  private static final float[] GRN_SMOOTH = { 0.0, 1.0, 1.0, 1.0, 1.0 };
  private static final float[] BNK_SMOOTH = { 0.0, 0.2, 0.2, 0.6, 0.1 };
  private static final float[] FLT_SMOOTH = { 0.0, 0.1, 0.1, 0.1, 0.1 };
  
  static final Terrain OUT_OF_BOUNDS = new Terrain("goes back in bounds",    "out of bounds.",                                #005000, OOB_SMOOTH, true);
  static final Terrain TEE =           new Terrain("leaves the tee",         "perfectly on a tee.",                           #A0A0A0, TEE_SMOOTH, false);
  static final Terrain ROUGH =         new Terrain("jumps from the rough",   "in the rough.",                                 #007800, RGH_SMOOTH, false);
  static final Terrain GREEN =         new Terrain("leaves the green",       "in the green.",                                 #00A000, GRN_SMOOTH, false);
  static final Terrain BUNKER =        new Terrain("leaves the sand bunker", "in a sand bunker.",                             #FFC107, BNK_SMOOTH, false);
  static final Terrain WATER_HAZARD =  new Terrain("goes back in bounds",    "in a water hazard.",                            #03A9F4, WHZ_SMOOTH, true);
  static final Terrain HOLE =          new Terrain("jumps out of the hole",  "in the hole.",                                  #A0A0A0, HLE_SMOOTH, false);
  static final Terrain WATER_FLOAT  =  new Terrain("splashes away",          "in a water hazard. The player swims after it!", #03A9F4, FLT_SMOOTH, false);

  // The ball [leaves the sand bunker] and flies X gallons, landing [in a water hazard.]
  String leavingText;
  String arrivingText;
  color tColor;
  float[] smoothness;
  boolean outOfBounds;

  Terrain(String l, String a, color c, float[] s, boolean o) {
    leavingText = l;
    arrivingText = a;
    tColor = c;
    smoothness = s;
    outOfBounds = o;
  }
}
