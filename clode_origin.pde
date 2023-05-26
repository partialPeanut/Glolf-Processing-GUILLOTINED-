// GLOLF TO DO LIST
// No. of players - no set amount (start w 12)
// Players: name, gender (random adjectives), cringe (chance of total beefitude), dumbassery (choice of stroke type), yeetness (strength), trigonometry (accuracy),
//          bisexuality (curve skill), asexuality (hole-in-one chance), scrappiness (skill in rough areas), charisma (get it in the hole ;3), autism (magic)
// Strokes: drive (max length min accuracy), approach (medium to long range + more accuracy), chip (med-short range), putt (short range)
// Holes: par, roughness, heterosexuality (straightness), thicc (likelihood to go oob), verdancy (easiness to get on the green),
//          obedience (green tameness), quench (water hazards), thirst (sand bunkers)
// Tourney: 18 courses of stroke play, sudden death on tie

// Main Features
//
// Main menu
// Debug Menu
// Different gamemodes
// Simultaneous Games: 
// 4 courses > 1 tourney
// 4 different rankings
// Top scoring players in each section + top scoring players overall go on to final match
// Course Mods and Hole Mods are interchangable

// Potential future mechanics
//
// Coastal (Everything is sand or water)
// Cringe
// Birds
// Boogey Tournies // High scores win // Boons + Curses
// Shadow games
// Giant turtle (the course is on a giant turtle)
// Balls
// Clubs (both the sticks and the bougie places)
// Tourny of the Damned (Revive player?)
// Charity Match: Atone
// Sainthood -100000 $ins
// Strikes
// PvP

// Bugs
//
// Fix rewinding
// Hole scale sometimes breaks? No clue why lmao

LeagueManager leagueManager = new LeagueManager();
PlayerManager playerManager = new PlayerManager();
TourneyManager tourneyManager;
Feed feed = new Feed();
UIController uiController = new UIController();

int totalPlayers = 96;
int playersPerTourney = 16;
int coursesPerTourney = 4;
int holesPerCourse = 9;

PFont boldFont;
PFont font;

int timePassed = 0;
int speedValue = 1000;
boolean playActive = false;
boolean timeStopped = false;

Button homeButton;
Button[] timeButtons = new Button[5];
Button[] headButtons = new Button[4];
UIComponent[][] uiComponents = new Button[6][];
VariableDisplayer variableDisplayer;
EventDisplayer eventDisplayer;
HoleDisplayer holeDisplayer;

// Setup
void setup() {
  //Application Settings
  surface.setTitle("Glolf!");
  surface.setIcon(loadImage("assets/icons/game_icon/bogey2.png"));
  size(1800, 960);
  
  //Font
  boldFont = loadFont("assets/fonts/PixelOperator-48.vlw");
  font = loadFont("assets/fonts/PixelOperator-48.vlw");
  
  //Initialize Players & TourneyManager
  playerManager.clearAllPlayers();
  playerManager.addNewPlayers(totalPlayers);
  tourneyManager = new TourneyManager(new Tourney(playerManager.chooseRandomLivingPlayers(playersPerTourney), coursesPerTourney, holesPerCourse));  
    
  // Initialize Buttons & Displays
  uiComponents = uiController.uiStartUp();
  
  homeButton        = (Button)uiComponents[0][0];
  timeButtons       = (Button[])uiComponents[1];
  headButtons       = (Button[])uiComponents[2];  
  eventDisplayer    = (EventDisplayer)uiComponents[3][0];
  holeDisplayer     = (HoleDisplayer)uiComponents[4][0];
  variableDisplayer = (VariableDisplayer)uiComponents[5][0];
}

// Draw
void draw() {
  background(200);
  
  textFont(boldFont);
  for (int i = 0; i < 3; i++) {
    for (UIComponent component : uiComponents[i]) component.display();
    if (i == 2) {
      textFont(font);
      strokeWeight(2);
      stroke(0);
      line(0, uiController.buttonSetHeight, width, uiController.buttonSetHeight);
    }
  }
  
  

  variableDisplayer.display();
  eventDisplayer.display();
  holeDisplayer.display();
  
  if (playActive && !timeStopped) {
    timeButtons[0].unpress();
    timeButtons[1].press();
    timeButtons[2].disable();
    timeButtons[3].disable();
  
    if (millis() >= timePassed + speedValue) nextEvent();
  }
  else if (!timeStopped) {
    timeButtons[0].press();
    timeButtons[1].unpress();
    timeButtons[2].enable();
    timeButtons[3].enable();
  }
}

void stopTime() {
  timeStopped = true;
  for (Button b : timeButtons) b.disable();
}
void resumeTime() {
  timeStopped = false;
  for (Button b : timeButtons) b.enable();
}

GlolfEvent nextEvent() {
  GlolfEvent lastEvent = leagueManager.nextEvent();
  for (int i = 0; i < 100; i++) {
    if (lastEvent != null) break;
    else lastEvent = leagueManager.nextEvent();
  }
  if (lastEvent == null) lastEvent = new EventNoEvent();
  
  timePassed += speedValue;
  feed.addEvent(lastEvent);
  println(lastEvent.toText());
  return lastEvent;
}

// Picks a random item from .txt file
String generateRandomFromList(String filename) {
  String[] list = loadStrings(filename);
  int idx = int(random(list.length));
  return list[idx];
}

// When keys are pressed
void keyPressed() {
  switch(key) {
    case ' ':
      playActive = !playActive;
      break;
    case 'c':
      if (timeStopped) tourneyManager.newRandomTourney(playerManager.chooseRandomLivingPlayers(playersPerTourney), coursesPerTourney, holesPerCourse);
      break;
  }
}

// When mouse is pressed
void mousePressed() {
  Button[] allButtons = (Button[])concat(concat(timeButtons, headButtons), append(holeDisplayer.butts, homeButton));
  
  for (Button button : allButtons) {
    if (button.isOver() && button.enabled) {
      button.press();
      switch(button.onClick) {
        case "pause":
          playActive = false;
          break;
        case "play": 
          if (!playActive) timePassed = millis();
          playActive = true;
          break;
        case "back":
          if (feed.everyEvent.size() > 1) {
            tourneyManager.undoEvent(feed.lastEvent());
            feed.removeLastEvent();
          }
          break;
        case "next":
          nextEvent();
          break;
        case "speed": 
          if (speedValue == 1000) speedValue = 500;
          else if (speedValue == 500) speedValue = 1;
          else if (speedValue == 1) speedValue = 1000;
          break;
        case "show_feed": break;
        case "debug_menu": break;
        case "girl":
          println("*kisskisskisskisskisskisskisskisskisskiss*");
          break;
        case "save_players":
          playerManager.savePlayersToJSON();
          break;
        case "kill_player":
          if (feed.lastEvent().playState().tourney != null && !timeStopped) {
            leagueManager.killPlayerDuringTourney();
            nextEvent();
          }
          break;
        case "restart":
          tourneyManager.restartTourney();
          break;
        case "continue":
          tourneyManager.newRandomTourney(playerManager.chooseRandomLivingPlayers(playersPerTourney), coursesPerTourney, holesPerCourse);
          break;
        case "exit":
          exit();
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
  
  if (variableDisplayer.isOverInfo()) variableDisplayer.selectPlayer();
}

// When mouse is released
void mouseReleased() {
  homeButton.unpress();
  for (Button button : timeButtons) {
    if (button.onClick != "play" && button.onClick != "pause") button.unpress();
  }
  for (Button button : headButtons) button.unpress();
  for (Button button : holeDisplayer.butts) button.unpress();
}

// When mouse is moved
void mouseMoved() {
  Button[] allButtons = (Button[])concat(concat(timeButtons, headButtons), append(holeDisplayer.butts, homeButton));
  for (Button button : allButtons) {
    if (button.isOver()) button.select();
    else button.deselect();
  }
  
  if (!variableDisplayer.isOverInfo()) variableDisplayer.dehover();
}

// When mouse is dragged
void mouseDragged() {
  Button[] allButtons = (Button[])concat(concat(timeButtons, headButtons), append(holeDisplayer.butts, homeButton));
  for (Button button : allButtons) {
    if (button.isOver()) button.select();
    else button.deselect();
  }
  
  if (!variableDisplayer.isOverInfo()) variableDisplayer.dehover();
}

// When mouse wheel is scrolled
void mouseWheel(MouseEvent e) {
  variableDisplayer.scroll(e.getCount());
}
