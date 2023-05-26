class Course {
  ArrayList<Hole> holes = new ArrayList<Hole>();
  ArrayList<Mod> mods = new ArrayList<Mod>();
  Weather weather;
  
  Course(int numHoles) {
    mods = generateRandomMods();
    holes = generateNewHoles(numHoles);
    weather = generateRandomWeather();
  }
  
  ArrayList<Mod> generateRandomMods() {
    ArrayList<Mod> _mods = new ArrayList<Mod>();
    for (Mod m : Mod.values()) {
      if (m.modType.courseAllowed && random(1) < m.pickChance) _mods.add(m);
    }
    return _mods;
  }
  
  // Generate new holes
  ArrayList<Hole> generateNewHoles(int num) {
    ArrayList<Hole> _holes = new ArrayList<Hole>();
    for (int i = 0; i < num; i++) {
      _holes.add(new Hole(mods));
    }
    return _holes;
  }
  
  // Generate weather
  Weather generateRandomWeather() {
    Weather[] weathers = Weather.values();
    return weathers[floor(random(weathers.length))];
  }
}
