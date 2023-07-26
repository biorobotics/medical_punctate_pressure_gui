public class PressureWindow extends PApplet { 
  // Force variables
  float force;
  float targetForce;
  float forceRange;
  float successTime;
  FloatList forceHistory = new FloatList();
  FloatList timeHistory = new FloatList();
  
  // Drawing variables
  float ratio;
  color forceColor, forceColorLight, doneColor;
  color blue = color(66,133,244);
  color red = color(219, 68, 55);
  color green = color(15, 157, 88);
  color yellow = color(244, 180, 0);
  
  public PressureWindow(float targetForce, float forceRange, float successTime)
  {
    super();
    this.targetForce = targetForce;
    this.forceRange = forceRange;
    this.successTime = successTime;
    force = 0;
    ratio = 0;
  }
  
  public void settings() {
    size(800, 800);
    forceColor = color(66, 133, 244);
    forceColorLight = color(160, 195, 255);
    doneColor  = color(15,157,88);
    randomize();
  }
  
  public void setForce(float f) {
    force = f;
    float time = millis() / 1000.0;
    forceHistory.append(force);
    timeHistory.append(time);
    for (int i=forceHistory.size()-1; i >= 0; --i) {
      if (time - timeHistory.get(i) > successTime)
      {
        forceHistory.remove(i);
        timeHistory.remove(i);
      }
    }
  }
  
  public void setTargetForce(float f) {
    targetForce = f;
  }
  
  public void draw() {
  }
  
  public void mousePressed() {
  }
  
  public void randomize() {
  }
}
