// hero motion
int yAccel = -1;
int yVeloc = 4;
int yPos = 17;

// display
int terminalColumns = 80;
int terminalRows = 24;
int terminalMarginBottom = 6;
int terminalMarginLeft = 6;
PFont font;
int fontSize = 16;
int atSignWidth;

void setup() {
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
  fill(255,0,0);
  for(int i = 0; i < 24; i++) {
    text("Hello FlappyRL",colToPixel(0),rowToPixel(i));
  }
}

int rowToPixel(int row) {
  return (row+1) * (fontSize + 2); 
}
int colToPixel(int col) {
  return col * atSignWidth + terminalMarginLeft;
}
