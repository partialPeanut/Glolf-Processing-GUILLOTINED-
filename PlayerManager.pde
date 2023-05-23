class PlayerManager {
  int minID = 100000;
  int maxID = 999999;
  ArrayList<Player> allPlayers;
  ArrayList<Player> livePlayers;
  ArrayList<Player> deadPlayers;
  ArrayList<Player> erasedPlayers;
  
  ArrayList<StringList> entangledPlayers;
  IntDict poisonCounters;

  PlayerManager() {
    allPlayers = new ArrayList<Player>();
    livePlayers = new ArrayList<Player>();
    deadPlayers = new ArrayList<Player>();
    erasedPlayers = new ArrayList<Player>();
    
    entangledPlayers = new ArrayList<StringList>();
    poisonCounters = new IntDict();
  }

  void clearAllPlayers() { allPlayers.clear(); }

  void addNewPlayers(int num) {
    for (int i = 0; i < num; i++) {
      addNewPlayer();
    }
  }
  Player addNewPlayer() {
    Player newPlayer = new Player(generateNewID());
    allPlayers.add(newPlayer);
    livePlayers.add(newPlayer);
    return newPlayer;
  }
  Player addPlayerClone(Player p) {
    Player clone = new Player(p);
    clone.id = generateNewID();
    allPlayers.add(clone);
    livePlayers.add(clone);
    return clone;
  }
  
  String generateNewID() {
    boolean isNew = false;
    String newID = "-1";
    while (!isNew) {
      isNew = true;
      int newIDint = int(random(minID, maxID+1));
      newID = "" + newIDint;
      for (Player p : allPlayers) {
        if (p.id == newID) isNew = false;
      }
    }
    return newID;
  }

  void savePlayersToJSON() {
    JSONArray players = new JSONArray();
    int i = 0;
    for (Player p : allPlayers) {
      players.setJSONObject(i, p.toJSON());
      i++;
    }
    saveJSONArray(players, "data/players.json");
  }

  void loadPlayersFromJSON(String filename) {
    clearAllPlayers();
    JSONArray players = loadJSONArray(filename);
    for (int i = 0; i < players.size(); i++) {
      JSONObject player = players.getJSONObject(i);
      allPlayers.add(new Player(player));
    }
  }
  
  void changePlayerStat(Player p, String s, float d) {
    switch(s) {
      case "competence":   p.competence += d;   return;
      case "smartassery":  p.smartassery += d;  return;
      case "yeetness":     p.yeetness += d;     return;
      case "trigonometry": p.trigonometry += d; return;
      case "bisexuality":  p.bisexuality += d;  return;
      case "asexuality":   p.asexuality += d;   return;
      case "scrappiness":  p.scrappiness += d;  return;
      case "charisma":     p.charisma += d;     return;
      case "autism":       p.autism += d;       return;
      default: return;
    }
  }
  
  void applyMod(Player p, Mod m) { p.mods.add(m); }
  void removeMod(Player p, Mod m) { p.mods.remove(m); }
  
  void appendSuffix(Player p, String s) { p.suffixes.append(s); }
  void removeSuffix(Player p, String s) {
    for (int i = 0; i < p.suffixes.size(); i++) {
      if (p.suffixes.get(i) == s) p.suffixes.remove(i);
      return;
    }
  }
  
  void giveSins(Player p, int s) { p.networth += s; }
  
  void killPlayer(Player p) {
    livePlayers.remove(p);
    deadPlayers.add(p);
  }
  void erasePlayer(Player p) {
    livePlayers.remove(p);
    erasedPlayers.add(p);
  }
  
  Player getPlayer(String id) {
    for (Player p : allPlayers) if (p.id == id) return p;
    return null;
  }
  
  ArrayList<Player> chooseRandomLivingPlayers(int num) {
    ArrayList<Player> unchosenPlayers = new ArrayList<Player>(livePlayers);
    if (num >= livePlayers.size()) return unchosenPlayers;
    
    ArrayList<Player> chosenPlayers = new ArrayList<Player>();
    for (int i = 0; i < num; i++) {
      int idx = int(random(unchosenPlayers.size()));
      Player p = unchosenPlayers.get(idx);
      chosenPlayers.add(p);
      unchosenPlayers.remove(p);
    }
    return chosenPlayers;
  }
  
  ArrayList<Player> chooseRandomAllPlayers(int num) {
    ArrayList<Player> unchosenPlayers = new ArrayList<Player>(allPlayers);
    if (num >= livePlayers.size()) return unchosenPlayers;
    
    ArrayList<Player> chosenPlayers = new ArrayList<Player>();
    for (int i = 0; i < num; i++) {
      int idx = int(random(unchosenPlayers.size()));
      Player p = unchosenPlayers.get(idx);
      chosenPlayers.add(p);
      unchosenPlayers.remove(p);
    }
    return chosenPlayers;
  }
  
  void entanglePlayers(Player a, Player b) {
    entangledPlayers.add(new StringList(a.id, b.id));
    a.mods.add(Mod.ENTANGLED);
    b.mods.add(Mod.ENTANGLED);
  }
  void detanglePlayer(Player p) {
    for (StringList sl : entangledPlayers) {
      if (sl.hasValue(p.id)) {
        entangledPlayers.remove(sl);
        return;
      }
    }
  }
  Player entangledWith(Player p) {
    for (StringList sl : entangledPlayers) {
      if (sl.get(0) == p.id) return getPlayer(sl.get(1));
      else if (sl.get(1) == p.id) return getPlayer(sl.get(0));
    }
    return null;
  }
  
  void poisonPlayer(Player p, int c) {
    p.competence -= 4;
    p.yeetness -= 2;
    p.trigonometry -= 2;
    poisonCounters.set(p.id, c);
    p.mods.add(Mod.POISONED);
  }
  void unpoisonPlayer(Player p) {
    p.competence += 4;
    p.yeetness += 2;
    p.trigonometry += 2;
    p.mods.remove(Mod.POISONED);
  }
  
  boolean hasRich() { return bourgeoisie().size() > 0; }
  ArrayList<Player> bourgeoisie() {
    int tooRich = 500000;
    ArrayList<Player> rich = new ArrayList<Player>();
    for (Player p : livePlayers) if (p.networth >= tooRich) rich.add(p);
    return rich;
  }
}
