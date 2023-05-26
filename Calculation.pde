static class Calculation {
  static final java.util.Random random = new java.util.Random();
  
  static float sRandom(float max) { return sRandom(0, max); }
  static float sRandom(float min, float max) { return (max-min) * random.nextFloat() + min; }
  
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
    float len = ranFactor * h.thicc;
    return len;
  }
  
  static float generateGreenLength(Hole h) {
    float ranFactor = sRandom(80,120);
    float len = ranFactor * h.verdancy;
    return len;
  }
  
  static float[] calculateBaseDistances(PlayState ps) {
    // In order: tee, drive, approach, chip, putt
    float[] dists = new float[5];
    float[] terrainFactor = new float[5];
    for (int i = 0; i < 5; i++) {
      terrainFactor[i] = constrain(Slope.scrappy(1.2, (float)ps.currentBall.terrain.smoothness[i]/ps.hole.roughness, ps.currentPlayer().scrappiness), 0.05, 1);
    }
    
    float windFactor = 1 + (ps.currentBall.past ? -1 : 1) * ps.hole.succblow;
    
    dists[0] = Slope.loggy(190,250,ps.currentPlayer().yeetness) * terrainFactor[0] * windFactor;
    dists[1] = Slope.loggy(190,250,ps.currentPlayer().yeetness) * terrainFactor[1] * windFactor;
    dists[2] = Slope.loggy(145,190,ps.currentPlayer().yeetness) * terrainFactor[2] * windFactor;
    dists[3] = Slope.loggy(105,150,ps.currentPlayer().yeetness) * terrainFactor[3] * windFactor;
    dists[4] = Slope.loggy(50, 95, ps.currentPlayer().yeetness) * terrainFactor[4] * windFactor;
    
    return dists;
  }
  
  static float[] calculateBaseWeights(float[] projDists, PlayState ps) {
    float[] weights = new float[4];
    for (int i = 0; i < projDists.length; i++) {
      weights[i] = 1000 * Slope.gaussy(projDists[i], abs(ps.currentBall.distance), 200 / max(ps.currentPlayer().smartassery, 1));
    }
    
    weights[0] = 0;
    return weights;
  }

  static StrokeType calculateStrokeType(PlayState ps) {
    // Chance to do nothing
    float nothingChance = 0.001;
    if (sRandom(1) <= nothingChance) return StrokeType.NOTHING;
    
    // Always tee off the tee
    if (ps.currentBall.terrain == Terrain.TEE) return StrokeType.TEE;
    
    // Projected distances
    float[] projDists = calculateBaseDistances(ps);
    
    // In order: tee, drive, approach, chip, putt
    float[] weights = calculateBaseWeights(subset(projDists,1), ps);
    
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
        distAndAngle[0] = ps.currentBall.distance;
        distAndAngle[1] = 0;
        break;
      case WHIFF:
        distAndAngle[0] = 1;
        distAndAngle[1] = sRandom(-PI,PI);
        break;
      case NOTHING:
        distAndAngle[0] = 0;
        distAndAngle[1] = 0;
        break;
      case FLY: break;
    }
    
    float newDistToHole = newDistToHole(ps.currentBall.distance, distAndAngle[0], distAndAngle[1]);
    Terrain nextTerrain = calculateNextTerrain(ps, type, newDistToHole, distAndAngle[0], distAndAngle[1]);
    return new StrokeOutcome(type, nextTerrain, distAndAngle[0], distAndAngle[1]);
  }
  
  // Determine type
  static StrokeOutcomeType calculateStrokeOutcomeType(PlayState ps, StrokeType st, float dist) {
    if (st == StrokeType.NOTHING) return StrokeOutcomeType.NOTHING;
    
    // Check for ace
    if (ps.currentBall.stroke == 0) {
      float aceChance = 0.01;
      if (sRandom(1) <= aceChance) return StrokeOutcomeType.ACE;
    }
    
    // Check whiff
    float whiffRate = Slope.loggy(0.015, 0.005, ps.currentPlayer().competence);
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
    float sinkChance = Slope.expy(ps.currentBall.distance, 0.3, 0.8) * ps.hole.obedience * strokeTypeFactor * Slope.loggy(0.5, 1.5, ps.currentPlayer().charisma);
    if (sRandom(1) <= sinkChance && dist >= ps.currentBall.distance) return ps.currentBall.stroke <= 1 ? StrokeOutcomeType.ACE : StrokeOutcomeType.SINK;
    
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
        variance = Slope.loggy(0.2,0.05,ps.currentPlayer().trigonometry);
        angle = Slope.loggy(PI/4,PI/40,ps.currentPlayer().trigonometry);
        break;
      case DRIVE:
        idx = 1;
        variance = Slope.loggy(0.15,0.04,ps.currentPlayer().trigonometry);
        angle = Slope.loggy(PI/4,PI/40,ps.currentPlayer().trigonometry);
        break;
      case APPROACH:
        idx = 2;
        variance = Slope.loggy(0.1,0.03,ps.currentPlayer().trigonometry);
        angle = Slope.loggy(PI/6,PI/60,ps.currentPlayer().trigonometry);
        break;
      case CHIP:
        idx = 3;
        variance = Slope.loggy(0.05,0.02,ps.currentPlayer().trigonometry);
        angle = Slope.loggy(PI/8,PI/80,ps.currentPlayer().trigonometry);
        break;
      case PUTT:
        idx = 4;
        variance = Slope.loggy(0.02,0.01,ps.currentPlayer().trigonometry);
        angle = Slope.loggy(PI/12,PI/120,ps.currentPlayer().trigonometry);
        break;
      case NOTHING:
        float[] dan2 = {0,0};
        return dan2;
    }
    variance = max(variance, 0);
    angle = constrain(angle, 0, PI);
    da[0] = distBases[idx] * sRandom(1-variance, 1+variance);
    da[1] = sRandom(-angle,angle);
    return da;
  }
  
  // Determine next terrain of a ball given a "rolling", knocked, or whiffed ball
  static Terrain calculatePostRollTerrain(PlayState ps, Ball b) {
    if (abs(b.distance) <= ps.hole.greenLength) return Terrain.GREEN;
    else if (b.terrain == Terrain.TEE || b.terrain == Terrain.GREEN) return Terrain.ROUGH;
    else return b.terrain;
  }
  static Terrain calculatePostRollTerrain(PlayState ps, float d, Ball b) {
    if (abs(d) <= ps.hole.greenLength) return Terrain.GREEN;
    else if (b.terrain == Terrain.TEE || b.terrain == Terrain.GREEN) return Terrain.ROUGH;
    else return b.terrain;
  }
  
  // Determine next terrain
  static Terrain calculateNextTerrain(PlayState ps, StrokeOutcomeType sot, float distFromHole, float strokeDist, float strokeAngle) {
    switch (sot) {
      case ACE:
      case SINK:
        return Terrain.HOLE;
      case WHIFF:
        return calculatePostRollTerrain(ps, distFromHole, ps.currentBall);
      case NOTHING:
        return ps.currentBall.terrain;
      case FLY:
        if (abs(distFromHole) <= ps.hole.greenLength) return Terrain.GREEN;
        
        // Heterosexuality determines how relevant the real calculation is, bisexuality determines if the curve works out in the player's favor
        float sideways = abs(strokeDist * sin(strokeAngle));
        float wiggleRoom = ps.hole.realWidth * (1 + Slope.loggy(-1, 1, ps.currentPlayer().bisexuality) * pow(2,-ps.hole.heterosexuality)/6);
        if (sideways > wiggleRoom) return Terrain.OUT_OF_BOUNDS;
        
        // Probabilities of landing in hazards
        float waterHazardChance = ps.hole.quench * Slope.loggy(1.75, 0.25, ps.currentPlayer().trigonometry);
        if (sRandom(1) <= waterHazardChance) {
          Terrain waterType = ps.currentBall.player.mods.contains(Mod.SEMI_AQUATIC) ? Terrain.WATER_FLOAT : Terrain.WATER_HAZARD;
          return waterType;
        }
        float sandBunkerChance = ps.hole.thirst * Slope.loggy(1.75, 0.25, ps.currentPlayer().trigonometry);
        if (sRandom(1) <= sandBunkerChance) {
          if (ps.hole.wildlife == Wildlife.WORM && sRandom(1) <= Wildlife.WORM.procChance) return Terrain.WORM_PIT;
          return Terrain.BUNKER;
        }
        
        return Terrain.ROUGH;
    }
    
    return Terrain.OUT_OF_BOUNDS;
  }
}

static class Slope {
  static float loggy(float min, float max, float x) {
    return (max-min)/2 * (log((x-6+sqrt(sq(x-6)+4))/2)/log(3+sqrt(10))+1) + min;
  }
  
  static float scrappy(float b, float x, float s) {
    return pow(x, pow(b,6-s));
  }
  
  static float gaussy(float x, float m, float sd) {
    return exp(-sq(x-m)/(2*sq(sd)))/sd;
  }
  
  static float expy(float x, float b, float z) {
    return z * pow(b, sq(x)/8000);
  }
}

static class StrokeOutcome {
  StrokeOutcomeType type;
  Terrain newTerrain;
  float distance;
  float angle;

  StrokeOutcome(StrokeOutcomeType sot, Terrain nt, float d, float a) {
    type = sot;
    newTerrain = nt;
    distance = d;
    angle = a;
  }
}
