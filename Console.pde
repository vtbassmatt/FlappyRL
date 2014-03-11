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

