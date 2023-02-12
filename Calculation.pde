static class Calculation {
  static final java.util.Random random = new java.util.Random();
  
  static float sRandom(float max) { return sRandom(0, max); }
  static float sRandom(float min, float max) { return (max-min) * random.nextFloat() + min; }
  
  static float totalMod(ArrayList<Effect> effects, FactorType ft) {
    float tm = 1;
    for (Effect e : effects) {
      if (e instanceof ModifyEffect && e.procCheck()) {
        ModifyEffect me = (ModifyEffect)e;
        tm *= me.changeFactor(ft);
      }
    }
    return tm;
  }
  static float totalMod(ArrayList<Effect> effects, FactorType ft, PlayState ps) {
    float tm = 1;
    for (Effect e : effects) {
      if (e instanceof ModifyEffect && e.procCheck(ps)) {
        ModifyEffect me = (ModifyEffect)e;
        tm *= me.changeFactor(ft);
      }
    }
    return tm;
  }
  
  static int weightedChoice(float[] weights) {
    float totalWeight = 0;
    for (float w : weights) totalWeight += w;
    float choice = sRandom(totalWeight);

    for (int i = 0; i < weights.length; i++) {
      choice -= weights[i];
      if (choice <= 0) return i;
    }
    return -1;
  }
  
  static float generateRealWidth(Hole h) {
    float ranFactor = sRandom(120,160);
    float len = ranFactor * h.thicc * Calculation.totalMod(h.mods, FactorType.REAL_WIDTH);
    return len;
  }
  
  static float generateGreenLength(Hole h) {
    float ranFactor = sRandom(80,120);
    float len = ranFactor * h.verdancy * Calculation.totalMod(h.mods, FactorType.GREEN_SIZE);
    return len;
  }
  
  static float[] calculateBaseDistances(PlayState ps) {
    // In order: tee, drive, approach, chip, putt
    float[] dists = new float[5];
    float[] terrainFactor = new float[5];
    for (int i = 0; i < 5; i++) {
      terrainFactor[i] = Slope.scrappy(1.2, ps.ball.terrain.smoothness[i]/ps.hole.roughness, ps.ball.player.scrappiness);
    }
    
    dists[0] = Slope.loggy(190,250,ps.ball.player.yeetness) * terrainFactor[0] * ps.totalMod(FactorType.TEE_DISTANCE);
    dists[1] = Slope.loggy(190,250,ps.ball.player.yeetness) * terrainFactor[1] * ps.totalMod(FactorType.DRIVE_DISTANCE);
    dists[2] = Slope.loggy(145,190,ps.ball.player.yeetness) * terrainFactor[2] * ps.totalMod(FactorType.APPROACH_DISTANCE);
    dists[3] = Slope.loggy(105,150,ps.ball.player.yeetness) * terrainFactor[3] * ps.totalMod(FactorType.CHIP_DISTANCE);
    dists[4] = Slope.loggy(50, 95, ps.ball.player.yeetness) * terrainFactor[4] * ps.totalMod(FactorType.PUTT_DISTANCE);
    
    return dists;
  }
  
  static float[] calculateBaseWeights(float[] projDists, PlayState ps) {
    float[] weights = new float[4];
    for (int i = 0; i < projDists.length; i++) {
      weights[i] = 1000 * Slope.gaussy(projDists[i], abs(ps.ball.distance), 6 * ps.ball.player.dumbassery);
    }
    
    weights[0] = 0;
    return weights;
  }

  static StrokeType calculateStrokeType(PlayState ps) {
    // Chance to do nothing
    float nothingChance = 0.001 * ps.totalMod(FactorType.NOTHING_CHANCE);
    if (sRandom(1) <= nothingChance) return StrokeType.NOTHING;
    
    // Always tee off the tee
    if (ps.ball.terrain == Terrain.TEE) return StrokeType.TEE;
    
    // Projected distances
    float[] projDists = calculateBaseDistances(ps);
    
    // In order: tee, drive, approach, chip, putt
    float[] weights = calculateBaseWeights(subset(projDists,1), ps);
    
    // Apply effects
    weights[0] *= ps.totalMod(FactorType.DRIVE_WEIGHT);
    weights[1] *= ps.totalMod(FactorType.APPROACH_WEIGHT);
    weights[2] *= ps.totalMod(FactorType.CHIP_WEIGHT);
    weights[3] *= ps.totalMod(FactorType.PUTT_WEIGHT);
    
    // Output the chosen swing type
    switch (weightedChoice(weights)) {
      case 0: return StrokeType.DRIVE;
      case 1: return StrokeType.APPROACH;
      case 2: return StrokeType.CHIP;
      case 3: return StrokeType.PUTT;
    }
    
    return StrokeType.NOTHING;
  }
  
  static float newDistToHole(float currDist, float dist, float angle) {
    return sqrt(sq(currDist) + sq(dist) - 2 * currDist * dist * cos(angle));
  }

  static StrokeOutcome calculateStrokeOutcome(PlayState ps, StrokeType st) {
    float[] distAndAngle = calculateStrokeDistanceAndAngle(ps, st);
    StrokeOutcomeType type = calculateStrokeOutcomeType(ps, st, distAndAngle[0]);
    
    switch (type) {
      case ACE:
      case SINK:
        distAndAngle[0] = ps.ball.distance;
        distAndAngle[1] = 0;
        break;
      case WHIFF:
        distAndAngle[0] = 1 * ps.totalMod(FactorType.WHIFF_DISTANCE);
        distAndAngle[1] = sRandom(-PI,PI);
        break;
      case NOTHING:
        distAndAngle[0] = 0;
        distAndAngle[1] = 0;
        break;
      case FLY: break;
    }
    
    float newDistToHole = newDistToHole(ps.ball.distance, distAndAngle[0], distAndAngle[1]);
    Terrain nextTerrain = calculateNextTerrain(ps, type, newDistToHole, distAndAngle[0], distAndAngle[1]);
    return new StrokeOutcome(type, nextTerrain, distAndAngle[0], distAndAngle[1]);
  }
  
  // Determine type
  static StrokeOutcomeType calculateStrokeOutcomeType(PlayState ps, StrokeType st, float dist) {
    if (st == StrokeType.NOTHING) return StrokeOutcomeType.NOTHING;
    
    // Check for ace
    if (ps.ball.stroke == 0) {
      float aceChance = 0.01 * ps.totalMod(FactorType.ACE_CHANCE);
      if (sRandom(1) <= aceChance) return StrokeOutcomeType.ACE;
    }
    
    // Check whiff
    float whiffRate = Slope.loggy(0.005, 0.015, ps.ball.player.cringe) * ps.totalMod(FactorType.WHIFF_RATE);
    if (sRandom(1) <= whiffRate) return StrokeOutcomeType.WHIFF;
    
    // Check sink
    float strokeTypeFactor = 1;
    switch (st) {
      case TEE: strokeTypeFactor = 0.2; break;
      case DRIVE: strokeTypeFactor = 0.2; break;
      case APPROACH: strokeTypeFactor = 0.4; break;
      case CHIP: strokeTypeFactor = 0.6; break;
      case PUTT: strokeTypeFactor = 1; break;
      case NOTHING: strokeTypeFactor = 0; break;
    }
    float sinkChance = Slope.expy(ps.ball.distance, 0.3, 0.8) * ps.hole.obedience * strokeTypeFactor * Slope.loggy(0.5, 1.5, ps.ball.player.charisma) * ps.totalMod(FactorType.SINK_CHANCE);
    if (sRandom(1) <= sinkChance && dist >= ps.ball.distance) return ps.ball.stroke == 0 ? StrokeOutcomeType.ACE : StrokeOutcomeType.SINK;
    
    // Fly by default
    return StrokeOutcomeType.FLY;
  }
  
  // Determine stroke distance
  static float[] calculateStrokeDistanceAndAngle(PlayState ps, StrokeType st) {
    float[] distBases = calculateBaseDistances(ps);
    float[] da = new float[2];
    int idx = 0;
    float variance = 0;
    float angle = 0;
    switch (st) {
      case TEE:
        idx = 0;
        variance = Slope.loggy(0.2,0.05,ps.ball.player.trigonometry) * ps.totalMod(FactorType.TEE_VARIANCE);
        angle = Slope.loggy(PI/4,PI/40,ps.ball.player.trigonometry) * ps.totalMod(FactorType.TEE_ANGLE);
        break;
      case DRIVE:
        idx = 1;
        variance = Slope.loggy(0.15,0.04,ps.ball.player.trigonometry) * ps.totalMod(FactorType.DRIVE_VARIANCE);
        angle = Slope.loggy(PI/4,PI/40,ps.ball.player.trigonometry) * ps.totalMod(FactorType.DRIVE_ANGLE);
        break;
      case APPROACH:
        idx = 2;
        variance = Slope.loggy(0.1,0.03,ps.ball.player.trigonometry) * ps.totalMod(FactorType.APPROACH_VARIANCE);
        angle = Slope.loggy(PI/6,PI/60,ps.ball.player.trigonometry) * ps.totalMod(FactorType.APPROACH_ANGLE);
        break;
      case CHIP:
        idx = 3;
        variance = Slope.loggy(0.05,0.02,ps.ball.player.trigonometry) * ps.totalMod(FactorType.CHIP_VARIANCE);
        angle = Slope.loggy(PI/8,PI/80,ps.ball.player.trigonometry) * ps.totalMod(FactorType.CHIP_ANGLE);
        break;
      case PUTT:
        idx = 4;
        variance = Slope.loggy(0.02,0.01,ps.ball.player.trigonometry) * ps.totalMod(FactorType.PUTT_VARIANCE);
        angle = Slope.loggy(PI/12,PI/120,ps.ball.player.trigonometry) * ps.totalMod(FactorType.PUTT_ANGLE);
        break;
      case NOTHING:
        float[] dan2 = {0,0};
        return dan2;
    }
    variance = max(variance, 0);
    angle = constrain(angle * ps.totalMod(FactorType.ANY_STROKE_ANGLE), 0, PI);
    da[0] = distBases[idx] * sRandom(1-variance, 1+variance) * ps.totalMod(FactorType.ANY_STROKE_DISTANCE);
    da[1] = sRandom(-angle,angle);
    return da;
  }
  
  // Determine next terrain
  static Terrain calculateNextTerrain(PlayState ps, StrokeOutcomeType sot, float distFromHole, float strokeDist, float strokeAngle) {
    switch (sot) {
      case ACE:
      case SINK:
        return Terrain.HOLE;
      case WHIFF:
        if (abs(distFromHole) <= ps.hole.greenLength) return Terrain.GREEN;
        else return ps.ball.terrain;
      case NOTHING:
        return ps.ball.terrain;
      case FLY:
        if (abs(distFromHole) <= ps.hole.greenLength) return Terrain.GREEN;
        
        // Heterosexuality determines how relevant the real calculation is, bisexuality determines if the curve works out in the player's favor
        float sideways = abs(strokeDist * sin(strokeAngle));
        float wiggleRoom = ps.hole.realWidth * (1 + Slope.loggy(-1, 1, ps.ball.player.bisexuality) * pow(2,-ps.hole.heterosexuality)/6);
        if (sideways > wiggleRoom) return Terrain.OUT_OF_BOUNDS;
        
        // Probabilities of landing in hazards
        float waterHazardChance = ps.hole.quench * Slope.loggy(1.75, 0.25, ps.ball.player.trigonometry) * ps.totalMod(FactorType.WATER_HAZARD_CHANCE);
        if (sRandom(1) <= waterHazardChance) return Terrain.WATER_HAZARD;
        float sandBunkerChance = ps.hole.thirst * Slope.loggy(1.75, 0.25, ps.ball.player.trigonometry) * ps.totalMod(FactorType.BUNKER_CHANCE);
        if (sRandom(1) <= sandBunkerChance) return Terrain.BUNKER;
        
        return Terrain.ROUGH;
    }
    
    return Terrain.OUT_OF_BOUNDS;
  }
}
