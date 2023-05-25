class Button {
  float x, y, w, h;
  String text;
  String onClick;
  
  boolean selected = false;
  boolean enabled = true;
  
  color bgCol = 225;
  color pressedCol = 150;
  color unpressedCol = 225;
  color disabledCol = 150;
  color strokeCol = 0;
  color strokeSelected = #FF0000;
  color strokeDeselected = #000000;
  color textCol = 0;

  Button(String t, String oc, float _x, float _y, float _w, float _h) {
    text = t;
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    onClick = oc;
  }

  void display() {
    fill(bgCol);
    if (!enabled) fill(disabledCol);
    stroke(strokeCol);
    strokeWeight(2);
    rectMode(CORNER);
    rect(x, y, w, h);

    fill(textCol);
    textAlign(CENTER, CENTER);
    textSize(0.8*h);
    text(text, x+w/2, y+h/2);    
  }

  boolean isOver() {
    return mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h;
  }
  
  void select() { strokeCol = strokeSelected; }
  void deselect() { strokeCol = strokeDeselected; }
  
  void press() { bgCol = pressedCol; }
  void unpress() { bgCol = unpressedCol; }
  
  void enable() { enabled = true; }
  void disable() { enabled = false; }
}



class ButtonChangeVarDisplay extends Button {
  DisplayType displayType;
  boolean active = false;

  color activeBgCol = 50;
  color activeTextCol = 255;
  color inactiveBgCol = 225;
  color inactiveTextCol = 0;

  ButtonChangeVarDisplay(String t, DisplayType dt, int _x, int _y, int _w, int _h) {
    super(t, "", _x, _y, _w, _h);
    displayType = dt;
  }

  void onClick() {
    variableDisplayer.changeType(displayType);
    activate();
  }

  void activate() {
    bgCol = activeBgCol;
    textCol = activeTextCol;
  }
  void deactivate() {
    bgCol = inactiveBgCol;
    textCol = inactiveTextCol;
  }
}

class Feed {
  ArrayList<GlolfEvent> everyEvent = new ArrayList<GlolfEvent>();
  
  Feed() {
    everyEvent.add(new EventVoid());
  }
  
  void addEvent(GlolfEvent e) { everyEvent.add(e); }
  GlolfEvent lastEvent() { return everyEvent.get(everyEvent.size()-1); }
  GlolfEvent lastLastEvent() { return everyEvent.get(everyEvent.size()-2); }
  void removeLastEvent() { everyEvent.remove(lastEvent()); }
}

class Gradient {
  float x, y, w, h, r1, r2, p1, p2;
  Boolean linear = false;
  Boolean radial = false;
  color c;
  int n;
  
  Gradient(float _x, float _y, float _w, float _h, color _c) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    c = _c;
    linear = true;
  }
  
  Gradient(float _x, float _y, float _r1, float _r2, float _p1, float _p2, color _c) {
    x = _x;
    y = _y;
    r1 = _r1;
    r2 = _r2;
    p1 = _p1;
    p2 = _p2;
    c = _c;
    radial = true;
  }
  
  void display() {
    fill(c);
    noStroke();
    if (linear) rect(x, y, w, h);
    if (radial && p1 == 0 && p2 == TWO_PI) ellipse(x, y, r1, r2);
    if (radial && (p1 != 0 || p2 != TWO_PI)) arc(x, y, r1, r2, p1, p2);
  }
}
