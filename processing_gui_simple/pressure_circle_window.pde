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
  float power;
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
  
  public void draw() {
    blendMode(BLEND);
    background(255);
    noStroke();
    int targetSize = int(width * 0.6);
    
    fill(color(blue, 180));
    int fillSize = int(max(0, pow(force / targetForce, power)) * targetSize);
    circle(width/2, width/2, fillSize);
    float nCorrect = 0;
    for (float element : forceHistory) {
      if (abs(element - targetForce) < forceRange)
        nCorrect ++;
      else
        nCorrect = 0;
    }
    if(forceHistory.size() > 0)
      ratio -= (ratio - nCorrect / forceHistory.size()) * 0.1;
    else
      ratio = 0;
    constrain(ratio, 0,1);
    if (nCorrect == forceHistory.size())
    {
      fill(yellow);
      circle(width/2, width/2, fillSize);
    } else
    {
      arc(width/2, width/2, fillSize, fillSize,
          HALF_PI - PI * ratio, HALF_PI + PI * ratio, CHORD);
    }
    int innerSize = int(pow((targetForce - forceRange) / targetForce, power) * targetSize);
    int outerSize = int(pow((targetForce + forceRange) / targetForce, power) * targetSize);
    
    fill(color(green,40));
    noStroke();
    drawDonut(width/2, height/2, innerSize, outerSize);
    
 
    blendMode(MULTIPLY);
    noFill();
    stroke(green);
    strokeWeight(5);
    circle(width/2, width/2, targetSize);
  }
  
  public void drawDonut(int centerX, float centerY, float r1, float r2) {
    
    beginShape();
    int ptsInCircle = 100;
    float x,y;
    // Draw outer edge of donut
    for (int i = 0; i <= ptsInCircle; i++){
          float theta = 2 * PI / ptsInCircle * i;
          x = r2*cos(theta) / 2 + centerX;
          y = r2*sin(theta) / 2 + centerY;
          vertex(x,y);
    }
    // trace inner edge of donut, in OPPOSITE direction
    for (int i = ptsInCircle; i >= 0 ; i--){
          float theta = 2 * PI / ptsInCircle * i;
          x = r1*cos(theta) / 2 + centerX;
          y = r1*sin(theta) / 2 + centerY;
          vertex(x,y);
    }
    endShape();
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
  
  public void randomize() {
    float range = 2;
    if(random(-1,1) > 0)
      power = random(1, range);
    else
      power = 1.0 / random(1, range);
  }
  
  
  public void mousePressed() {
    //randomize();
  }
}
