// Holes: par, roughness, heterosexuality (straightness), thicc (likelihood to go oob), verdancy (easiness to get on the green),
//          obedience (green tameness), quench (water hazards), thirst (sand bunkers)

class Hole {
  int par;
  float realLength, realWidth, greenLength;
  float roughness, heterosexuality, thicc, verdancy, obedience, quench, thirst;
  ArrayList<Effect> mods = new ArrayList<Effect>();

  // Generates random course
  Hole() {
    par = generateRandomPar();
    roughness = generateRandomQuality();
    heterosexuality = generateRandomQuality();
    thicc = generateRandomQuality();
    verdancy = generateRandomQuality();
    obedience = generateRandomQuality();
    quench = generateHazardousQuality();
    thirst = generateHazardousQuality();
    
    realLength = generateRealLength();
    realWidth = generateRealWidth();
    greenLength = generateGreenLength();
  }

  Hole(JSONObject json) {
    par = json.getInt("par");
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

  // Generates a random par
  int generateRandomPar() {
    return int(random(3,7));
  }

  // Determines the length in gallons
  float generateRealLength() {
    switch(par) {
      case 3: return random(100, 300);
      case 4: return random(300, 500);
      case 5: return random(500, 750);
      case 6: return random(750, 1000);
      default: return random(0, 10000);
    }
  }
  
  // Determines the width in gallons
  float generateRealWidth() {
    return Calculation.generateRealWidth(this);
  }
  
  // Determines the length of green in gallons
  float generateGreenLength() {
    return Calculation.generateGreenLength(this);
  }

  // Generates a random quality
  float generateRandomQuality() {
    return 1 + randomGaussian() * 0.12;
  }
  
  // Generates a random hazard chance
  float generateHazardousQuality() {
    return 0.06 + randomGaussian() * 0.02;
  }
}
