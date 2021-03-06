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

