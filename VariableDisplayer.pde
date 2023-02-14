class VariableDisplayer {
  DisplayType type;
  TourneyManager tourneyManager;
  Player hoveredPlayer = null;
  Player selectedPlayer = null;

  int x, y, w, h;
  int margin = 10;
  int offset = 4;

  int staticDisplayHeight = 80;
  color staticBgCol = color(50);
  color staticStrokeCol = color(255, 0, 0);
  color staticTextCol = color(255, 0, 0);

  color bgCol = 50;
  color strokeCol = 0;
  color textCol = 255;
  color inactiveTextCol = 160;
  color hoveredTextCol = color(160, 160, 255);
  color selectedTextCol = color(100, 100, 255);
  color inactiveSelectedTextCol = color(80, 80, 140);
  int textSize = 36;

  int varDisplayY, varDisplayH;

  String statsPlaceholder = "---";
  int statsTextLeading = 40;

  String scorePlaceholder = "-";
  int playerListUnitHeight = 48;
  int playerListUnitOffset = 12;
  int playerListTotalHeight;
  float listScrollOffset = 0;
  int scrollSpeed = 60;

  ButtonChangeVarDisplay[] displayChangeButtons = new ButtonChangeVarDisplay[4];
  int varDisButtonY;
  int varDisButtonH = 40;

  VariableDisplayer(TourneyManager tm, int _x, int _y, int _w, int _h) {
    type = DisplayType.PLAYER_STATS;
    tourneyManager = tm;

    x = _x;
    y = _y;
    w = _w;
    h = _h;

    varDisplayY = y+staticDisplayHeight+margin;
    varDisplayH = h - staticDisplayHeight - varDisButtonH - margin;

    varDisButtonY = y+h - varDisButtonH;

    displayChangeButtons[0] = new ButtonChangeVarDisplay("Player", DisplayType.PLAYER_STATS, x, varDisButtonY, w/4, varDisButtonH);
    displayChangeButtons[1] = new ButtonChangeVarDisplay("Course", DisplayType.COURSE_STATS, x+w/4, varDisButtonY, w/4, varDisButtonH);
    displayChangeButtons[2] = new ButtonChangeVarDisplay("Strokes", DisplayType.HOLE_SCORES, x+2*w/4, varDisButtonY, w/4, varDisButtonH);
    displayChangeButtons[3] = new ButtonChangeVarDisplay("Standings", DisplayType.TOURNEY_SCORES, x+3*w/4, varDisButtonY, w/4, varDisButtonH);

    displayChangeButtons[0].activate();
  }

  void changeType(DisplayType dt) { type = dt; }
  int getPlayerListHeight() { return getHoleControl().balls.size() * playerListUnitHeight - varDisplayH; }
  
  HoleControl getHoleControl() { return tourneyManager.holeControl; }
  Player getCurrentPlayer() { return tourneyManager.currentPlayer(); }

  void scroll(float amount) {
    listScrollOffset = constrain(listScrollOffset-amount*scrollSpeed, -getPlayerListHeight(), 0);
  }

  void display() {
    // Static display box
    fill(staticBgCol);
    stroke(staticStrokeCol);
    strokeWeight(2);
    rectMode(CORNER);
    rect(x, y, w, staticDisplayHeight);

    // Static display text
    fill(staticTextCol);
    textSize(textSize);
    textAlign(LEFT, CENTER);
    text(nameOf(getCurrentPlayer()), x+margin, y+staticDisplayHeight/2-offset);
    textAlign(RIGHT, CENTER);
    text(strokeOf(getCurrentPlayer()), x+w-margin, y+staticDisplayHeight/2-offset);

    // Var display box
    fill(bgCol);
    stroke(strokeCol);
    rect(x, varDisplayY, w, varDisplayH);

    // Var display buttons
    for (Button b : displayChangeButtons) b.display();

    // Var display contents
    clip(x, varDisplayY, w, varDisplayH);
    switch(type) {
    case PLAYER_STATS:
    case COURSE_STATS:
      displayStats();
      break;
    case HOLE_SCORES:
    case TOURNEY_SCORES:
      displayScores();
      break;
    }
    noClip();
  }

  void displayStats() {
    String text = statsPlaceholder;
    if (type == DisplayType.PLAYER_STATS) text = playerToText(selectedPlayer == null ? getCurrentPlayer() : selectedPlayer);
    if (type == DisplayType.COURSE_STATS) {
      text = courseToText(tourneyManager.tourney,getHoleControl().hole);
      stroke(textCol);
      line(x+margin*2, varDisplayY+104, x+w-margin*2, varDisplayY+104);
    }

    fill(textCol);
    textAlign(LEFT);
    textSize(textSize);
    textLeading(statsTextLeading);
    text(text, x+margin, varDisplayY+margin, w-2*margin, varDisplayH-2*margin);
  }

  void displayScores() {
    line(x, varDisplayY+listScrollOffset, x+w, varDisplayY+listScrollOffset);

    IntDict scores;
    switch(type) {
      case HOLE_SCORES:
        scores = getHoleControl().playersAndStrokes();
        break;
      case TOURNEY_SCORES:
        scores = tourneyManager.playersByScores();
        break;
      default:
        scores = null;
    }

    int i = 1;
    for (String id : scores.keys()) {
      int scoreInt = scores.get(id);
      
      if (scoreInt < 0) {
        if (scoreInt < 0) scoreInt *= -1;
        
        if (selectedPlayer != null && id == selectedPlayer.id) fill(inactiveSelectedTextCol);
        else if (hoveredPlayer != null && id == hoveredPlayer.id) fill(hoveredTextCol);
        else fill(inactiveTextCol);
      }
      else if (id == getCurrentPlayer().id) fill(staticTextCol);
      else if (selectedPlayer != null && id == selectedPlayer.id) fill(selectedTextCol);
      else if (hoveredPlayer != null && id == hoveredPlayer.id) fill(hoveredTextCol);
      else fill(textCol);
      
      String score = null;
      switch(type) {
        case HOLE_SCORES:
          score = strokeOf(scoreInt);
          break;
        case TOURNEY_SCORES:
          score = scoreOf(scoreInt);
          break;
        default:
          scores = null;
      }
      
      float blockY = varDisplayY+listScrollOffset+i*playerListUnitHeight;

      textSize(textSize);
      textAlign(LEFT, BOTTOM);
      text(nameOf(id), x+margin, blockY+margin-playerListUnitOffset);
      textAlign(RIGHT, BOTTOM);
      text(score, x+w-margin, blockY+margin-playerListUnitOffset);
      
      if (mouseX >= x && mouseX <= x+w && mouseY >= blockY-playerListUnitHeight && mouseY <= blockY) {
        hoveredPlayer = playerManager.getPlayer(id);
      }

      strokeWeight(2);
      stroke(0);
      line(x, blockY, x+w, blockY);

      i++;
    }
  }
  
  void dehover() { hoveredPlayer = null; }
  
  void selectPlayer() {
    if (selectedPlayer == hoveredPlayer) selectedPlayer = null;
    else selectedPlayer = hoveredPlayer;
  }

  String nameOf(Player player) { return Format.playerToName(player); }
  String nameOf(String id) { return nameOf(playerManager.getPlayer(id)); }

  String strokeOf(int strokes) { return Format.intToStrokes(strokes); }
  String strokeOf(Player player) { return strokeOf(getHoleControl().currentStrokeOf(player)); }

  String scoreOf(int score) { return Format.intToScore(score); }

  String playerToText(Player player) {
    if (player == null) return statsPlaceholder;
    else return 
      "Name: " + player.firstName + " " + player.lastName +
      "\nGender: " + player.gender +
      "\nNet Worth: " + nfc(player.networth) + " $ins" +
      "\nCringe: " + player.cringe +
      "\nDumbassery: " + player.dumbassery +
      "\nYeetness: " + player.yeetness +
      "\nTrigonometry: " + player.trigonometry +
      "\nBisexuality: " + player.bisexuality +
      "\nAsexuality: " + player.asexuality +
      "\nScrappiness: " + player.scrappiness +
      "\nCharisma: " + player.charisma +
      "\nAutism: " + player.autism;
  }

  String courseToText(Tourney tourney,Hole hole) {
    if (tourney == null || hole == null) return statsPlaceholder;
    else return
      tourney.tourneyName +
      "\nPrize: " + nfc(tourney.prizeMoney) + " $ins" +
      "\n" +
      "\nCurrent Hole" +
      "\nPar: " + hole.par +
      "\nRoughness: " + hole.roughness +
      "\nHeterosexuality: " + hole.heterosexuality +
      "\nThicc: " + hole.thicc +
      "\nVerdancy: " + hole.verdancy +
      "\nObedience: " + hole.obedience +
      "\nQuench: " + hole.quench +
      "\nThirst: " + hole.thirst;
  }
  
  boolean isOverInfo() {
    return mouseX >= x && mouseX <= x+w && mouseY >= varDisplayY && mouseY <= varDisplayY+varDisplayH;
  }
}
