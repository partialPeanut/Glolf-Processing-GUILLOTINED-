class Tourney {
  ArrayList<Player> players = new ArrayList<Player>();
  ArrayList<Hole> holes = new ArrayList<Hole>();
  ArrayList<Effect> mods = new ArrayList<Effect>();
  int prizeMoney;
  String tourneyName;
  
  // Open / Cup / Challenge / Invitational / Tour / Tournament

  Tourney(ArrayList<Player> ps, int holes) {
    players = ps;
    generateNewHoles(holes);
    tourneyName = generateTourneyName();
    prizeMoney = generatePrizeMoney();
  }

  // Generate new courses
  void generateNewHoles(int num) {
    holes.clear();
    for (int i = 0; i < num; i++) {
      holes.add(new Hole());
    }
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
  
  // Determine prize money
  int generatePrizeMoney() {
    return int(random(10000,20001));
  }
  
  Player randomPlayer() {
    int idx = int(random(players.size()));
    return players.get(idx);
  }
}
