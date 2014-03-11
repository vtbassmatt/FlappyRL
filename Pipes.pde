class Pipes {
  int[] pipeList = new int[120];
  int pipeGap = 2;
  NumberSource heightNumbers;
  NumberSource distanceNumbers;
  int ticksTilNextPipe;
  
  Pipes() {
    //heightNumbers = new NoiseNumberSource(1, 23);
    heightNumbers = new RandomNumberSource(1, 23);
    
    distanceNumbers = new RandomNumberSource(10,20);
    
    int i;
    for(i = 16; i < pipeList.length; i += distanceNumbers.getNext()) {
      pipeList[i] = heightNumbers.getNext();
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
      if(Math.abs(pipeList[hero.xPos] - hero.yPos) < pipeGap) {
        return 1;
      }
    }
    return 0;
  }
}

