class EventDisplayer {
  int x, y, w, h;
  int margin = 10;
  int bgCol = 50;
  int strokeCol = 0;
  int textCol = 255;
  int textSize = 36;
  int textLeading = 40;

  EventDisplayer(int _x, int _y, int _w, int _h) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
  }

  void display() {
    fill(bgCol);
    stroke(strokeCol);
    rect(x, y, w, h);

    String text = feed.lastEvent().toText();

    fill(textCol);
    textAlign(LEFT);
    textSize(textSize);
    textLeading(textLeading);
    text(text, x+margin, y+margin, w-2*margin, h-2*margin);
  }
}
