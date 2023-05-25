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
  color staticStrokeCol = #ffa666;
  color staticTextCol = #ffa666;

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
  int getPlayerListHeight() { return tourneyManager.tourney.players.size() * playerListUnitHeight - varDisplayH; }
  
  HoleControl getHoleControl() { return tourneyManager.holeControl; }
  Player getCurrentPlayer() { return tourneyManager.currentPlayer(); }

  void scroll(float amount) {
    listScrollOffset = constrain(listScrollOffset+amount*scrollSpeed, 0, max(0,getPlayerListHeight()));
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
    if (type == DisplayType.PLAYER_STATS) {
      text = playerToText(selectedPlayer == null ? getCurrentPlayer() : selectedPlayer);
    }
    if (type == DisplayType.COURSE_STATS) {
      text = courseToText(tourneyManager.tourney,getHoleControl().hole);
      stroke(textCol);
      line(x+margin*2, varDisplayY+182, x+w-margin*2, varDisplayY+182);
    }

    fill(textCol);
    textAlign(LEFT);
    textSize(textSize);
    textLeading(statsTextLeading);
    text(text, x+margin, varDisplayY+margin, w-2*margin, varDisplayH-2*margin);
  }

  void displayScores() {
    line(x, varDisplayY-listScrollOffset, x+w, varDisplayY-listScrollOffset);

    IntDict scores;
    switch(type) {
      case HOLE_SCORES:
        scores = feed.lastEvent().playState().playersAndStrokes();
        break;
      case TOURNEY_SCORES:
        scores = tourneyManager.playersByScores();
        break;
      default:
        scores = null;
    }
    
    if (scores == null) return;

    int i = 1;
    for (String id : scores.keys()) {
      int scoreInt = scores.get(id);
      
      if (scoreInt < 0) {
        if (scoreInt < 0) scoreInt *= -1;
        
        if (selectedPlayer != null && id == selectedPlayer.id) fill(inactiveSelectedTextCol);
        else if (hoveredPlayer != null && id == hoveredPlayer.id) fill(hoveredTextCol);
        else fill(inactiveTextCol);
      }
      else if (selectedPlayer != null && id == selectedPlayer.id) fill(selectedTextCol);
      else if (hoveredPlayer != null && id == hoveredPlayer.id) fill(hoveredTextCol);
      else if (getCurrentPlayer() != null && id == getCurrentPlayer().id) fill(staticTextCol);
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
      
      float blockY = varDisplayY-listScrollOffset+i*playerListUnitHeight;

      textSize(textSize);
      textAlign(LEFT, BOTTOM);
      text(nameOf(id), x+margin, blockY+margin-playerListUnitOffset);
      textAlign(RIGHT, BOTTOM);
      text(score, x+w-margin, blockY+margin-playerListUnitOffset);
      
      if (mouseX >= x && mouseX <= x+w && mouseY >= blockY-playerListUnitHeight && mouseY <= blockY && isOverInfo()) {
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
    switch(type) {
      case PLAYER_STATS:
      case COURSE_STATS:
        return;
      default: break;
    }
    
    if (selectedPlayer == hoveredPlayer) selectedPlayer = null;
    else selectedPlayer = hoveredPlayer;
  }

  String nameOf(Player player) { return Format.playerToName(player); }
  String nameOf(String id) { return nameOf(playerManager.getPlayer(id)); }

  String strokeOf(int strokes) { return Format.intToStrokes(strokes); }
  String strokeOf(Player player) { return strokeOf(feed.lastEvent().playState().currentStrokeOf(player)); }

  String scoreOf(int score) { return Format.intToScore(score); }

  String playerToText(Player player) {
    if (player == null) return statsPlaceholder;
    else return 
      "Name: " + Format.playerToName(player) +
      "\nGender: " + player.gender +
      "\nMods: " + Format.modsToBrief(player.mods) + 
      "\nNet Worth: " + nfc(player.networth) + " $ins" +
      "\nCompetence: " + player.competence +
      "\nSmartassery: " + player.smartassery +
      "\nYeetness: " + player.yeetness +
      "\nTrigonometry: " + player.trigonometry +
      "\nBisexuality: " + player.bisexuality +
      "\nAsexuality: " + player.asexuality +
      "\nScrappiness: " + player.scrappiness +
      "\nCharisma: " + player.charisma +
      "\nAutism: " + player.autism;
  }

  String courseToText(Tourney tourney, Hole hole) {
    if (tourney == null || hole == null) return statsPlaceholder;
    else return
      tourney.tourneyName +
      "\nPrize: " + nfc(tourney.prizeMoney) + " $ins" +
      "\nWeather: " + tourney.weather.name +
      "\nMods: " + Format.modsToBrief(tourney.mods) +
      "\n" +
      "\nHole " + (tourney.holes.indexOf(hole)+1) + " of " + tourney.holes.size() +
      "\nPar: " + hole.par +
      "\nWildlife: " + hole.wildlife.name +
      "\nMods: " + Format.modsToBrief(hole.mods) +
      (hole.succblow < 0 ? "\nSucc: " : "\nBlow: ") + abs(hole.succblow) +
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

class HoleDisplayer {
  Hole hole = null;
  
  int holePoint, teePoint;
  float totalLength;
  FloatList roughHeights = new FloatList();
  FloatList greenHeights = new FloatList();
  FloatList pastHeights = new FloatList();

  int x, y, w, h;
  int margin = 10;
  
  Button[] butts = new Button[3];
  float buttonSize = 240;
  
  int scaleY; // Y position of the scale
  int scaleDist = 100; // Amount of gallons per tick
  int scaleHeight = 30; // Height of scale ticks
  
  int windArrowY; // Y position of the wind arrows
  int windArrowLength = 40; // Length of one wind arrow
  int windArrowHeight = 15; // Height of wind arrows
  
  int tempestArrowHeight = 30; // Height of tempest swap indicator arrows
  int tempestArrowMargin = 10; // Space between markers and tempest arrows
  
  int terrainY; // Y position of the middle of the terrain
  int greenSlope = 20; // "Run-up" for terrain-green transition
  float noiseScale = 0.01; // Roughness of rough
  float noiseBase = 30; // Height of roughness
  float gravity = 0.004; // Height of stroke arc (lower = smaller)
  
  float teeHeight = 10; // Height of the tee icon
  float teeWidth = 10; // Width of the tee icon
  float flagpoleHeight = 90; // Height of the flagpole
  float flagHeight = 30; // Height of the flag
  float flagWidth = 30; // Width of the flag
  float ballMarkHeight; // Height of the ball markers
  float crossSize = 30; // Width and height of the out-of-bounds X
  
  int bgCol = 50;
  int strokeCol = 0;
  int textCol = 255;
  int textSize = 48;
  int textLeading = 40;
  
  color staticColor = #ffa666; // Color of the currently glolfing player
  color flagFill = color(220, 0, 0); // Flag fill
  color flagStroke = color(255, 0, 0); // Flag stroke
  color defaultBallMarkColor = color(120, 120); // Default ball mark
  color arcColor = #7fffa666; // Color of the stroke arc
  
  color knockedColor = #C70039; // Color when a ball is knocked away

  HoleDisplayer(int _x, int _y, int _w, int _h) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    
    butts[0] = new Button("R", "restart", x+w/2-margin-3*buttonSize/2, y+h/2-buttonSize/2, buttonSize, buttonSize);
    butts[1] = new Button("C", "continue", x+w/2-buttonSize/2, y+h/2-buttonSize/2, buttonSize, buttonSize);
    butts[2] = new Button("X", "exit", x+w/2+margin+buttonSize/2, y+h/2-buttonSize/2, buttonSize, buttonSize);
    
    terrainY = int(0.6*h);
    scaleY = int(terrainY+noiseBase+scaleHeight);
    windArrowY = int(scaleY+windArrowHeight+60);
    ballMarkHeight = noiseBase + 10;
  }
  
  void setHole(Hole h) {
    if (h == null) {
      hole = null;
      return;
    }
    
    roughHeights.clear();
    greenHeights.clear();
    pastHeights.clear();
    
    hole = h;
    float roughLength = max(100, 50 + hole.realLength - hole.greenLength);
    float pastLength = 100;
    totalLength = roughLength + 2*hole.greenLength + 100;
    if (totalLength < 450) {
      pastLength += 450 - totalLength;
      totalLength = 450;
    }
    float holePosition = roughLength + hole.greenLength;
    float teePosition = holePosition - hole.realLength;
    
    int roughStart = margin;
    int greenStart = int((w-2*margin)*roughLength/totalLength);
    int greenEnd = int((w-2*margin)*(roughLength + 2*hole.greenLength)/totalLength);
    int pastEnd = w-margin;
    
    holePoint = int((w-2*margin)*holePosition/totalLength);
    teePoint = int((w-2*margin)*teePosition/totalLength);
    
    for (int i = roughStart; i < greenStart; i++) {
      roughHeights.append((noise(i*noiseScale)-0.5)*hole.roughness*noiseBase);
    }
    for (int i = greenEnd; i < pastEnd; i++) {
      pastHeights.append((noise(i*noiseScale)-0.5)*hole.roughness*noiseBase);
    }
    
    float greenBegin = roughHeights.get(roughHeights.size()-1);
    float greenFinish = pastHeights.get(0);
    for (int i = 0; i < greenSlope; i++) {
      greenHeights.append(sq(greenSlope-i)*greenBegin/sq(greenSlope));
    }
    greenHeights.append(new float[greenEnd-greenStart-2*greenSlope]);
    for (int i = 0; i < greenSlope; i++) {
      greenHeights.append(sq(i)*greenFinish/sq(greenSlope));
    }
  }

  void display() {
    fill(bgCol);
    stroke(strokeCol);
    rect(x, y, w, h);
    
    if (feed.lastEvent() instanceof EventTourneyConclude) {
      displayTourneyContinue();
      return;
    }
    else if (hole == null) {
      fill(textCol);
      textAlign(CENTER,CENTER);
      textSize(textSize);
      text("---", x+w/2, y+h/2);
      return;
    }
    
    for (Button b : butts) b.disable();
    displayHoleVisualizerReal();
  }
  
  void displayTourneyContinue() {
    for (Button b : butts) {
      b.enable();
      b.display();
    }
  }
  
  color determineBallColor(Ball b) {
    ArrayList<Ball> bs = new ArrayList<Ball>();
    bs.add(b);
    return combineBallColors(bs);
  }
  
  color combineBallColors(ArrayList<Ball> balls) {
    GlolfEvent lastEvent = feed.lastEvent();
    color[] prioList = {
      staticColor,
      Weather.TEMPEST.col,
      Weather.MIRAGE.col,
      knockedColor,
      variableDisplayer.hoveredTextCol,
      variableDisplayer.selectedTextCol
    };
    
    int prio = -1;
    for (Ball b : balls) {
      if (b.player == variableDisplayer.selectedPlayer) prio = max(prio, 5);
      else if (b.player == variableDisplayer.hoveredPlayer) prio = max(prio, 4);
      else if (lastEvent instanceof EventAggression) {
        EventAggression ea = (EventAggression)lastEvent;
        if (b.player == ea.knockedPlayer) prio = max(prio, 3);
      }
      else if (lastEvent instanceof EventMirageSwap) {
        EventMirageSwap ems = (EventMirageSwap)lastEvent;
        if (b.player == ems.playerA || b.player == ems.playerB) prio = max(prio, 2);
      }
      else if (lastEvent instanceof EventTempestSwap) {
        EventTempestSwap ets = (EventTempestSwap)lastEvent;
        if (b.player == ets.playerA || b.player == ets.playerB) prio = max(prio, 1);
      }
      else if (b == lastEvent.playState().currentBall) prio = max(prio, 0);
    }
    
    if (prio == -1) return color(0,0);
    else return prioList[prio];
  }
  
  color combineBallColors(ArrayList<Ball> balls, color def) {
    return combineBallColors(balls) == color(0,0) ? def : combineBallColors(balls);
  }
   
  void displayHoleVisualizerReal() {
    strokeWeight(4);
    clip(x,y,w,h);
    
    GlolfEvent lastEvent = feed.lastEvent();
    Ball currentBall = lastEvent.playState().currentBall;
    ArrayList<Ball> balls = lastEvent.playState().balls;
    
    // Draw scale
    stroke(255);
    line(x+margin, y+scaleY, x+w-2*margin, y+scaleY);
    int currDist = 0;
    int currPoint = teePoint;
    while (currPoint < w-2*margin) {
      line(x+margin+currPoint, y+scaleY, x+margin+currPoint, y+scaleY-scaleHeight);
      currDist += 100;
      currPoint = teePoint + int((w-2*margin)*currDist/totalLength);
    }
    
    // Draw wind
    int numArrows = int(hole.succblow * 100);
    float lastEnd = x+w/2;
    if (numArrows < 0) {
      stroke(255,0,0);
      for (int i = 0; i < -numArrows; i++) {
        drawHorizArrow(lastEnd, lastEnd - windArrowLength, y+windArrowY, windArrowHeight);
        lastEnd -= windArrowLength + margin;
      }
    }
    else {
      stroke(0,0,255);
      for (int i = 0; i < numArrows; i++) {
        drawHorizArrow(lastEnd, lastEnd + windArrowLength, y+windArrowY, windArrowHeight);
        lastEnd += windArrowLength + margin;
      }
    }
    
    // Draw the terrain
    int iT = 0;
    noFill();
    
    stroke(Terrain.ROUGH.tColor);
    beginShape();
    for (float f : roughHeights) {
      curveVertex(x+margin+iT, y+terrainY+f);
      iT++;
    }
    endShape();
    
    stroke(Terrain.GREEN.tColor);
    beginShape();
    for (float f : greenHeights) {
      curveVertex(x+margin+iT, y+terrainY+f);
      iT++;
    }
    endShape();
    
    stroke(Terrain.ROUGH.tColor);
    beginShape();
    for (float f : pastHeights) {
      curveVertex(x+margin+iT, y+terrainY+f);
      iT++;
    }
    endShape();
    
    // Select flagpole color
    color flagpoleColor = color(Terrain.HOLE.tColor);
    if (currentBall.sunk) flagpoleColor = staticColor;
    else if (ballOf(variableDisplayer.selectedPlayer) != null && ballOf(variableDisplayer.selectedPlayer).sunk) flagpoleColor = variableDisplayer.inactiveSelectedTextCol;
    else if (ballOf(variableDisplayer.hoveredPlayer) != null && ballOf(variableDisplayer.hoveredPlayer).sunk) flagpoleColor = variableDisplayer.hoveredTextCol;
    
    // Draw the flagpole
    stroke(flagpoleColor);
    line(x+margin+holePoint, y+terrainY, x+margin+holePoint, y+terrainY-flagpoleHeight);
    fill(flagFill);
    stroke(flagStroke);
    triangle(x+margin+holePoint, y+terrainY-flagpoleHeight,
             x+margin+holePoint, y+terrainY-flagpoleHeight+flagHeight,
             x+margin+holePoint-flagWidth, y+terrainY-flagpoleHeight+flagHeight/2);
    
    // Choose ball colors
    for (Ball b : balls) {
      b.col = determineBallColor(b);
    }
    
    // Draw the ball markers
    for (Ball b : balls) {
      int pixDist = int((w-2*margin)*b.distance/totalLength);
      int ballPoint = b.past ? holePoint + pixDist : holePoint - pixDist;
      
      color ballMarkColor = b.col == color(0,0) ? defaultBallMarkColor : b.col;
      stroke(ballMarkColor);
      if (!b.sunk && b.terrain != Terrain.TEE) line(x+margin+ballPoint, y+terrainY-ballMarkHeight/2, x+margin+ballPoint, y+terrainY+ballMarkHeight/2);
      
      // Draws swap arrows for tempest weather
      if (lastEvent instanceof EventTempestSwap) {
        EventTempestSwap ets = (EventTempestSwap)lastEvent;
        if (b.player == ets.playerA || b.player == ets.playerB) {
          float relDistThis = b.past ? b.distance : -b.distance;
          Ball ballOther = b.player == ets.playerA ? ballOf(ets.playerB) : ballOf(ets.playerA);
          float relDistOther = ballOther.past ? ballOther.distance : -ballOther.distance;
          int pixRelDist = int((w-2*margin)*(relDistThis-relDistOther)/totalLength);
          
          int flip = relDistThis < relDistOther ? 1 : -1;
          if (relDistThis == relDistOther) flip = b.player == ets.playerA ? 1 : -1;
          
          stroke(Weather.TEMPEST.col);
          if (abs(pixRelDist) < tempestArrowHeight + 3*tempestArrowMargin) {
            line(x+margin+ballPoint - flip*tempestArrowMargin, y+terrainY-tempestArrowHeight/2, x+margin+ballPoint - flip*tempestArrowMargin, y+terrainY+tempestArrowHeight/2);
            line(x+margin+ballPoint - flip*tempestArrowMargin, y+terrainY, x+margin+ballPoint - flip*(tempestArrowMargin+tempestArrowHeight/2), y+terrainY+tempestArrowHeight/2);
            line(x+margin+ballPoint - flip*tempestArrowMargin, y+terrainY, x+margin+ballPoint - flip*(tempestArrowMargin+tempestArrowHeight/2), y+terrainY-tempestArrowHeight/2);
          }
          else {
            line(x+margin+ballPoint + flip*tempestArrowMargin, y+terrainY, x+margin+ballPoint + flip*(tempestArrowMargin+tempestArrowHeight/2), y+terrainY+tempestArrowHeight/2);
            line(x+margin+ballPoint + flip*tempestArrowMargin, y+terrainY, x+margin+ballPoint + flip*(tempestArrowMargin+tempestArrowHeight/2), y+terrainY-tempestArrowHeight/2);
            if (flip == 1) line(x+margin+ballPoint + tempestArrowMargin, y+terrainY, x+margin+ballPoint + abs(pixRelDist) - tempestArrowMargin, y+terrainY);
          }
        }
      }
    }
    
    // Draws arc
    if (lastEvent instanceof EventStrokeOutcome) {
      EventStrokeOutcome eso = (EventStrokeOutcome)lastEvent;
      
      float angle = PI/18;
      switch(eso.strokeType) {
        case TEE:
          angle = PI/4;
          break;
        case DRIVE:
          angle = PI/5;
          break;
        case APPROACH:
          angle = PI/6;
          break;
        case CHIP:
          angle = PI/3;
          break;
        case PUTT:
          angle = PI/8;
          break;
        case NOTHING:
        default:
          break;
      }
      
      int flip = eso.distance > eso.fromDistance && !eso.toTerrain.outOfBounds ? -1 : 1;
      int startDist = flip * int((w-2*margin)*eso.fromDistance/totalLength);
      int startPoint = ballOf(eso.player).past ? holePoint + startDist : holePoint - startDist;
      
      int flipOob = ballOf(eso.player).past ? 1 : -1;
      float sentDistance = eso.toTerrain.outOfBounds ? flip*eso.fromDistance + flipOob*eso.distance : eso.toDistance;
      int endDist = int((w-2*margin)*sentDistance/totalLength);
      int endPoint = ballOf(eso.player).past ? holePoint + endDist : holePoint - endDist;
      
      float startY = getHeight(startPoint);
      if (eso.fromTerrain == Terrain.TEE) startY -= teeHeight;
      float endY = getHeight(endPoint);
      
      stroke(arcColor);
      noFill();
      beginShape();
      vertex(x+margin+startPoint, y+terrainY+startY);
      quadraticVertex(x+margin+(startPoint+endPoint)/2, y+terrainY+startY-gravity*sq(endPoint-startPoint)*(2-sin(angle))/(8*sin(angle)),
                      x+margin+endPoint, y+terrainY+endY);
      endShape();
      
      // Draws cross
      if (eso.toTerrain.outOfBounds) {
        stroke(eso.toTerrain.tColor);
        line(x+margin+endPoint-crossSize/2, y+terrainY+endY-crossSize/2, x+margin+endPoint+crossSize/2, y+terrainY+endY+crossSize/2);
        line(x+margin+endPoint-crossSize/2, y+terrainY+endY+crossSize/2, x+margin+endPoint+crossSize/2, y+terrainY+endY-crossSize/2);
      }
    }
    
    // Choose the color of the tee
    ArrayList<Ball> teeBalls = new ArrayList<Ball>(balls);
    teeBalls.removeIf(b -> b.terrain != Terrain.TEE);
    color teeStroke = combineBallColors(teeBalls, Terrain.TEE.tColor);
        
    // Draw the tee
    float teeY = 0;
    if (teePoint < roughHeights.size()) teeY = roughHeights.get(teePoint);
    else teeY = greenHeights.get(teePoint-roughHeights.size());
    stroke(teeStroke);
    line(x+margin+teePoint, y+terrainY+teeY, x+margin+teePoint, y+terrainY+teeY-teeHeight);
    line(x+margin+teePoint-teeWidth/2, y+terrainY+teeY-teeHeight, x+margin+teePoint+teeWidth/2, y+terrainY+teeY-teeHeight);
    
    // Draws active ball marker
    int activePixDist = int((w-2*margin)*currentBall.distance/totalLength);
    int activeBallPoint = currentBall.past ? holePoint + activePixDist : holePoint - activePixDist;
    stroke(staticColor);
    if (!currentBall.sunk && currentBall.terrain != Terrain.TEE)
      line(x+margin+activeBallPoint, y+terrainY-ballMarkHeight/2, x+margin+activeBallPoint, y+terrainY+ballMarkHeight/2);
    
    strokeWeight(2);
    noClip();
  }
  
  void drawHorizArrow(float start, float end, float y, float arrowH) {
    line(start, y, end, y);
    float arrowX = start < end ? end - arrowH : end + arrowH;
    line(end, y, arrowX, y+arrowH);
    line(end, y, arrowX, y-arrowH);
  }
  
  float getHeight(int x) {
    if (x < 0) return 0;
    else if (x < roughHeights.size()) return roughHeights.get(x);
    else if (x < roughHeights.size() + greenHeights.size()) return greenHeights.get(x-roughHeights.size());
    else if (x < roughHeights.size() + greenHeights.size() + pastHeights.size()) return pastHeights.get(x-roughHeights.size()-greenHeights.size());
    else return 0;
  }
  
  Ball ballOf(Player p) { return feed.lastEvent().playState().ballOf(p); }
}
