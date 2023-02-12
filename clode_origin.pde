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

import g4p_controls.*;

PlayerManager playerManager = new PlayerManager();
TourneyManager tourneyManager;
Feed feed = new Feed();

int margin = 10;
int buttonSetHeight = 80;
int varDisplayWidth = 600;
int eventDisplayHeight = 120;
int buttonWidth;

GGroup buttonGroup;
GButton[] buttons = new GButton[6];
VariableDisplayer variableDisplayer;
EventDisplayer eventDisplayer;
HoleVisualizer holeVisualizer;

// Setup
void setup() {
  surface.setTitle("Glolf!");
  size(1800, 800);
  
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(4);
  
  G4P.setDisplayFont("data/Calibri-Light-48.vlw", G4P.PLAIN, 36);
  GButton.useRoundCorners(false);

  buttonWidth = int((width - (buttons.length+1) * margin)/buttons.length);
  buttons[0] = new GButton(this, margin + 0 * (buttonWidth + margin), margin, buttonWidth, buttonSetHeight-2*margin, "Next Event");
  buttons[0].addEventHandler(this, "handleNextEvent");
  buttons[1] = new GButton(this, margin + 1 * (buttonWidth + margin), margin, buttonWidth, buttonSetHeight-2*margin, "Next Hole");
  buttons[1].addEventHandler(this, "handleNextHole");
  buttons[2] = new GButton(this, margin + 2 * (buttonWidth + margin), margin, buttonWidth, buttonSetHeight-2*margin, "Show Feed");
  buttons[2].addEventHandler(this, "handleShowFeed");
  buttons[3] = new GButton(this, margin + 3 * (buttonWidth + margin), margin, buttonWidth, buttonSetHeight-2*margin, "Debugging");
  buttons[3].addEventHandler(this, "handleDebugMenu");
  buttons[4] = new GButton(this, margin + 4 * (buttonWidth + margin), margin, buttonWidth, buttonSetHeight-2*margin, "Girl Button");
  buttons[4].addEventHandler(this, "handleGirlButton");
  buttons[5] = new GButton(this, margin + 5 * (buttonWidth + margin), margin, buttonWidth, buttonSetHeight-2*margin, "Save Players");
  buttons[5].addEventHandler(this, "handleSavePlayers");
  
  buttonGroup = new GGroup(this);
  for (GButton b : buttons) buttonGroup.addControl(b);

  eventDisplayer = new EventDisplayer(2*margin+varDisplayWidth, buttonSetHeight+margin, width-3*margin-varDisplayWidth, eventDisplayHeight);
  holeVisualizer = new HoleVisualizer(2*margin+varDisplayWidth, buttonSetHeight+eventDisplayHeight+2*margin, width-3*margin-varDisplayWidth, height-buttonSetHeight-eventDisplayHeight-3*margin);
  
  playerManager.clearAllPlayers();
  playerManager.addNewPlayers(16);
  tourneyManager = new TourneyManager(new Tourney(playerManager.allPlayers, 18));
  
  variableDisplayer = new VariableDisplayer(this, tourneyManager, margin, buttonSetHeight + margin, varDisplayWidth, height - buttonSetHeight - 2*margin);
}

// Draw
void draw() {
  background(200);

  strokeWeight(2);
  stroke(0);
  line(0, buttonSetHeight, width, buttonSetHeight);

  variableDisplayer.display();
  eventDisplayer.display();
  holeVisualizer.display();
}

// When mouse wheel is scrolled
void mouseWheel(MouseEvent e) {
  variableDisplayer.scroll(e.getCount());
}

void handleNextEvent(GButton button, GEvent event) {
  tourneyManager.nextEvent();
}
