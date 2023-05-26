class UIController {
  final int margin = 10;
  final int buttonSetHeight = 80;
  final int varDisplayWidth = 600;
  final int eventDisplayHeight = 160;
  
  UIComponent[][] uiStartUp() {
    int timeButtonWidth = buttonSetHeight-2*margin;
    int headButtonWidth = int(((width - margin - varDisplayWidth) - (headButtons.length+1) * margin)/headButtons.length);
    
    UIComponent[][] uiComponents;    
    
    uiComponents = new UIComponent[6][];
    
    Button[] homeButton = new Button[1];
    homeButton[0]  = new Button("Home", "home", margin, margin, varDisplayWidth-5*(timeButtonWidth+margin), buttonSetHeight-2*margin);
    
    Button[] timeButtons = new Button[5];
    timeButtons[0] = new Button("II", "pause", 2*margin+varDisplayWidth-5*(timeButtonWidth+margin), margin, buttonSetHeight-2*margin, buttonSetHeight-2*margin);
    timeButtons[1] = new Button(">", "play", 2*margin+varDisplayWidth-4*(timeButtonWidth+margin), margin, buttonSetHeight-2*margin, buttonSetHeight-2*margin);
    timeButtons[2] = new Button("I<", "back", 2*margin+varDisplayWidth-3*(timeButtonWidth+margin), margin, buttonSetHeight-2*margin, buttonSetHeight-2*margin);
    timeButtons[3] = new Button(">I", "next", 2*margin+varDisplayWidth-2*(timeButtonWidth+margin), margin, buttonSetHeight-2*margin, buttonSetHeight-2*margin);
    timeButtons[4] = new Button(">>", "speed", 2*margin+varDisplayWidth-(timeButtonWidth+margin), margin, buttonSetHeight-2*margin, buttonSetHeight-2*margin);
  
    Button[] headButtons = new Button[4];
    headButtons[0] = new Button("Murder", "kill_player", 2*margin + varDisplayWidth, margin, headButtonWidth, buttonSetHeight-2*margin);
    headButtons[1] = new Button("Debugging", "debug_menu", 3*margin + headButtonWidth + varDisplayWidth, margin, headButtonWidth, buttonSetHeight-2*margin);
    headButtons[2] = new Button("Girl Button", "girl", 4*margin + 2*headButtonWidth + varDisplayWidth, margin, headButtonWidth, buttonSetHeight-2*margin);
    headButtons[3] = new Button("Save Players", "save_players", 5*margin + 3*headButtonWidth + varDisplayWidth, margin, headButtonWidth, buttonSetHeight-2*margin);
  
    EventDisplayer[] eventDisplayer = new EventDisplayer[1];
    eventDisplayer[0] = new EventDisplayer(2*margin+varDisplayWidth, buttonSetHeight+margin, width-3*margin-varDisplayWidth, eventDisplayHeight);
    
    HoleDisplayer[] holeDisplayer = new HoleDisplayer[1];
    holeDisplayer[0] = new HoleDisplayer(2*margin+varDisplayWidth, buttonSetHeight+eventDisplayHeight+2*margin, width-3*margin-varDisplayWidth, height-buttonSetHeight-eventDisplayHeight-3*margin);
    
    VariableDisplayer[] variableDisplayer = new VariableDisplayer[1];
    variableDisplayer[0] = new VariableDisplayer(tourneyManager, margin, buttonSetHeight + margin, varDisplayWidth, height - buttonSetHeight - 2*margin);      
    
    uiComponents[0] = homeButton;
    uiComponents[1] = timeButtons;
    uiComponents[2] = headButtons;
    uiComponents[3] = eventDisplayer;
    uiComponents[4] = holeDisplayer;
    uiComponents[5] = variableDisplayer;    
   
    return uiComponents;
  }
  
  // Creates a new linear gradient
  //NOTE: If n is too small and cannot be evenly divided by l-1, it can cause a NullPointerException!
  Gradient[] linearGrad(String _vh, float _x, float _y, float _w, float _h, int _n, color... _c) {
    
    String direction = _vh;       // direction should be equal to "V" or "H", specifying the the gradient direction    
    float x = _x;                 // x, y, w, and h function as if one was using rect()  
    float y = _y;                 // They define the overall size and position of the gradient
    float w = _w;                 // The optional _c parameters define the gradient colors, from top to bottom or left to right
    float h = _h;                 // l is equal to the number of color paramaters entered into the function
    int l = _c.length;            // l-1 is frequently used and is equal to the length of the color[][] array C
    int n = _n;                   // n is the number of rectangles that make up the gradient, higher values -> smoother gradient    
    int m = n/max(1,(l-1));       // m is equal to n divided into sections for each color pair
    
    color[][]  C = constructColorArray(_c);
    Gradient[] G = constructGradientArray(direction, x, y, w, h, 0, 0, l, n, m, C);        
    return G;
  }
  
  // Creates a new radial gradient
  //NOTE: If n is too small and cannot be evenly divided by l-1, it can cause a NullPointerException!
  Gradient[] radialGrad(float _x, float _y, float _r1, float _r2, float _p1, float _p2, int _n, color... _c) {
    
    String direction = "R";       // direction for radial gradients is always equal to "R"
    float x = _x;                 // x, y, r1, and r2 function as if one was using ellipse() or arc()  
    float y = _y;                 // They define the overall size and position of the gradient
    float r1 = _r1;               // p1 and p2 define the starting and ending radius of the arc()
    float r2 = _r2;               // for an ellipse: p1 = 0 and p2 = TWO_PI
    float p1 = _p1;               // The optional _c parameters define the gradient colors, from top to bottom or left to right
    float p2 = _p2;               // l is equal to the number of color paramaters entered into the function
    int l = _c.length;            // l-1 is frequently used and is equal to the length of the color[][] array C
    int n = _n;                   // n is the number of circles that make up the gradient, higher values -> smoother gradient    
    int m = n/max(1,(l-1));       // m is equal to n divided into sections for each color pair    
    
    color[][]  C = constructColorArray(_c);
    Gradient[] G = constructGradientArray(direction, x, y, r1, r2, p1, p2, l, n, m, C);    
    return G;
  }
  
  private color[][] constructColorArray(color[] _c, String... _z) {
    int l = _c.length;
    String z = null;
    if (_z.length > 0) z = _z[0];
    color[][] C = new color[max(1,(l-1))][2];
    Boolean c1 = l > 0;    
    Boolean c2 = l > 1;
    if (c1) C[0][0] = _c[0];
    if (c2) C[0][0] = _c[0];
    
    C[0][1] = l > 1 ? _c[1] : -1;
    if (!c1) {
      if (c2) {
        int r = (C[0][1] >> 16) & 0xFF;
        int g = (C[0][1] >> 8) & 0xFF;
        int b = C[0][1] & 0xFF;
        C[0][0] = color(r,g,b,0);
      }
      else {
        C[0][0] = color(0,0,0,0);
        C[0][1] = color(0,0,0,0);
      }      
    }
    else if (c1) {
      if (!c2) {
        int r = (C[0][0] >> 16) & 0xFF;
        int g = (C[0][0] >> 8) & 0xFF;
        int b = C[0][0] & 0xFF;
        C[0][1] = color(r,g,b,0);
      }
    }
    if (l > 2) {
      for (int i = 1; i < l-1; i++) {
        C[i][0] = _c[i];
        C[i][1] = _c[i+1];
      }
    }
    if (z != null) {
      color[][] I = new color[max(1, (l-1))][2];
      int j = l-2;
      for (int i = 0; i < max(1, (l-1)); i++) {
        I[i][0] = C[j][1];
        I[i][1] = C[j][0];
        j--;
      }
      C = I;
    }
    return C;
  }
  
  private Gradient[] constructGradientArray(String _vhr, float _x, float _y, float _wr1, float _hr2, float _p1, float _p2, int _l, int _n, int _m, color[][] _C) {
    
    String type = _vhr;    
    float x  = _x; 
    float y  = _y;
    int   l  = _l;
    int   n  = _n;
    int   m  = _m;
    
    float r1 = (type == "R")  ?      _wr1 : 0;    
    float r2 = (type == "R")  ?      _hr2 : 0;
    float w  = (type != "R")  ?      _wr1 : 0;   
    float h  = (type != "R")  ?      _hr2 : 0;
    float p1 = (type == "R")  ?       _p1 : 0;
    float p2 = (type == "R")  ?       _p2 : 0;
    float q1 = (type == "R")  ?  (r1-1)/n : 0;
    float q2 = (type == "R")  ?  (r2-1)/n : 0;
    
    color[][] C = _C;
    Gradient[] G = new Gradient[n];
    
    h = type == "V" ? (h/n) : h;
    w = type == "H" ? (w/n) : w;
    // i is a variable used in the outer for() loop
    for (int i = 0; i < max(1,(l-1)); i++) {
      int k = 0;
      if ((m*(i+2)) <= n) {
        for (int j = (m*i); j < (m*(i+1)); j++) {
          float z = float(k)/float(m);
          color c = lerpColor(C[i][0], C[i][1], z);
          if (type == "V") G[j] = new Gradient( x, (y+(j*h)), w, h, c );
          if (type == "H") G[j] = new Gradient( (x+(j*w)), y, w, h, c );
          if (type == "R") G[j] = new Gradient(x, y, (q1*(n-j)), (q2*(n-j)), p1, p2, c );
          k++;
        }
      }
      else {
        for (int j = (m*i); j < n; j++) {
          float z = float(k)/float(n-(m*i));
          color c = lerpColor(C[i][0], C[i][1], z);
          if (type == "V") G[j] = new Gradient( x, (y+(j*h)), w, h, c );
          if (type == "H") G[j] = new Gradient( (x+(j*w)), y, w, h, c );
          if (type == "R") G[j] = new Gradient(x, y, (q1*(n-j)), (q2*(n-j)), p1, p2, c );
          k++;
        }
      }
    }
    return G;
  }
}
