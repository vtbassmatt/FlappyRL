class Background {
  int[] cloudList = new int[120];
  NumberSource heightNumbers;
  NumberSource distanceNumbers;
  int ticksTilNextCloud;
  int depth;
  int ticksTilNextAdvance;
  
  color cloudColor1 = color(240);
  color cloudColor2 = color(40);
  
  Background(int depth) {
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

