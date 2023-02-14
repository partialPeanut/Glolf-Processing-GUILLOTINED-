static class Slope {
  static float loggy(float min, float max, float x) {
    return (max-min)/2 * (log((x-6+sqrt(sq(x-6)+4))/2)/log(3+sqrt(10))+1) + min;
  }
  
  static float scrappy(float b, float x, float s) {
    return pow(x, pow(b,6-s));
  }
  
  static float gaussy(float x, float m, float sd) {
    return exp(-sq(x-m)/(2*sq(sd)))/sd;
  }
  
  static float expy(float x, float b, float z) {
    return z * pow(b, sq(x)/8000);
  }
}
