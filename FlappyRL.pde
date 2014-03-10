static class GameState {
  static final int NOT_STARTED = 0;
  static final int ALIVE = 1;
  static final int DEAD = 2;
}

class Hero {
  // motion
  int yAccel;  // positive numbers point down - consider fixing
  int yVeloc;
  int yPos;
  int xPos;

  Hero() {
    yAccel = 1;
    yVeloc = 2;
    yPos = 24 - 17;  // closer to the top than the bottom
    xPos = 5;
  }
  
  void draw(Console console) {
    //fill(0,0,255);
    fill(255,0,255);  // temporary - f.lux hides the character
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
  
  Pipes() {
    for(int i = 12; i < pipeList.length; i += 12) {
      pipeList[i] = 17;
    }
  }
  
  void draw(Console console) {
    fill(0,255,0);
    for(int i = 0; i < console.columns + 1; i++) {
      if(pipeList[i] > 0) {
        for(int j = 0; j < console.rows; j++) {
          if(Math.abs(pipeList[i] - j) >= pipeGap) {
            console.print("=",i,j);
          }
        }
      }
    }
  }

  void advance () {
    for(int i = 1; i < pipeList.length - 1; i++) {
      pipeList[i-1] = pipeList[i];
    }
    pipeList[pipeList.length-1] = 0;
  }
  
  boolean collided(Hero hero) {
    if(pipeList[hero.xPos] != 0) {
      if(Math.abs(pipeList[hero.xPos] - hero.yPos) >= pipeGap) {
        return true;
      }
    }
    return false;
  }
}

// display
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
    font = loadFont("Menlo-Regular-16.vlw");
    textFont(font);

    // figure out width of a character + space between characters
    float w1 = textWidth("@");
    float w2 = textWidth("@@");
    atSignWidth = (int)(w2 - w1);
    
    size(atSignWidth * columns, (fontSize + 2) * rows + marginBottom);
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

Hero hero;
Pipes pipes;
Console console;
int state;

// debugging
int lastKeyCode;

void setup() {
  state = GameState.NOT_STARTED;
  hero = new Hero();
  pipes = new Pipes();
  console = new Console();
  
  lastKeyCode = 0;
  
  // TODO: make first keypress send you into ALIVE
  state = GameState.ALIVE;
}

void draw() {
  background(0);
  
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
  }
  
  // debugging
  if(lastKeyCode > 0) {
    console.print(Integer.toString(lastKeyCode),0,0);
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
  }
}

void updateTheWorld() {
  hero.physicsTick();
  pipes.advance();
  
  checkCollisions();
}

void checkCollisions() {
  if(hero.yPos >= console.rows) {
    // crashed into ground
    println("crashed into ground");
    state = GameState.DEAD;
  } else if(hero.yPos < 0) {
    // soared off top
    println("soared into the sun");
    state = GameState.DEAD;
  } else if(pipes.collided(hero)) {
    // collided with a pipe
    println("hit a pipe");
    state = GameState.DEAD;
  }
}
