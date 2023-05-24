class Tourney {
  ArrayList<Player> players = new ArrayList<Player>();
  ArrayList<Hole> holes = new ArrayList<Hole>();
  ArrayList<Mod> mods = new ArrayList<Mod>();
  Weather weather;
  
  String tourneyName;
  int prizeMoney;
  
  // Open / Cup / Challenge / Invitational / Tour / Tournament

  Tourney(ArrayList<Player> ps, int holes) {
    players = ps;
    mods = generateRandomMods();
    generateNewHoles(holes);
    weather = generateRandomWeather();
    tourneyName = generateTourneyName();
    prizeMoney = generatePrizeMoney();
  }

  // Generate new courses
  void generateNewHoles(int num) {
    holes.clear();
    for (int i = 0; i < num; i++) {
      holes.add(new Hole(mods));
    }
  }
  
  // Generate weather
  Weather generateRandomWeather() {
    Weather[] weathers = Weather.values();
    return weathers[floor(random(weathers.length))];
  }
  
  // Generate Tourney name
  String generateTourneyName() {
    String tourneyNoun = generateRandomFromList("data/tournouns.txt");
    int r = int(random(1,9));
    switch(r) {
      case 1: return tourneyNoun + " Open";
      case 2: return tourneyNoun + " Cup";
      case 3: return tourneyNoun + " Challenge";
      case 4: return tourneyNoun + " Invitational";
      case 5: return tourneyNoun + " Tour";
      case 6: return tourneyNoun + " Tournament";
      case 7: return "The Player's " + tourneyNoun;
      case 8: return "The Hole " + tourneyNoun;
      default: return "Undefined";
    }   
  }
  
  ArrayList<Mod> generateRandomMods() {
    ArrayList<Mod> _mods = new ArrayList<Mod>();
    for (Mod m : Mod.values()) {
      if (m.modType.tourneyAllowed && random(1) < m.pickChance) _mods.add(m);
    }
    return _mods;
  }
  
  // Determine prize money
  int generatePrizeMoney() {
    return int(random(25000,50000));
  }
  
  Player randomPlayer() {
    int idx = int(random(players.size()));
    return players.get(idx);
  }
}
