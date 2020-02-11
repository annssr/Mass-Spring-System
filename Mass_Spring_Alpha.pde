import java.util.Random;

ArrayList<Point> Points = new ArrayList<Point>(1);
ArrayList<Button> Buttons = new ArrayList<Button>(1);
ArrayList<Button> Modes = new ArrayList<Button>(1);
ArrayList<Spring> Springs = new ArrayList<Spring>(1);
static int DIMENSIONS = 1100;
Random rand = new Random();
static int Point_SIZE = 15;
float old_time = 0, new_time = 0;
static float TIME_STEP = 1500;
static float MAX_FORCE = 0.0001;
static float MAX_VELOCITY = 1.1;
float WANDER_WEIGHT = 0.5;
float GRAVITY = 0.9;
float BOUNCE = 0.0;
float AVOIDANCE_WEIGHT = 2.7;
float MATCHING_WEIGHT = 1.1;
float MOUSE_WEIGHT = 15.0;
float DAMPING_COEFF = 0.01;
float SPRING_DAMPING_COEFF = 0.01;
float FRICTION_COEFFICIENT = 0.5;
float TIME_MODIFIER = 0.1;
float k = 1.25; // Spring constant
static float CENTERING_DISTANCE = Point_SIZE * 20;
static float AVOIDANCE_DISTANCE = Point_SIZE * 4;

boolean animate = true;

int current_editable = 0;

// Buttons
Button pointAdder = new Button(1150, 50, "Add Points", false);
Button pointConnector = new Button(1150, 150, "Connect Points", false);
Button pointDrag = new Button(1150, 250, "Drag Points");
Button muscleConnector = new Button(1150, 350, "Connect Muscles", false);
Button gravity = new Button(1150, 450, "Toggle Gravity");
Button spring = new Button(1150, 550, "Toggle Muscles");

void setup(){
  size(1200, 600);
  // Add buttons
  Buttons.add(pointAdder);
  Buttons.add(pointConnector);
  Buttons.add(muscleConnector);
  Buttons.add(pointDrag);
  Buttons.add(gravity);
  Buttons.add(spring);
  // Add modes, only one of which can be selected at a time
  Modes.add(pointAdder);
  Modes.add(pointConnector);
  Modes.add(pointDrag);
  // Add points
  for(int i = 0; i < 1; i++){
    //Points.add(new Point(1, new PVector(abs(rand.nextInt()%600), abs(rand.nextInt()%600)), new PVector(0, 0), new PVector(0, 0)));
  }
}

void pairUp(Point A, Point B){
  float rest = dist(A.position.x, A.position.y, B.position.x, B.position.y);
  A.connected_to.add(B);
  B.connected_to.add(A);
  A.rest.add(rest);
  B.rest.add(rest);
}

void draw(){
  background(#FFFFFF);
  line(DIMENSIONS, 0, DIMENSIONS, height);
  //let's keep track of the variables and their values
  fill(#000000);
  //String current = current_editable==0? "WANDER WEIGHT": current_editable==1? "CENTERING WEIGHT": "AVOIDANCE WEIGHT";
  //text("Wander Weight: " + WANDER_WEIGHT + ", Centering Weight: " + CENTERING_WEIGHT + ", AVOIDANCE WEIGHT: " + AVOIDANCE_WEIGHT + "\n Current: " + current, 0, DIMENSIONS-20);
  new_time = millis();
  //if(animate){
  //  updateForces();
  //}
  // Apply rest phase to springs
  if(spring.selected){
    for(Spring s: Springs)
      s.rest();
  }
  for(Point b : Points){
    // Apply all forces on point
    b.applyForces();
    b.updatePosition();
    b.checkBounds();
    
    //Points.get(3).position.set(550, height - Point_SIZE/2 - 200);
    
    // Random Stuff
    if(randomize){
      b.position = new PVector(abs(rand.nextInt()%600), abs(rand.nextInt()%600));
    }
    if(dist(mouseX, mouseY, b.position.x, b.position.y) < Point_SIZE/2 && !pointAdder.selected)
      fill(#FF5A5A);
    else
      fill(#FF0000);
      
    // Drag the point around
    if(dragged_point != null)
      dragged_point.position.set(mouseX, mouseY);
    pushMatrix();
    translate(b.position.x, b.position.y);
    ellipse(0, 0, Point_SIZE, Point_SIZE);
    popMatrix();
    for(int i = 0; i < b.connected_to.size(); i++){
      fill(#000000);
      line(b.position.x, b.position.y, b.connected_to.get(i).position.x, b.connected_to.get(i).position.y);
    }
  }
  for(Button b: Buttons){
    b.display();
  }
  old_time = new_time;
  randomize = false;
}

void updateForces(){
  for(Point b : Points){
    PVector tmp_for_calculations = new PVector();
    
    // Mouse Stuff //<>//
    if(mousePressed){
      //figure out the distance between the two
      float distance = dist(b.position.x, b.position.y, mouseX, mouseY);
      //add the vector while multiplying it with the weight
      tmp_for_calculations = ((PVector.sub(new PVector(mouseX, mouseY), b.position)).div(distance)).mult(MOUSE_WEIGHT);
      if(!attract)
        tmp_for_calculations.mult(-1);
      b.forces.add(tmp_for_calculations);
    }
  }
}

boolean attract = true;
boolean addPoints = true;
boolean connectPoints = false;
Point pairable = null;
Point dragged_point = null;
void mousePressed() {
  int x = mouseX;
  int y = mouseY;
  if(mouseX <= DIMENSIONS){
    if(pointAdder.selected)
      Points.add(new Point(1, new PVector(mouseX, mouseY), new PVector(0, 0), new PVector(0, 0)));
    else if(pointConnector.selected){
      Point closest = null;
      double min_dist = Double.POSITIVE_INFINITY;
      // Search for the point closest to what we picked
      for(Point p: Points){
        double d = dist(x, y, p.position.x, p.position.y);
        if(d < min_dist){
          min_dist = d;
          closest = p;
        }
      }
      // Now we check whether we'd already selected a point or not
      if(pairable == null) // We didn't, so let's select this one for now
        pairable = closest;
      else if(closest != null){
        // We already did, so now we can pair the two points
        pairable.connected_to.add(closest);
        closest.connected_to.add(pairable);
        float rest_length = dist(closest.position.x, closest.position.y, pairable.position.x, pairable.position.y);
        if(muscleConnector.selected){
          // Create a spring object
          Springs.add(new Spring(pairable, closest, rest_length, pairable.rest.size(), closest.rest.size(), 0, rest_length, 0.1));
        }
        closest.rest.add(rest_length);
        pairable.rest.add(rest_length);
        pairable = null;
      }
    }
    else if(pointDrag.selected){
      // Check if we're already dragging a point
      if(dragged_point != null){
        // Deselect the point
        dragged_point = null;
      }
      else{
        double min_dist = Double.POSITIVE_INFINITY;
        // Search for the point closest to what we picked
        for(Point p: Points){
          double d = dist(x, y, p.position.x, p.position.y);
          if(d < min_dist){
            min_dist = d;
            dragged_point = p;
          }
        }
      }
    }
  }
  else{
    for(Button b: Buttons){
      if(x >= b.x && x <= b.x+b.buttonSize && y >= b.y && y <= b.y+b.buttonSize){
        // Check if we're selecting a mode
        if(Modes.contains(b)){
          // If so, mark it as selected, and everything else as not
          for(Button tmp: Modes)
            tmp.selected = false;
          b.selected = true;
          break;
        }
        b.selected = !b.selected;
        break;
      }
    }
  }
}

void mouseReleased(){
  dragged_point = null;
}

boolean randomize = false;
boolean toggle_avoidance = true, toggle_damping = true, toggle_wandering = true;
void keyPressed(){
  switch(key){
    case ' ':
      animate = !animate;
      break;
    case '-':
    if(Points.size() > 0)
      Points.remove(0);
      break;
    case '=':
      Points.add(new Point(1, new PVector(abs(rand.nextInt()%600), abs(rand.nextInt()%600)), new PVector(0, 0), new PVector(0, 0)));
      break;
    case '1':
      Points.clear();
      shape1();
      break;
    case '2':
      Points.clear();
      shape2();
      break;
    case 's':
      randomize = true;
      break;
    case 'a':
      System.out.println("Points");
      int i = 0;
      for(Point p: Points)
        System.out.println(i++ + ": " + p.position.x + ", " + p.position.y);
      for(Spring s: Springs)
        System.out.println(s.A.position.x + ", " + s.A.position.y + " - " + s.B.position.x + ", " + s.B.position.y);
      break;
    case 'c':
      Points.clear();
      background(#FFFFFF);
      break;
    default:
      break;
  }
}

void shape2(){
  // Set up a frame
  Points.add(new Point(1, new PVector(450, height - Point_SIZE/2 - 100), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(550, height - Point_SIZE/2 - 80), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(650, height - Point_SIZE/2 - 80), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(750, height - Point_SIZE/2 - 80), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(850, height - Point_SIZE/2 - 80), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(950, height - Point_SIZE/2 - 100), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(950, height - Point_SIZE/2 - 160), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(850, height - Point_SIZE/2 - 180), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(750, height - Point_SIZE/2 - 180), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(650, height - Point_SIZE/2 - 180), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(550, height - Point_SIZE/2 - 180), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(450, height - Point_SIZE/2 - 160), new PVector(0, 0), new PVector(0, 0)));
  // Link it
  for(int i = 0; i < Points.size(); i++)
    pairUp(Points.get(i), Points.get((i+1) % Points.size()));
  for(int i = 1; i < 5; i++){
    Point tailA = Points.get(i), tailB = Points.get(Points.size() - (i));
    pairUp(tailA, tailB); //<>//
    tailB = Points.get(Points.size() - i - 1);
    pairUp(tailA, tailB);
    tailB = Points.get(Points.size() - i - 2);
    pairUp(tailA, tailB);
  }
  pairUp(Points.get(0), Points.get(10));
  pairUp(Points.get(5), Points.get(7));
  // Now the legs
  Points.add(new Point(1, new PVector(600, height - Point_SIZE/2), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(800, height - Point_SIZE/2), new PVector(0, 0), new PVector(0, 0)));
  // Leg#1
  Point tailA = Points.get(12), tailB = Points.get(1);
  pairUp(tailA, tailB);
  float d = dist(tailA.position.x, tailA.position.y, tailB.position.x, tailB.position.y);
  Springs.add(new Spring(tailA, tailB, tailA.rest.get(tailA.rest.size()-1), tailA.rest.size()-1, tailB.rest.size()-1, 1/2, d/2, 0.2));
  tailB = Points.get(2);
  pairUp(tailA, tailB);
  d = dist(tailA.position.x, tailA.position.y, tailB.position.x, tailB.position.y);
  Springs.add(new Spring(tailA, tailB, tailA.rest.get(tailA.rest.size()-1), tailA.rest.size()-1, tailB.rest.size()-1, 2, d/2, 0.1));
  // Extra support
  tailB = Points.get(10);
  pairUp(tailA, tailB);
  //Springs.add(new Spring(tailA, tailB, tailA.rest.get(tailA.rest.size()-1), tailA.rest.size()-1, tailB.rest.size()-1, 1, d, 0.1));
  // Leg#2
  tailA = Points.get(13);
  tailB = Points.get(3);
  pairUp(tailA, tailB);
  d = dist(tailA.position.x, tailA.position.y, tailB.position.x, tailB.position.y);
  Springs.add(new Spring(tailA, tailB, tailA.rest.get(tailA.rest.size()-1), tailA.rest.size()-1, tailB.rest.size()-1, 1/2, d/2, 0.2));
  tailB = Points.get(4);
  pairUp(tailA, tailB);
  d = dist(tailA.position.x, tailA.position.y, tailB.position.x, tailB.position.y);
  Springs.add(new Spring(tailA, tailB, tailA.rest.get(tailA.rest.size()-1), tailA.rest.size()-1, tailB.rest.size()-1, 2, d/2, 0.1));
  // Extra support
  tailB = Points.get(8);
  pairUp(tailA, tailB);
  //Springs.add(new Spring(tailA, tailB, tailA.rest.get(tailA.rest.size()-1), tailA.rest.size()-1, tailB.rest.size()-1, 1, d, 0.1));
  
  //float d = dist(tailA.position.x, tailA.position.y, tailB.position.x, tailB.position.y);
  //Springs.add(new Spring(tailA, tailB, tailA.rest.get(tailA.rest.size()-1), tailA.rest.size()-1, tailB.rest.size()-1, i/3, 2*d/3, 0.1));
}

void shape1(){
  // Set up a "square" with six points
  Points.add(new Point(1, new PVector(750, height - Point_SIZE/2), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(850, height - Point_SIZE/2), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(950, height - Point_SIZE/2), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(940, height - Point_SIZE/2 - 50), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(850, height - Point_SIZE/2 - 60), new PVector(0, 0), new PVector(0, 0)));
  Points.add(new Point(1, new PVector(760, height - Point_SIZE/2 - 50), new PVector(0, 0), new PVector(0, 0)));
  // Link up the points
  for(int i = 0; i < Points.size(); i++)
    pairUp(Points.get(i), Points.get((i+1)%Points.size()));
  pairUp(Points.get(0), Points.get(4));
  pairUp(Points.get(1), Points.get(3));
  pairUp(Points.get(1), Points.get(4));
  pairUp(Points.get(1), Points.get(5));
  pairUp(Points.get(2), Points.get(4));
  Point tailA = Points.get(2), tailB = Points.get(4);
  float d = dist(tailA.position.x, tailA.position.y, tailB.position.x, tailB.position.y);
  Springs.add(new Spring(tailA, tailB, tailA.rest.get(tailA.rest.size()-1), tailA.rest.size()-1, tailB.rest.size()-1, 1, d, 0.2));
}
