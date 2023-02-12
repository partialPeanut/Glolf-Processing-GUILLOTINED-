// Players: name, gender (random adjectives), cringe (chance of total beefitude), dumbassery (choice of stroke type), yeetness (strength), trigonometry (accuracy),
//          bisexuality (curve skill), asexuality (hole-in-one chance), scrappiness (skill in rough areas), charisma (get it in the hole ;3), autism (magic)

class Player {
  String id, firstName, lastName, gender;
  float cringe, dumbassery, yeetness, trigonometry, bisexuality, asexuality, scrappiness, charisma, autism;
  ArrayList<Effect> mods = new ArrayList<Effect>();

  // Full random player gen
  Player(String _id) {
    id = _id;
    firstName = generateRandomFromList("data/firstnames.txt");
    lastName = generateRandomFromList("data/lastnames.txt");
    gender = generateRandomFromList("data/genders.txt");
    cringe = generateRandomStat();
    dumbassery = generateRandomStat();
    yeetness = generateRandomStat();
    trigonometry = generateRandomStat();
    bisexuality = generateRandomStat();
    asexuality = generateRandomStat();
    scrappiness = generateRandomStat();
    charisma = generateRandomStat();
    autism = generateRandomStat();
  }

  // Custom player gen
  Player(JSONObject json) {
    id = json.getString("id");
    firstName = json.getString("firstName");
    lastName = json.getString("lastName");
    gender = json.getString("gender");
    cringe = json.getFloat("cringe");
    dumbassery = json.getFloat("dumbassery");
    yeetness = json.getFloat("yeetness");
    trigonometry = json.getFloat("trigonometry");
    bisexuality = json.getFloat("bisexuality");
    asexuality = json.getFloat("asexuality");
    scrappiness = json.getFloat("scrappiness");
    charisma = json.getFloat("charisma");
    autism = json.getFloat("autism");
  }

  JSONObject toJSON() {
    JSONObject json = new JSONObject();

    json.setString("id", id);
    json.setString("firstName", firstName);
    json.setString("lastName", lastName);
    json.setString("gender", gender);
    json.setFloat("cringe", cringe);
    json.setFloat("dumbassery", dumbassery);
    json.setFloat("yeetness", yeetness);
    json.setFloat("trigonometry", trigonometry);
    json.setFloat("bisexuality", bisexuality);
    json.setFloat("asexuality", asexuality);
    json.setFloat("scrappiness", scrappiness);
    json.setFloat("charisma", charisma);
    json.setFloat("autism", autism);

    return json;
  }

  // Picks a random item from .txt file
  String generateRandomFromList(String filename) {
    String[] list = loadStrings(filename);
    int idx = int(random(list.length));
    return list[idx];
  }

  // Generates a random float via normal distribution w mean 6 and s.d. 2
  float generateRandomStat() {
    return 6 + randomGaussian() * 2;
  }
}
