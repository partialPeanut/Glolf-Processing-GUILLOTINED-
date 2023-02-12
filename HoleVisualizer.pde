class HoleVisualizer {
  PlayState prevState = null;
  PlayState currState = null;

  int x, y, w, h;
  int margin = 10;
  int bgCol = 50;
  int strokeCol = 0;
  int textCol = 255;
  int textSize = 48;
  int textLeading = 40;

  HoleVisualizer(int _x, int _y, int _w, int _h) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
  }
  
  void setPlayState(PlayState ps) {
    if (currState == null) {
      currState = ps;
      return;
    }
    
    if (currState.ball.player == ps.ball.player) {
      prevState = currState;
      currState = ps;
    }
    else {
      currState = ps;
      prevState = null;
    }
  }

  void display() {
    fill(bgCol);
    stroke(strokeCol);
    rect(x, y, w, h);
    
    String text = "";
    if (prevState == null) text = "About to make a shot!!";
    else {
      text = "Just shot it.";
    }
    if (currState == null) return;
    
    text += "\n" + currState.ball.distance + " gallons from hole.";
    
    fill(textCol);
    textAlign(CENTER,CENTER);
    textSize(textSize);
    textLeading(textLeading);
    text(text, x+w/2, y+h/2);
  }
}
