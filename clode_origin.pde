// GLOLF TO DO LIST
// No. of players - no set amount (start w 12)
// Players: name, gender (random adjectives), cringe (chance of total beefitude), dumbassery (choice of stroke type), yeetness (strength), trigonometry (accuracy),
//          bisexuality (curve skill), asexuality (hole-in-one chance), scrappiness (skill in rough areas), charisma (get it in the hole ;3), autism (magic)
// Strokes: drive (max length min accuracy), approach (medium to long range + more accuracy), chip (med-short range), putt (short range)
// Holes: par, roughness, heterosexuality (straightness), thicc (likelihood to go oob), verdancy (easiness to get on the green),
//          obedience (green tameness), quench (water hazards), thirst (sand bunkers)
// Tourney: 18 courses of stroke play, sudden death on tie

// Potential future mechanics
// Select player
// Play, pause, and step buttons
// Every player has a net worth
// Prize money + guillotine
// Terrain
// Adding players or player death
// Small chance of insta-guillotine
// Cringe has chance to nullify dumbassery
// High enough scrappiness -> hitting out of bunker is an advantage
// Shadow games
// Hole size
// Weather: type, wind speed, direction
// Balls
// Clubs
// Course/hole names
// Tourny of the Damned (Revive player?)
// Charity Match: Atone
// Resdistribute Wealth: "The League has been weighed down by their sins."
// Sainthood -100000 $ins


PlayerManager playerManager = new PlayerManager();
TourneyManager tourneyManager;
Feed feed = new Feed();

int margin = 10;
int buttonSetHeight = 80;
int varDisplayWidth = 600;
int eventDisplayHeight = 120;
int timeButtonWidth;
int headButtonWidth;

Button homeButton;
Button[] timeButtons = new Button[5];
Button[] headButtons = new Button[4];
VariableDisplayer variableDisplayer;
EventDisplayer eventDisplayer;
HoleVisualizer holeVisualizer;

// Setup
void setup() {
  surface.setTitle("Glolf!");
  size(1800, 800);

  PFont font = loadFont("data/Calibri-Light-48.vlw");
  textFont(font);
  
  // Initialize Buttons
  timeButtonWidth = buttonSetHeight-2*margin;
  headButtonWidth = int(((width - margin - varDisplayWidth) - (headButtons.length+1) * margin)/headButtons.length);
  
  homeButton = new Button("Home", "home", margin, margin, varDisplayWidth-5*(timeButtonWidth+margin), buttonSetHeight-2*margin);
 
  timeButtons[0] = new Button("1", "pause", 2*margin+varDisplayWidth-5*(timeButtonWidth+margin), margin, buttonSetHeight-2*margin, buttonSetHeight-2*margin);
  timeButtons[1] = new Button("2", "play", 2*margin+varDisplayWidth-4*(timeButtonWidth+margin), margin, buttonSetHeight-2*margin, buttonSetHeight-2*margin);
  timeButtons[2] = new Button("3", "back", 2*margin+varDisplayWidth-3*(timeButtonWidth+margin), margin, buttonSetHeight-2*margin, buttonSetHeight-2*margin);
  timeButtons[3] = new Button("4", "next", 2*margin+varDisplayWidth-2*(timeButtonWidth+margin), margin, buttonSetHeight-2*margin, buttonSetHeight-2*margin);
  timeButtons[4] = new Button("5", "speed", 2*margin+varDisplayWidth-(timeButtonWidth+margin), margin, buttonSetHeight-2*margin, buttonSetHeight-2*margin);

  headButtons[0] = new Button("Show Feed", "show_feed", 2*margin + varDisplayWidth, margin, headButtonWidth, buttonSetHeight-2*margin);
  headButtons[1] = new Button("Debugging", "debug_menu", 3*margin + headButtonWidth + varDisplayWidth, margin, headButtonWidth, buttonSetHeight-2*margin);
  headButtons[2] = new Button("Girl Button", "girl", 4*margin + 2*headButtonWidth + varDisplayWidth, margin, headButtonWidth, buttonSetHeight-2*margin);
  headButtons[3] = new Button("Save Players", "save_players", 5*margin + 3*headButtonWidth + varDisplayWidth, margin, headButtonWidth, buttonSetHeight-2*margin);
   
  //Initialize Players & TourneyManager
  playerManager.clearAllPlayers();
  playerManager.addNewPlayers(16);
  tourneyManager = new TourneyManager(new Tourney(playerManager.allPlayers, 18));
    
  // Initialize Displays
  eventDisplayer = new EventDisplayer(2*margin+varDisplayWidth, buttonSetHeight+margin, width-3*margin-varDisplayWidth, eventDisplayHeight);
  holeVisualizer = new HoleVisualizer(2*margin+varDisplayWidth, buttonSetHeight+eventDisplayHeight+2*margin, width-3*margin-varDisplayWidth, height-buttonSetHeight-eventDisplayHeight-3*margin);
  variableDisplayer = new VariableDisplayer(tourneyManager, margin, buttonSetHeight + margin, varDisplayWidth, height - buttonSetHeight - 2*margin);
}

// Draw
void draw() {
  background(200);
  
  homeButton.display();
  for (Button button : headButtons) {
    button.display();
  }
  for (Button button : timeButtons) {
    button.display();
  }
  

  strokeWeight(2);
  stroke(0);
  line(0, buttonSetHeight, width, buttonSetHeight);

  variableDisplayer.display();
  eventDisplayer.display();
  holeVisualizer.display();
}

// Picks a random item from .txt file
String generateRandomFromList(String filename) {
  String[] list = loadStrings(filename);
  int idx = int(random(list.length));
  return list[idx];
}

// When mouse is pressed
void mousePressed() {
  for (Button button : headButtons) {
    if (button.isOver()) {
      switch(button.onClick) {
        case "next_event":
          tourneyManager.nextEvent();
          break;
        case "next_hole":
          break;
        case "show_feed":
          break;
        case "debug_menu":
          break;
        case "girl":
          println("Mauuuuu <- that's 'I love my geef' in kitty cat <333");
          break;
        case "save_players":
          playerManager.savePlayersToJSON();
          break;
        default: break;
      }
    }
  }
  for (ButtonChangeVarDisplay button : variableDisplayer.displayChangeButtons) {
    if (button.isOver()) {
      button.onClick();
      for (ButtonChangeVarDisplay b : variableDisplayer.displayChangeButtons) {
        if (b != button) b.deactivate();
      }
    }
  }
}

// When mouse is moved
void mouseMoved() {
  for (Button button : headButtons) {
    if (button.isOver()) {
      button.select();
    }
    else {
      button.deselect(); 
    }
  }
}

// When mouse wheel is scrolled
void mouseWheel(MouseEvent e) {
  variableDisplayer.scroll(e.getCount());
}
