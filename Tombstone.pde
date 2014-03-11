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
