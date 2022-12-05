public class PressureWindowArrow extends PressureWindow { 
  
  public PressureWindowArrow(float targetForce, float forceRange, float successTime)
  {
    super(targetForce, forceRange, successTime);
  } 
  
  public void draw() {
    blendMode(BLEND);
    background(255);
    noStroke();
    int targetSize = height / 5;
    float fillSize = 0;
    float forceSum = 0;
    int nCorrect = 0;
    for (float element : forceHistory) {
      forceSum += element;
      if (abs(element - targetForce) < forceRange)
        nCorrect ++;
      else
        nCorrect = 0;
    }
    if (timeHistory.size() > 3)
    {
      float lastTime = timeHistory.get(timeHistory.size() - 1);
      float df = linear_regression(timeHistory, forceHistory)[1];
      fillSize = (df / forceRange) * targetSize;
      ratio = nCorrect / forceHistory.size();
    }
    
    //fillSize = ((force-targetForce) / forceRange) * targetSize;
    fill(blue);
    if(abs(fillSize) < targetSize) fill(green);
    else if (fillSize > 0) fill(red);
    rect(0, height / 2, width, -fillSize);
    fill(color(green,100));
    rect(0, height / 2 - targetSize, width, targetSize * 2);
    stroke(yellow);
    strokeWeight(5);
    line(0,height / 2,width, height / 2);
    
    
  }
}
