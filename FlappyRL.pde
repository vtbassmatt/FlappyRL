/* @pjs globalKeyEvents="true"; */

static final boolean DEBUG = false;
static final String VERSION = "1.0.2.1";

boolean PROCESSING_JS = (""+2.0==""+2);

static class GameState {
  static final int NOT_STARTED = 0;
  static final int ALIVE = 1;
  static final int DEAD = 2;
}

Hero hero;
Pipes pipes;
Console console;
Tombstone tombstone;
Backdrop[] backdrop;
int state;
int playerScore;
String causeOfDeath;

// debugging
int lastKeyCode;

void setup() {
  // we have to cheat, because Processing.JS requires that size() be the first call in setup()
  if(PROCESSING_JS) {
    size(800, 438);
  }
  frameRate(30);
  
  state = GameState.NOT_STARTED;
  hero = new Hero();
  pipes = new Pipes();
  console = new Console();
  tombstone = new Tombstone(hero);
  backdrop = new Backdrop[] { new Backdrop(2), new Backdrop(3) };
  playerScore = 0;
  causeOfDeath = "a glitch in the matrix";
  
  lastKeyCode = 0;
  
  if(DEBUG) {
    // skip the title screen in debug mode
    state = GameState.ALIVE;
  }
}

void draw() {
  background(15);
  
  if(state == GameState.NOT_STARTED) {
      fill(lerpColor(color(0,255,0), color(0,200,0), colorPulsePosition(2.0)));
      String[] instructions = {
        "Welcome to FlappyRL.",
        "",
        "Controls: Right arrow to advance, up arrow to flap your wings.",
        "Gravity is always trying to pull you down.",
        "",
        "Press spacebar to begin."
      };
      for(int i = 0; i < instructions.length; i++) {
        String instruc = instructions[i];
        console.print(instruc, (console.columns / 2) - (instruc.length() / 2), (console.rows / 2) + i - (instructions.length / 2));
      }
      fill(127);
      console.print(VERSION, 0, console.rows - 1);
  } else {
  
    for(int i = 0; i < backdrop.length; i++) {
      backdrop[i].draw(console);
    }
    
    pipes.draw(console);
    drawGround();
    
    if(state == GameState.ALIVE) {
      hero.draw(console);
    } else {
      fill(200,0,0);
      console.print("You are dead", console.columns / 2 - 6, console.rows / 2 - 1);
      console.print("(" + causeOfDeath + ")", console.columns / 2 - (causeOfDeath.length() / 2 + 1), console.rows / 2);
      console.print("Press spacebar to try again", console.columns / 2 - 13, console.rows / 2 + 1);
      tombstone.draw(console);
    }

  }
  
  // score
  fill(255);
  console.print("score: " + Integer.toString(playerScore),0,0);
  
  // debugging
  if(DEBUG) {
    if(lastKeyCode > 0) {
      fill(127);
      console.print(Integer.toString(lastKeyCode),76,0);
    }
  }
}

void drawGround() {
  fill(0,127,0);
  for(int i = 0; i < console.columns + 1; i++) {
    console.print("_", i, console.rows - 1);
  }
}

void keyPressed() {
  lastKeyCode = keyCode;
  
  if(state == GameState.ALIVE) {
    switch(keyCode) {
      case 39:  // right arrow
      case 65:  // A for advance
        updateTheWorld();
        break;
        
      case 38:  // up arrow
      case 70:  // F for flap
        hero.yVeloc = -2;
        updateTheWorld();
        break;
    }
  } else if(state == GameState.NOT_STARTED) {
    if(keyCode == 32) {
      state = GameState.ALIVE;
    }
  } else if(state == GameState.DEAD) {
    if(keyCode == 32) {
      setup();
      state = GameState.ALIVE;
    }
  }
}

void updateTheWorld() {
  hero.physicsTick();
  pipes.advance();
  for(int i = 0; i < backdrop.length; i++) {
    backdrop[i].advance();
  }
  
  checkCollisions();
  checkScore();
}

void checkCollisions() {
  if(hero.yPos >= console.rows) {
    // crashed into ground
    causeOfDeath = "crashed into ground";
    state = GameState.DEAD;
  } else if(hero.yPos < 0) {
    // soared off top
    causeOfDeath = "soared into the sun";
    state = GameState.DEAD;
  } else if(pipes.collided(hero)) {
    // collided with a pipe
    causeOfDeath = "hit a pipe";
    state = GameState.DEAD;
  }
}

void checkScore() {
  int points = pipes.scorePoints(hero);
  if(points > 0) {
    playerScore += points;
  }
}
