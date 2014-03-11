/* @pjs globalKeyEvents="true"; */

static final boolean DEBUG = false;
static final String VERSION = "1.0.1.0";

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
      console.print("You are dead", console.columns / 2 - 6, console.rows / 2);
      console.print("(" + causeOfDeath + ")", console.columns / 2 - (causeOfDeath.length() / 2 + 1), console.rows / 2 + 1);
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
class Backdrop {
  int[] cloudList = new int[120];
  NumberSource heightNumbers;
  NumberSource distanceNumbers;
  int ticksTilNextCloud;
  int depth;
  int ticksTilNextAdvance;
  
  color cloudColor1 = color(240);
  color cloudColor2 = color(40);
  
  Backdrop(int depth) {
    distanceNumbers = new NoiseNumberSource(5,20);
    heightNumbers = new RandomNumberSource(1,20);
    
    int i;
    for(i = 16; i < cloudList.length; i += distanceNumbers.getNext()) {
      cloudList[i] = heightNumbers.getNext();
    }
    
    ticksTilNextCloud = i - cloudList.length;
    
    this.depth = depth;
    ticksTilNextAdvance = depth;
  }
  
  void draw(Console console) {
    for(int i = 0; i < console.columns + 1; i++) {
      if(cloudList[i] > 0) {
        fill(lerpColor(cloudColor1, cloudColor2, colorPulsePosition(24 - cloudList[i])));
        console.print("~",i,cloudList[i]);
      }
    }
  }

  void advance () {
    ticksTilNextAdvance--;
    
    if(ticksTilNextAdvance <= 0) {
      ticksTilNextAdvance = depth;
      
      for(int i = 1; i < cloudList.length; i++) {
        cloudList[i-1] = cloudList[i];
      }
      
      ticksTilNextCloud--;
      if(ticksTilNextCloud <= 0) {
        ticksTilNextCloud = distanceNumbers.getNext();
        cloudList[cloudList.length-1] = heightNumbers.getNext();
      } else {
        cloudList[cloudList.length-1] = 0;
      }
    }
  }
}

class Console {
  int columns;
  int rows;
  int marginBottom;
  int marginLeft;
  PFont font;
  int fontSize;
  int atSignWidth;
  
  Console() {
    columns = 80;
    rows = 24;
    marginBottom = 6;
    marginLeft = 6;
    
    fontSize = 16;
    if(PROCESSING_JS) {
      font = createFont("monospace",fontSize);
    } else {
      font = loadFont("Menlo-Regular-16.vlw");
    }
    textFont(font);

    // figure out width of a character + space between characters
    float w1 = textWidth("@");
    float w2 = textWidth("@@");
    atSignWidth = (int)(w2 - w1);
    
    size(atSignWidth * columns, (fontSize + 2) * rows + marginBottom);
    if(DEBUG) {
      if(width != 800) { println("expected width 800, got " + width); }
      if(height != 438) { println("expected height 438, got " + height); }
    }
  }
  
  int rowToPixel(int row) {
    return (row+1) * (fontSize + 2); 
  }
  int colToPixel(int col) {
    return col * atSignWidth + marginLeft;
  }
  
  void print(String s, int col, int row) {
    text(s, colToPixel(col), rowToPixel(row));
  }
}

class Hero {
  // motion
  int yAccel;  // positive numbers point down - consider fixing
  int yVeloc;
  int yPos;
  int xPos;
  
  color mainColor = color(0,0,255);
  //color mainColor = color(255,0,255);  // for use during f.lux nighttime
  color pulseColor = color(0,127,255);

  Hero() {
    yAccel = 1;
    yVeloc = -1;
    yPos = 24 - 17;  // closer to the top than the bottom
    xPos = 5;
  }
  
  void draw(Console console) {
    fill(lerpColor(mainColor, pulseColor, colorPulsePosition(1.0)));

    console.print("@",xPos,yPos);
    
    // show where the player will be next frame
    for(int i = 1; i < 6; i++) {
      fill(255 / (i+1));
      console.print("@",xPos+i, futureFrame(i));
    }
  }
  
  int futureFrame(int delta) {
    if(delta < 0) {
      return yPos;
    }
    
    int newYVeloc = yVeloc;
    int newYPos = yPos;
    
    while(delta > 0) {
      newYVeloc = newYVeloc + yAccel;
      newYPos = newYPos + newYVeloc;
      delta--;
    }
    
    return newYPos;
  }
  
  void physicsTick() {
    yVeloc = yVeloc + yAccel;
    yPos = yPos + yVeloc;
  }

}

class Pipes {
  int[] pipeList = new int[120];
  int pipeGap = 2;
  int allowedHeightDelta = 12;
  NumberSource heightNumbers;
  NumberSource distanceNumbers;
  int ticksTilNextPipe;
  int lastPipeHeight;
  
  Pipes() {
    //heightNumbers = new NoiseNumberSource(1, 23);
    heightNumbers = new RandomNumberSource(1, 23);
    
    distanceNumbers = new RandomNumberSource(10,20);
    
    // pretend the last pipe was at height 12 - middle of the screen
    lastPipeHeight = 12;
    int i;
    for(i = 16; i < pipeList.length; i += distanceNumbers.getNext()) {
      pipeList[i] = heightNumbers.getNext();
      
      // ensure we didn't create an impossible situation
      while(abs(lastPipeHeight - pipeList[i]) > allowedHeightDelta) {
        pipeList[i] = heightNumbers.getNext();
      }
      
      lastPipeHeight = pipeList[i];
    }
    
    ticksTilNextPipe = i - pipeList.length;
  }
  
  void draw(Console console) {
    fill(0,255,0);
    for(int i = 0; i < console.columns + 1; i++) {
      if(pipeList[i] > 0) {
        for(int j = 0; j < console.rows; j++) {
          if(Math.abs(pipeList[i] - j) > pipeGap) {
            console.print("|",i,j);
          } else if(Math.abs(pipeList[i] - j) == pipeGap) {
            console.print("=",i,j);
          }
        }
      }
    }
  }

  void advance () {
    for(int i = 1; i < pipeList.length; i++) {
      pipeList[i-1] = pipeList[i];
    }
    
    ticksTilNextPipe--;
    if(ticksTilNextPipe <= 0) {
      ticksTilNextPipe = distanceNumbers.getNext();
      pipeList[pipeList.length-1] = heightNumbers.getNext();

      // ensure we didn't create an impossible situation
      while(abs(lastPipeHeight - pipeList[pipeList.length-1]) > allowedHeightDelta) {
        pipeList[pipeList.length-1] = heightNumbers.getNext();
      }
      lastPipeHeight = pipeList[pipeList.length-1];
      
    } else {
      pipeList[pipeList.length-1] = 0;
    }
  }
  
  boolean collided(Hero hero) {
    if(pipeList[hero.xPos] != 0) {
      if(Math.abs(pipeList[hero.xPos] - hero.yPos) >= pipeGap) {
        return true;
      }
    }
    return false;
  }
  
  int scorePoints(Hero hero) {
    if(pipeList[hero.xPos] != 0) {
      if(DEBUG) {
        println("height: " + pipeList[hero.xPos]);
      }
      if(Math.abs(pipeList[hero.xPos] - hero.yPos) < pipeGap) {
        return 1;
      }
    }
    return 0;
  }
}

interface NumberSource {
  int getNext();
}

class NoiseNumberSource implements NumberSource {
  // from Processing docs: Perlin noise source works best
  // with a step between 0.005 and 0.03 for most applications
  float step = 0.1;
  float offset = 0.0;
  float min;
  float max;
  float range;
  
  NoiseNumberSource(int min, int max) {
    this.min = (float)min;
    this.max = (float)max;
    range = max - min;
  }
  
  int getNext() {
    offset += step;
    return (int)(range * noise(offset) + min);
  }
}

class RandomNumberSource implements NumberSource {
  int min;
  int max;
  
  RandomNumberSource(int min, int max) {
    this.min = min;
    this.max = max;
  }
  
  int getNext() {
    return (int)(random(min,max));
  }
}

float colorPulsePosition(float duration) {  
    float frameOfPeriod = frameCount % (frameRate * duration);
    float position = frameOfPeriod / (frameRate * duration);
    float sinPosition = sin(PI * position);
    
    return abs(sinPosition);
}
class Tombstone {
  Hero hero;
  
  Tombstone(Hero hero) {
    this.hero = hero;
  }
  
  void draw(Console console) {
    fill(190);
    console.print(" ,., ", hero.xPos - 2, console.rows - 4);
    console.print("|:::|", hero.xPos - 2, console.rows - 3);
    console.print("|RIP|", hero.xPos - 2, console.rows - 2);
    console.print("|:::|", hero.xPos - 2, console.rows - 1);
  }
}

