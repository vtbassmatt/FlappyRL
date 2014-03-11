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

