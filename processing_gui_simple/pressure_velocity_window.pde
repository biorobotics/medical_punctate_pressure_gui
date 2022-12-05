float[] linear_regression(FloatList x, FloatList y) { 
    float[] retval = new float[2];
    int N = x.size();
    assert(N == y.size());
    float x_sum = 0;
    float y_sum = 0;
    for(int i=0; i<N; i++)
    {
     x_sum += x.get(i);
     y_sum += y.get(i);
    }
    float x_mean = x_sum / N;
    float y_mean = y_sum / N;
    
    float num_sum = 0;
    float den_sum = 0;
    for(int i=0; i<N; i++)
    {
     num_sum += (x.get(i) - x_mean) * (y.get(i) - y_mean);
     den_sum += pow(x.get(i) - x_mean, 2);
    }
    
    retval[1] = num_sum / den_sum;
    retval[0] = y_mean - (retval[1]*x_mean);
    
    return retval;
}

public class PressureVelocityWindow extends PressureWindow { 
  
  public PressureVelocityWindow(float targetForce, float forceRange, float successTime)
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
      ratio = (df / forceRange);
    }
    
    println(ratio);
    
    fill(red);
    if(abs(ratio) < 1) fill(green);
    else if (ratio > 0) fill(red);
    rect(0, 0, height, width);
    
    
  }
}
