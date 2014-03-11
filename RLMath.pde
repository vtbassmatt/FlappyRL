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
