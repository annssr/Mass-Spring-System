public class Spring{
  Point A, B;
  float frequency, phase, amplitude;
  float rest_length;
  int restA, restB;
  public Spring(Point a, Point b, float rest_l, int rA, int rB, float phas, float amp, float f){
    A = a;
    B = b;
    phase = phas;
    amplitude = amp;
    frequency = f;
    rest_length = rest_l;
    restA = rA;
    restB = rB;
  }
  
  float ang = 0;
  public void rest(){
    float new_rest = rest_length/2 + abs(sin((frequency * (ang + phase * PI/2))) * amplitude);
    // Update the pair's rest lengths
    A.rest.set(restA, new_rest);
    B.rest.set(restB, new_rest);
    ang += 0.2;
  }
}
