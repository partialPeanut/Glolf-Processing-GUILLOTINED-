class Button {
  int x, y, w, h;
  color bgCol = 225;
  color strokeCol = 0;
  color textCol = 0;
  String text;

  Button(String t, int _x, int _y, int _w, int _h) {
    text = t;
    x = _x;
    y = _y;
    w = _w;
    h = _h;
  }

  Button(String t, int _x, int _y, int _w, int _h, int mar, int idx) {
    text = t;
    x = _x + idx * (_w + mar);
    y = _y;
    w = _w;
    h = _h;
  }

  void display() {
    fill(bgCol);
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

  void onClick() {
  }
}



class ButtonNextEvent extends Button {
  ButtonNextEvent(String t, int _x, int _y, int _w, int _h, int _m, int _i) {
    super(t, _x, _y, _w, _h, _m, _i);
  }

  void onClick() {
    if (feed.lastEvent() instanceof EventTourneyFinish) exit();
    tourneyManager.nextEvent();
  }
}



class ButtonGeneratePlayer extends Button {
  ButtonGeneratePlayer(String t, int _x, int _y, int _w, int _h) {
    super(t, _x, _y, _w, _h);
  }

  void onClick() {
    playerManager.addNewPlayer();
  }
}



class ButtonSavePlayers extends Button {
  ButtonSavePlayers(String t, int _x, int _y, int _w, int _h) {
    super(t, _x, _y, _w, _h);
  }
  ButtonSavePlayers(String t, int _x, int _y, int _w, int _h, int _m, int _i) {
    super(t, _x, _y, _w, _h, _m, _i);
  }

  void onClick() {
    playerManager.savePlayersToJSON();
  }
}



class ButtonGirl extends Button {
  ButtonGirl(String t, int _x, int _y, int _w, int _h, int _m, int _i) {
    super(t, _x, _y, _w, _h, _m, _i);
  }
  void onClick() {
    println("Mauuuuu <- that's 'I love my geef' in kitty cat <333");
  }
}



class ButtonChangeVarDisplay extends Button {
  DisplayType displayType;
  boolean active = false;

  color activeBgCol = 50;
  color activeTextCol = 255;
  color inactiveBgCol = 225;
  color inactiveTextCol = 0;

  ButtonChangeVarDisplay(String t, DisplayType dt, int _x, int _y, int _w, int _h) {
    super(t, _x, _y, _w, _h);
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
