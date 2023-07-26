public class PressureCircleWindow extends PressureWindow {
  float power;
  
  public PressureCircleWindow(float targetForce, float forceRange, float successTime)
  {
    super(targetForce, forceRange, successTime);
  }
  
  public void draw() {
    blendMode(BLEND);
    background(255);
    noStroke();
    int targetSize = int(width * 0.6);
    fill(color(blue, 180));
    int fillSize = int(max(0, pow(force / targetForce, power)) * targetSize);
    stroke(green);
    strokeWeight(5);
    circle(width/2, width/2, fillSize);
    float nCorrect = 0;
    for (float element : forceHistory) {
      if (abs(element - targetForce) < forceRange)
        nCorrect ++;
      else
        nCorrect = 0;
    }
    ratio = nCorrect / forceHistory.size();
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
