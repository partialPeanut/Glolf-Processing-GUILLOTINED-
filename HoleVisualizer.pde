class HoleVisualizer {
  int x, y, w, h;
  int margin = 10;
  int bgCol = 50;
  int strokeCol = 0;
  int pointCol = 150;
  
  float maxLength = 2000;
  float maxPar = 20;

  HoleVisualizer(int _x, int _y, int _w, int _h) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
  }
  
  void setPlayState(PlayState ps) {}

  void display() {
    fill(bgCol);
    stroke(strokeCol);
    rect(x, y, w, h);
    
    stroke(pointCol);
    strokeWeight(4);
    for (HashMap.Entry me : sizeAndRealPar.entrySet()) {
      float len = (float)me.getKey();
      float par = (float)me.getValue();
      point(x+margin + (w-2*margin) * len/maxLength, y+h-margin - (h-2*margin) * par/maxPar);
    }
    strokeWeight(1);
  }
}
