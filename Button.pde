public class Button{
  int buttonSize = 20;
  int x, y;
  boolean selected = true;
  String label;
  public Button(int x, int y, String label){
    this.x = x;
    this.y = y;
    this.label = label;
  }
  
  public Button(int x, int y, String label, boolean selected){
    this.x = x;
    this.y = y;
    this.label = label;
    this.selected = selected;
  }
  
  public void display(){
    fill(selected? #0000FF:#FFFFFF); // If selected, it becomes blue
    rect(x, y, buttonSize, buttonSize);
    fill(#000000);
    textSize(12);
    textAlign(CENTER);
    text(label, x + buttonSize/2, y + 2 * buttonSize);
  }
}
