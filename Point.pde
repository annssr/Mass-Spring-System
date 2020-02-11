class Point{
  int maxY;
  int mass;
  PVector position; // Position
  PVector old_position;
  PVector velocity;
  PVector forces;
  ArrayList<Point> connected_to = new ArrayList<Point>();
  ArrayList<Float> rest = new ArrayList<Float>(); // Rest lengths
  public Point(int m, PVector p, PVector v, PVector f){
    mass = m;
    position = p;
    old_position = p;
    velocity = v;
    forces = f;
  }
  
  void checkBounds(){
    int rad = Point_SIZE/2;
    boolean lb = this.position.x > (DIMENSIONS - rad);
    boolean rb = this.position.x < rad;
    if(rb || lb){
      // Move it back to a legal area
      position.x = rb? rad : (DIMENSIONS - rad);
      //this.velocity.set(this.velocity.x * -BOUNCE, this.velocity.y);
    }
    boolean db = this.position.y > (height - rad);
    boolean ub = this.position.y < rad;
    if(ub || db){
      // Move it back to a legal area
      position.y = db? (height - rad) : rad;
      //this.velocity.set(this.velocity.x, this.velocity.y * -BOUNCE);
    }
    // Check if we're just oscillating a small distance. In such a case, just stop moving
    if((ub || lb || db || rb) && this.velocity.mag() < 0.0001){
      this.velocity.set(0, 0);
      return;
    }
  }
  
  public void updatePosition(){
    old_position = position.copy();
    
    // Friction
    // First, check if we're actually moving in any direction and that we're on the ground
    float mag = this.velocity.mag();
    if(mag > 0 && this.position.y == (height - Point_SIZE/2)){
      // Cool, now we check if the friction force is higher or not
      float downward_force = this.mass * GRAVITY * FRICTION_COEFFICIENT;
      if(mag <= downward_force) // Yes, so we neutralize the force
        this.velocity.x = 0;
      else{ // No, so we decrease the force by the amount
        // Check direction and prep accordingly
        velocity.x = TIME_MODIFIER * forces.x + (forces.x > 0? -downward_force: forces.x < 0? downward_force: 0);
      } 
    }
    
    // Multiply forces by time...?
    this.forces.mult(TIME_MODIFIER);
    //add the acceleration (force * time) to current velocity to obtain new velocity
    this.velocity.set(PVector.add(this.velocity, this.forces));
    // Check if it's so slow we might as well just stop it from moving
    if(this.velocity.mag() <= TIME_MODIFIER * 0.1){
      this.velocity.set(0, 0);
      return;
    }
    
    // Add velocity to position
    this.position.add(new PVector(this.velocity.x * TIME_MODIFIER, this.velocity.y * TIME_MODIFIER));
  }
  
  public void applyForces(){
    this.forces.set(0, 0);
    
    // Wander force
    if(toggle_wandering){
      float x = -1 + (rand.nextFloat() % 1) * (1 - -1), y = -1 + (rand.nextFloat() % 1) * (1 - -1);
      PVector wandering_vector = new PVector(x, y);
      wandering_vector.mult(WANDER_WEIGHT);
      wandering_vector.limit(MAX_FORCE);
      //this.forces.add(wandering_vector);
    }
    
    // Spring force
    for(int i = 0; i < connected_to.size(); i++){
      Point c = connected_to.get(i);
      float r = rest.get(i);
      PVector L = new PVector(this.position.x - c.position.x, this.position.y - c.position.y);
      PVector LDot = new PVector(this.velocity.x - c.velocity.x, this.velocity.y - c.velocity.y);
      PVector LNorm = (L.copy()).normalize();
      float Lmag = L.mag();
      PVector springA = LNorm.mult(-1 * (k * (Lmag - r) + SPRING_DAMPING_COEFF * LDot.dot(LNorm)));
      //PVector springA = new PVector(LNorm.x * -1 * (k * (Lmag - r)), LNorm.y * -1 * (k * (Lmag - r)));
      //springA.add(DAMPING_COEFF * LDot.dot(LNorm), DAMPING_COEFF * LDot.dot(LNorm));
      this.forces.add(springA);
    }
    
    // Gravity
    // Check that we're not already on the ground
    float downward_force = this.mass * GRAVITY;
    if(gravity.selected && this.position.y != (height - Point_SIZE/2)){
      // Create the vector for gravity
      PVector gravity_vector = new PVector(0, downward_force);
      //Add the gravity to the point
      this.forces.add(gravity_vector);
    }
    
    //Viscous Damping
    if(toggle_damping){
      // Calculate damping force
      float drag = this.velocity.mag();
      drag = drag * drag * DAMPING_COEFF;
      PVector damping_vector = this.velocity.copy();
      damping_vector.mult(-1);
      damping_vector.setMag(drag);
      // Apply damping proportional to velocity
      this.forces.add(damping_vector);
    }
  }
  
}

boolean reverse_x, reverse_y;
int boundaries(int var, Point p){
  int point_bounds = p.mass * Point_SIZE/2;
  int displacement;
  // Check if point is edging into the boundary
  if(var < point_bounds){
    // Calculate displacement to get the point back within the boundaries
    displacement = point_bounds;
  }
  else if(var > (DIMENSIONS - point_bounds)){
    displacement = DIMENSIONS - point_bounds;
  }
  else{
    return var;
  }
  return displacement;
}
