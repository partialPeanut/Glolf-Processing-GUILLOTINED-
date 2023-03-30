class HoleVisualizer {
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
  
  color staticColor = color(255,0,0); // Color of the currently glolfing player
  color flagFill = color(220, 0, 0); // Flag fill
  color flagStroke = color(255, 0, 0); // Flag stroke
  color defaultBallMarkColor = color(120, 120); // Default ball mark
  color arcColor = color(255,0,0,120); // Color of the stroke arc

  HoleVisualizer(int _x, int _y, int _w, int _h) {
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
    
    // Draw the ball markers
    for (Ball b : balls) {
      int pixDist = int((w-2*margin)*b.distance/totalLength);
      int ballPoint = b.past ? holePoint + pixDist : holePoint - pixDist;
      
      color ballMarkColor = defaultBallMarkColor;
      if (b.player == variableDisplayer.selectedPlayer) ballMarkColor = variableDisplayer.selectedTextCol;
      else if (b.player == variableDisplayer.hoveredPlayer) ballMarkColor = variableDisplayer.hoveredTextCol;
      stroke(ballMarkColor);
      if (!b.sunk && b.terrain != Terrain.TEE) line(x+margin+ballPoint, y+terrainY-ballMarkHeight/2, x+margin+ballPoint, y+terrainY+ballMarkHeight/2);
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
      
      int flip = eso.distance > eso.fromDistance ? -1 : 1;
      int startDist = flip * int((w-2*margin)*eso.fromDistance/totalLength);
      int startPoint = ballOf(eso.player).past ? holePoint + startDist : holePoint - startDist;
      
      int flipOob = ballOf(eso.player).past ? 1 : -1;
      float sentDistance = eso.toTerrain.outOfBounds ? eso.fromDistance + flipOob * eso.distance : eso.toDistance;
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
    
    // Draws active ball marker
    int activePixDist = int((w-2*margin)*currentBall.distance/totalLength);
    int activeBallPoint = currentBall.past ? holePoint + activePixDist : holePoint - activePixDist;
    stroke(staticColor);
    if (!currentBall.sunk && currentBall.terrain != Terrain.TEE)
      line(x+margin+activeBallPoint, y+terrainY-ballMarkHeight/2, x+margin+activeBallPoint, y+terrainY+ballMarkHeight/2);
    
    // Choose the color of the tee
    color teeStroke = Terrain.TEE.tColor;
    for (Ball b : balls) {
      if (b.terrain == Terrain.TEE) {
        if (b.player == variableDisplayer.selectedPlayer) {
          teeStroke = variableDisplayer.selectedTextCol;
          break;
        }
        else if (b.player == variableDisplayer.hoveredPlayer) teeStroke = variableDisplayer.hoveredTextCol;
        else if (b == currentBall && teeStroke == Terrain.TEE.tColor) teeStroke = staticColor;
      }
    }
        
    // Draw the tee
    float teeY = 0;
    if (teePoint < roughHeights.size()) teeY = roughHeights.get(teePoint);
    else teeY = greenHeights.get(teePoint-roughHeights.size());
    stroke(teeStroke);
    line(x+margin+teePoint, y+terrainY+teeY, x+margin+teePoint, y+terrainY+teeY-teeHeight);
    line(x+margin+teePoint-teeWidth/2, y+terrainY+teeY-teeHeight, x+margin+teePoint+teeWidth/2, y+terrainY+teeY-teeHeight);
    
    // Select flagpole color
    color flagpoleColor = Terrain.HOLE.tColor;
    if (currentBall.sunk) flagpoleColor = staticColor;
    else if (ballOf(variableDisplayer.selectedPlayer).sunk) flagpoleColor = variableDisplayer.inactiveSelectedTextCol;
    else if (ballOf(variableDisplayer.hoveredPlayer).sunk) flagpoleColor = variableDisplayer.hoveredTextCol;
    
    // Draw the flagpole
    stroke(flagpoleColor);
    line(x+margin+holePoint, y+terrainY, x+margin+holePoint, y+terrainY-flagpoleHeight);
    fill(flagFill);
    stroke(flagStroke);
    triangle(x+margin+holePoint, y+terrainY-flagpoleHeight,
             x+margin+holePoint, y+terrainY-flagpoleHeight+flagHeight,
             x+margin+holePoint-flagWidth, y+terrainY-flagpoleHeight+flagHeight/2);
    
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
