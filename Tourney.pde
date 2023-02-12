class Tourney {
  ArrayList<Player> players = new ArrayList<Player>();
  ArrayList<Hole> holes = new ArrayList<Hole>();
  ArrayList<Effect> mods = new ArrayList<Effect>();

  Tourney(ArrayList<Player> ps, int holes) {
    players = ps;
    generateNewHoles(holes);
  }

  // Generate new courses
  void generateNewHoles(int num) {
    holes.clear();
    for (int i = 0; i < num; i++) {
      holes.add(new Hole());
    }
  }
}
