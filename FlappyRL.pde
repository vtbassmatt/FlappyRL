class Hero {
  // hero motion
  int yAccel;  // positive numbers point down - should fix that
  int yVeloc;
  int yPos;
  int xPos;

  Hero() {
    yAccel = 1;
    yVeloc = 4;
    yPos = 24 - 17;  // closer to the top than the bottom
    xPos = 5;
  }
}

Hero hero;

// the world
int[] pipes = new int[120];

// display
int terminalColumns = 80;
int terminalRows = 24;
int terminalMarginBottom = 6;
int terminalMarginLeft = 6;
PFont font;
int fontSize = 16;
int atSignWidth;

void setup() {
  hero = new Hero();
  
  for(int i = 12; i < 120; i += 12) {
    pipes[i] = 17;
  }
  font = loadFont("Menlo-Regular-16.vlw");
  textFont(font);
  
  // figure out width of a character + space between characters
  float w1 = textWidth("@");
  float w2 = textWidth("@@");
  atSignWidth = (int)(w2 - w1);
  
  size(atSignWidth * terminalColumns, (fontSize + 2) * terminalRows + terminalMarginBottom);
}

void draw() {
  background(0);
  
  // hello world
  fill(127,0,0);
  for(int i = 0; i < 24; i++) {
    text("Hello FlappyRL",colToPixel(i),rowToPixel(i));
  }
  
  // hero
  fill(0,0,255);
  text("@",colToPixel(hero.xPos),rowToPixel(hero.yPos));
  
  // pipes
  fill(0,255,0);
  for(int i = 0; i < terminalColumns + 1; i++) {
    if(pipes[i] > 0) {
      text("=",colToPixel(i),rowToPixel(23));
    }
  }
}

int rowToPixel(int row) {
  return (row+1) * (fontSize + 2); 
}
int colToPixel(int col) {
  return col * atSignWidth + terminalMarginLeft;
}
