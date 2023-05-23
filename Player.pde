// Players: name, gender (random adjectives), cringe (chance of total beefitude), dumbassery (choice of stroke type), yeetness (strength), trigonometry (accuracy),
//          bisexuality (curve skill), asexuality (hole-in-one chance), scrappiness (skill in rough areas), charisma (get it in the hole ;3), autism (magic)

class Player {
  String id, firstName, lastName, gender;
  StringList suffixes;
  float competence, smartassery, yeetness, trigonometry, bisexuality, asexuality, scrappiness, charisma, autism;
  int networth;
  ArrayList<Mod> mods = new ArrayList<Mod>();

  // Full random player gen
  Player(String _id) {
    id = _id;
    firstName = generateRandomFromList("data/firstnames.txt");
    lastName = generateRandomFromList("data/lastnames.txt");
    suffixes = new StringList();
    gender = generateRandomFromList("data/genders.txt");
    mods = generateRandomMods();
    competence = generateRandomStat();
    smartassery = generateRandomStat();
    yeetness = generateRandomStat();
    trigonometry = generateRandomStat();
    bisexuality = generateRandomStat();
    asexuality = generateRandomStat();
    scrappiness = generateRandomStat();
    charisma = generateRandomStat();
    autism = generateRandomStat();
    networth = generateNetWorth();
  }

  // Custom player gen
  Player(JSONObject json) {
    id = json.getString("id");
    firstName = json.getString("firstName");
    lastName = json.getString("lastName");
    gender = json.getString("gender");
    competence = json.getFloat("competence");
    smartassery = json.getFloat("smartassery");
    yeetness = json.getFloat("yeetness");
    trigonometry = json.getFloat("trigonometry");
    bisexuality = json.getFloat("bisexuality");
    asexuality = json.getFloat("asexuality");
    scrappiness = json.getFloat("scrappiness");
    charisma = json.getFloat("charisma");
    autism = json.getFloat("autism");
    networth = json.getInt("networth");
  }
  
  // Player copy
  Player(Player p) {
    id = p.id;
    firstName = p.firstName;
    lastName = p.lastName;
    suffixes = new StringList(p.suffixes);
    gender = p.gender;
    competence = p.competence;
    smartassery = p.smartassery;
    yeetness = p.yeetness;
    trigonometry = p.trigonometry;
    bisexuality = p.bisexuality;
    asexuality = p.asexuality;
    scrappiness = p.scrappiness;
    charisma = p.charisma;
    autism = p.autism;
    networth = p.networth;
  }

  JSONObject toJSON() {
    JSONObject json = new JSONObject();

    json.setString("id", id);
    json.setString("firstName", firstName);
    json.setString("lastName", lastName);
    json.setString("gender", gender);
    json.setFloat("competence", competence);
    json.setFloat("smartassery", smartassery);
    json.setFloat("yeetness", yeetness);
    json.setFloat("trigonometry", trigonometry);
    json.setFloat("bisexuality", bisexuality);
    json.setFloat("asexuality", asexuality);
    json.setFloat("scrappiness", scrappiness);
    json.setFloat("charisma", charisma);
    json.setFloat("autism", autism);
    json.setInt("networth", networth);

    return json;
  }

  // Generates a random float via normal distribution w mean 6 and s.d. 2
  float generateRandomStat() {
    return 6 + randomGaussian() * 2;
  }
  
  ArrayList<Mod> generateRandomMods() {
    ArrayList<Mod> _mods = new ArrayList<Mod>();
    for (Mod m : Mod.values()) {
      if (random(1) < m.pickChance) _mods.add(m);
    }
    return _mods;
  }
    
  // Generates a random net worth
  int generateNetWorth() {
    float r = random(0,100);
    if (r < 70) {
      return int(random(-60000,60000));
    }
    else if (r < 99) {
      return int(random(40000,300000));
    }
    else {
      return int(random(300000,600000));
    }
  }
  
  // Returns a string with the name of a random player stat
  String randomStat() {
    String[] stats = { "competence", "smartassery", "yeetness", "trigonometry", "bisexuality", "asexuality", "scrappiness", "charisma", "autism" };
    return stats[floor(random(9))];
  }
}
