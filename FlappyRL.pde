/*
TODO:
  - Generate parallax scrolling background
  - Make some pipes fatter than others
  - Animate the main character?
  - Add spells/potions/monsters?
*/

static class GameState {
  static final int NOT_STARTED = 0;
  static final int ALIVE = 1;
  static final int DEAD = 2;
}

Hero hero;
Pipes pipes;
Console console;
Tombstone tombstone;
int state;
int playerScore;
String causeOfDeath;

// debugging
int lastKeyCode;

void setup() {
  state = GameState.NOT_STARTED;
  hero = new Hero();
  pipes = new Pipes();
  console = new Console();
  tombstone = new Tombstone(hero);
  playerScore = 0;
  causeOfDeath = "a glitch in the matrix";
  
  lastKeyCode = 0;
  
  // temporary: remove this line to bring back the title screen
  state = GameState.ALIVE;
}

void draw() {
  background(0);
  
  if(state == GameState.NOT_STARTED) {
      fill(0,200,0);
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
  } else {
  
    // hello world
    fill(127,0,0);
    for(int i = 0; i < console.rows; i++) {
      console.print("Hello FlappyRL",i,i);
    }
    
    pipes.draw(console);
    drawGround();
    
    if(state == GameState.ALIVE) {
      hero.draw(console);
    } else {
      fill(200,0,0);
      console.print("You are dead", console.columns / 2 - 6, console.rows / 2);
      console.print("(" + causeOfDeath + ")", console.columns / 2 - (causeOfDeath.length() / 2 + 1), console.rows / 2 + 1);
      tombstone.draw(console);
    }

  }
  
  // score
  fill(255);
  console.print("score: " + Integer.toString(playerScore),0,0);
  
  // debugging
  if(lastKeyCode > 0) {
    fill(127);
    console.print(Integer.toString(lastKeyCode),76,0);
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
        updateTheWorld();
        break;
        
      case 38:  // up arrow
        hero.yVeloc = -2;
        updateTheWorld();
        break;
    }
  } else if(state == GameState.NOT_STARTED) {
    if(keyCode == 32) {
      state = GameState.ALIVE;
    }
  }
}

void updateTheWorld() {
  hero.physicsTick();
  pipes.advance();
  
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
