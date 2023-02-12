class PlayerManager {
  int minID = 100000;
  int maxID = 999999;
  ArrayList<Player> allPlayers;

  PlayerManager() {
    allPlayers = new ArrayList<Player>();
  }

  Player getPlayer(String id) {
    for (Player p : allPlayers) {
      if (p.id == id) return p;
    }
    return null;
  }

  void clearAllPlayers() {
    allPlayers.clear();
  }

  void addNewPlayers(int num) {
    for (int i = 0; i < num; i++) {
      addNewPlayer();
    }
  }
  Player addNewPlayer() {
    Player newPlayer = new Player(generateNewID());
    allPlayers.add(newPlayer);
    return newPlayer;
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
}
