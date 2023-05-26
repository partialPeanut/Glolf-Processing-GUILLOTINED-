class Tourney {
  ArrayList<Player> players = new ArrayList<Player>();
  ArrayList<Course> courses = new ArrayList<Course>();
  ArrayList<Mod> mods = new ArrayList<Mod>();
  
  String tourneyName;
  int prizeMoney;

  Tourney(ArrayList<Player> ps, int numCourses, int holesPerCourse) {
    players = ps;
    courses = generateNewCourses(numCourses, holesPerCourse);
    mods = generateRandomMods();
    tourneyName = generateTourneyName();
    prizeMoney = generatePrizeMoney();
  }
  
  // Generate new courses
  ArrayList<Course> generateNewCourses(int num, int hpc) {
    ArrayList<Course> _courses = new ArrayList<Course>();
    for (int i = 0; i < num; i++) {
      _courses.add(new Course(hpc));
    }
    return _courses;
  }
  
  // Generate Tourney name
  String generateTourneyName() {
    String tourneyNoun = generateRandomFromList("data/lists/t_nouns.txt");
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
    return int(random(100000,200000));
  }
  
  Player randomPlayer() {
    int idx = int(random(players.size()));
    return players.get(idx);
  }
}
