class Ball {
  Player player;
  int stroke;
  boolean sunk;
  boolean past;
  float distance;
  Terrain terrain;
  color col;

  Ball(Player p, float dist) {
    player = p;
    stroke = 0;
    sunk = false;
    past = false;
    distance = dist;
    terrain = Terrain.TEE;
  }
  
  Ball(Ball b) { set(b); }
  void set(Ball b) {
    player = b.player;
    stroke = b.stroke;
    sunk = b.sunk;
    past = b.past;
    distance = b.distance;
    terrain = b.terrain;
  }
  
  Ball(Ball b, Player p) {
    set(b);
    player = p;
  }
  
  void sunk() { sunk = true; }
  void unsunk() { sunk = false; }
  
  void teleportTo(Ball b) {
    sunk = b.sunk;
    past = b.past;
    distance = b.distance;
    terrain = b.terrain;
  }
}
