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
