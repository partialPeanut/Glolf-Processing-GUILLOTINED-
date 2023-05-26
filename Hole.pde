// Holes: par, roughness, heterosexuality (straightness), thicc (likelihood to go oob), verdancy (easiness to get on the green),
//          obedience (green tameness), quench (water hazards), thirst (sand bunkers)

class Hole {
  float realLength, realWidth, greenLength;
  int par;
  float succblow, roughness, heterosexuality, thicc, verdancy, obedience, quench, thirst;
  Wildlife wildlife;
  ArrayList<Mod> courseMods;
  ArrayList<Mod> mods;

  // Generates random course
  Hole(ArrayList<Mod> cm) {
    courseMods = cm;
    mods = generateMods();
    
    float quenchMult = 1;
    float thirstMult = 1;
    if (mods.contains(Mod.COASTAL)) {
      quenchMult = (float)Mod.COASTAL.val1;
      thirstMult = (float)Mod.COASTAL.val2;
    }
    
    succblow = generateRandomSuccblow();
    
    roughness = generateRandomQuality();
    heterosexuality = generateRandomQuality();
    thicc = generateRandomQuality();
    verdancy = generateRandomQuality();
    obedience = generateRandomQuality();
    quench = generateHazardousQuality() * quenchMult;
    thirst = generateHazardousQuality() * thirstMult;
    
    wildlife = generateWildlife();
    
    realLength = generateRealLength();
    realWidth = generateRealWidth();
    greenLength = generateGreenLength();
    
    par = lengthToPar(realLength);
  }

  Hole(JSONObject json) {
    par = json.getInt("par");
    
    succblow = json.getFloat("succblow");
    roughness = json.getFloat("roughness");
    heterosexuality = json.getFloat("heterosexuality");
    thicc = json.getFloat("thicc");
    verdancy = json.getFloat("verdancy");
    obedience = json.getFloat("obedience");
    quench = json.getFloat("quench");
    thirst = json.getFloat("thirst");
    
    realLength = json.getFloat("realLength");
    realWidth = json.getFloat("realWidth");
    greenLength = json.getFloat("greenLength");
  }

  // Converts course to JSON
  JSONObject toJSON() {
    JSONObject json = new JSONObject();

    json.setInt("par", par);
    
    json.setFloat("succblow", succblow);
    json.setFloat("roughness", roughness);
    json.setFloat("heterosexuality", heterosexuality);
    json.setFloat("thicc", thicc);
    json.setFloat("verdancy", verdancy);
    json.setFloat("obedience", obedience);
    json.setFloat("quench", quench);
    json.setFloat("thirst", thirst);
    
    json.setFloat("realLength", realLength);
    json.setFloat("realWidth", realWidth);
    json.setFloat("greenLength", greenLength);

    return json;
  }
  
  // Randomizes wind
  void randomizeWind() { succblow = generateRandomSuccblow(); }

  // Generates a random par
  int lengthToPar(float len) {
    if (len < 150) return int(4.1);
    else if (len < 250) return int(-0.009*len + 5.45);
    else return int(len/150 + 23/15);
  }

  // Determines the real dimensions of the hole in gallons
  float generateRealLength() { return random(0, 1000); }
  float generateRealWidth() { return Calculation.generateRealWidth(this); }
  float generateGreenLength() { return Calculation.generateGreenLength(this); }
  
  // Generates a random windy thing
  float generateRandomSuccblow() {
    return randomGaussian() * 0.06;
  }

  // Generates a random quality
  float generateRandomQuality() {
    return 1 + randomGaussian() * 0.12;
  }
  
  // Generates a random hazard chance
  float generateHazardousQuality() {
    return 0.06 + randomGaussian() * 0.02;
  }
  
  ArrayList<Mod> generateMods() {
    ArrayList<Mod> _mods = new ArrayList<Mod>();
    for (Mod m : courseMods) {
      if (m.modType == ModType.HOLE_OR_COURSE) _mods.add(m);
    }
    for (Mod m : generateRandomMods()) {
      if (!_mods.contains(m)) _mods.add(m);
    }
    return _mods;
  }
  ArrayList<Mod> generateRandomMods() {
    ArrayList<Mod> _mods = new ArrayList<Mod>();
    for (Mod m : Mod.values()) {
      if (m.modType.holeAllowed && random(1) < m.pickChance) _mods.add(m);
    }
    return _mods;
  }
  
  Wildlife generateWildlife() {
    if (mods.contains(Mod.SWAMPLAND) && random(1) < Mod.SWAMPLAND.procChance) return Wildlife.MOSQUITO;
    else return generateRandomWildlife();
  }
  Wildlife generateRandomWildlife() {
    Wildlife[] lives = Wildlife.values();
    return lives[floor(random(lives.length))];
  }
}
