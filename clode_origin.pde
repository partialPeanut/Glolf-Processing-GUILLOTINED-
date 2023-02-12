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

PlayerManager playerManager = new PlayerManager();
TourneyManager tourneyManager;
Feed feed = new Feed();

int margin = 10;
int buttonSetHeight = 80;
int varDisplayWidth = 600;
int eventDisplayHeight = 120;
int buttonWidth;

Button[] buttons = new Button[6];
VariableDisplayer variableDisplayer;
EventDisplayer eventDisplayer;
HoleVisualizer holeVisualizer;

// Setup
void setup() {
  surface.setTitle("Glolf!");
  size(1800, 800);

  PFont font = loadFont("data/Calibri-Light-48.vlw");
  textFont(font);

  buttonWidth = int((width - (buttons.length+1) * margin)/buttons.length);
  buttons[0] = new Button("Next Event", "next_event", margin, margin, buttonWidth, buttonSetHeight-2*margin);
  buttons[1] = new Button("Next Hole", "next_hole", 2*margin + buttonWidth, margin, buttonWidth, buttonSetHeight-2*margin);
  buttons[2] = new Button("Show Feed", "show_feed", 3*margin + 2*buttonWidth, margin, buttonWidth, buttonSetHeight-2*margin);
  buttons[3] = new Button("Debugging", "debug_menu", 4*margin + 3*buttonWidth, margin, buttonWidth, buttonSetHeight-2*margin);
  buttons[4] = new Button("Girl Button", "girl", 5*margin + 4*buttonWidth, margin, buttonWidth, buttonSetHeight-2*margin);
  buttons[5] = new Button("Save Players", "save_players", 6*margin + 5*buttonWidth, margin, buttonWidth, buttonSetHeight-2*margin);

  eventDisplayer = new EventDisplayer(2*margin+varDisplayWidth, buttonSetHeight+margin, width-3*margin-varDisplayWidth, eventDisplayHeight);
  holeVisualizer = new HoleVisualizer(2*margin+varDisplayWidth, buttonSetHeight+eventDisplayHeight+2*margin, width-3*margin-varDisplayWidth, height-buttonSetHeight-eventDisplayHeight-3*margin);
  
  playerManager.clearAllPlayers();
  playerManager.addNewPlayers(16);
  tourneyManager = new TourneyManager(new Tourney(playerManager.allPlayers, 18));
  
  variableDisplayer = new VariableDisplayer(tourneyManager, margin, buttonSetHeight + margin, varDisplayWidth, height - buttonSetHeight - 2*margin);
}

// Draw
void draw() {
  background(200);

  for (Button button : buttons) {
    button.display();
  }

  strokeWeight(2);
  stroke(0);
  line(0, buttonSetHeight, width, buttonSetHeight);

  variableDisplayer.display();
  eventDisplayer.display();
  holeVisualizer.display();
}

// When mouse is pressed
void mousePressed() {
  for (Button button : buttons) {
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

// When mouse wheel is scrolled
void mouseWheel(MouseEvent e) {
  variableDisplayer.scroll(e.getCount());
}
