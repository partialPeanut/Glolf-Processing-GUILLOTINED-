class HoleVisualizer {
  Hole hole = null;
  
  int holePoint, teePoint;
  float totalLength;
  FloatList roughHeights = new FloatList();
  FloatList greenHeights = new FloatList();
  FloatList pastHeights = new FloatList();

  int x, y, w, h;
  int margin = 10;
  
  int terrainY;
  int greenSlope = 10;
  float noiseScale = 0.01;
  float noiseBase = 30;
  
  float teeHeight = 10;
  float teeWidth = 10;
  float flagpoleHeight = 90;
  float flagHeight = 30;
  float flagWidth = 30;
  float ballMarkHeight = 40;
  float ballArcHeight = 90;
  
  int bgCol = 50;
  int strokeCol = 0;
  int textCol = 255;
  int textSize = 48;
  int textLeading = 40;
  
  color staticColor = color(255,0,0);
  color flagFill = color(220, 0, 0);
  color flagStroke = color(255, 0, 0);
  color defaultBallMarkColor = color(120, 120);

  HoleVisualizer(int _x, int _y, int _w, int _h) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    
    terrainY = int(0.6*h);
  }
  
  void setHole(Hole h) {
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
    
    if (hole == null) {
      fill(textCol);
      textAlign(CENTER,CENTER);
      textSize(textSize);
      text("---", x+w/2, y+h/2);
      return;
    }
    
    strokeWeight(4);
    
    GlolfEvent lastEvent = feed.lastEvent();
    Ball currentBall = tourneyManager.holeControl.currentBall();
    ArrayList<Ball> activeBalls = tourneyManager.holeControl.activeBalls;
    
    // Draw arc
    if (lastEvent instanceof EventStrokeOutcome) {
      EventStrokeOutcome eso = (EventStrokeOutcome)lastEvent;
      
      int flip = eso.distance > eso.fromDistance ? -1 : 1;
      int startDist = flip * int((w-2*margin)*eso.fromDistance/totalLength);
      int startPoint = tourneyManager.holeControl.ballOf(eso.player).past ? holePoint + startDist : holePoint - startDist;
      
      float sentDistance = eso.toTerrain.outOfBounds ? eso.fromDistance - eso.distance : eso.toDistance;
      int endDist = int((w-2*margin)*sentDistance/totalLength);
      int endPoint = tourneyManager.holeControl.ballOf(eso.player).past ? holePoint + endDist : holePoint - endDist;
      
      float startY = getHeight(startPoint);
      if (eso.fromTerrain == Terrain.TEE) startY -= teeHeight;
    
      noFill();
      ellipseMode(CORNER);
      stroke(255,120);
      arc(x+margin+min(startPoint,endPoint), y+terrainY+startY-ballArcHeight, abs(startPoint-endPoint), 2*ballArcHeight, -PI, 0);
      
      if (eso.toTerrain.outOfBounds);
    }
    
    // Choose the color of the tee
    color teeStroke = Terrain.TEE.tColor;
    for (Ball b : activeBalls) {
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
    else if (tourneyManager.holeControl.ballOf(variableDisplayer.selectedPlayer).sunk) flagpoleColor = variableDisplayer.inactiveSelectedTextCol;
    else if (tourneyManager.holeControl.ballOf(variableDisplayer.hoveredPlayer).sunk) flagpoleColor = variableDisplayer.hoveredTextCol;
    
    // Draw the flagpole
    stroke(flagpoleColor);
    line(x+margin+holePoint, y+terrainY, x+margin+holePoint, y+terrainY-flagpoleHeight);
    fill(flagFill);
    stroke(flagStroke);
    triangle(x+margin+holePoint, y+terrainY-flagpoleHeight,
             x+margin+holePoint, y+terrainY-flagpoleHeight+flagHeight,
             x+margin+holePoint-flagWidth, y+terrainY-flagpoleHeight+flagHeight/2);
    
    // Draw the terrain
    int i = 0;
    stroke(Terrain.ROUGH.tColor);
    for (float f : roughHeights) {
      point(x+margin+i, y+terrainY+f);
      i++;
    }
    stroke(Terrain.GREEN.tColor);
    for (float f : greenHeights) {
      point(x+margin+i, y+terrainY+f);
      i++;
    }
    stroke(Terrain.ROUGH.tColor);
    for (float f : pastHeights) {
      point(x+margin+i, y+terrainY+f);
      i++;
    }
    
    // Draw the ball markers
    for (Ball b : activeBalls) {
      int pixDist = int((w-2*margin)*b.distance/totalLength);
      int ballPoint = b.past ? holePoint + pixDist : holePoint - pixDist;
      
      color ballMarkColor = defaultBallMarkColor;
      if (b.player == variableDisplayer.selectedPlayer) ballMarkColor = variableDisplayer.selectedTextCol;
      else if (b.player == variableDisplayer.hoveredPlayer) ballMarkColor = variableDisplayer.hoveredTextCol;
      else if (b == currentBall) ballMarkColor = staticColor;
      stroke(ballMarkColor);
      if (!b.sunk && b.terrain != Terrain.TEE) line(x+margin+ballPoint, y+terrainY-ballMarkHeight/2, x+margin+ballPoint, y+terrainY+ballMarkHeight/2);
    }
    
    strokeWeight(2);
  }
  
  float getHeight(int x) {
    if (x < roughHeights.size()) return roughHeights.get(x);
    else if (x < roughHeights.size() + greenHeights.size()) return greenHeights.get(x-roughHeights.size());
    else return pastHeights.get(x-roughHeights.size()-greenHeights.size());
  }
}
