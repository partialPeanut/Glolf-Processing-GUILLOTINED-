// Holes: par, roughness, heterosexuality (straightness), thicc (likelihood to go oob), verdancy (easiness to get on the green),
//          obedience (green tameness), quench (water hazards), thirst (sand bunkers)

class Hole {
  float realLength, realWidth, greenLength;
  int par;
  float roughness, heterosexuality, thicc, verdancy, obedience, quench, thirst;
  ArrayList<Effect> mods = new ArrayList<Effect>();

  // Generates random course
  Hole() {
    realLength = generateRealLength();
    realWidth = generateRealWidth();
    greenLength = generateGreenLength();
    
    par = lengthToPar(realLength);
    roughness = generateRandomQuality();
    heterosexuality = generateRandomQuality();
    thicc = generateRandomQuality();
    verdancy = generateRandomQuality();
    obedience = generateRandomQuality();
    quench = generateHazardousQuality();
    thirst = generateHazardousQuality();
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
  int lengthToPar(float len) {
    if (len < 150) return int(4.1);
    else if (len < 250) return int(-0.009*len + 5.45);
    else return int(len/150 + 23/15);
  }

  // Determines the real dimensions of the hole in gallons
  float generateRealLength() { return random(0, 1000); }
  float generateRealWidth() { return Calculation.generateRealWidth(this); }
  float generateGreenLength() { return Calculation.generateGreenLength(this); }

  // Generates a random quality
  float generateRandomQuality() {
    return 1 + randomGaussian() * 0.12;
  }
  
  // Generates a random hazard chance
  float generateHazardousQuality() {
    return 0.06 + randomGaussian() * 0.02;
  }
}
