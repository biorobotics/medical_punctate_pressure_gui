static final String RENDERER = JAVA2D;

static final void setDefaultClosePolicy(PApplet pa, boolean keepOpen) {
  final Object surf = pa.getSurface().getNative();
  final PGraphics canvas = pa.getGraphics();

  if (canvas.isGL()) {
    final com.jogamp.newt.Window w = (com.jogamp.newt.Window) surf;

    for (com.jogamp.newt.event.WindowListener wl : w.getWindowListeners())
      if (wl.toString().startsWith("processing.opengl.PSurfaceJOGL"))
        w.removeWindowListener(wl); 

    w.setDefaultCloseOperation(keepOpen?
      com.jogamp.nativewindow.WindowClosingProtocol.WindowClosingMode
      .DO_NOTHING_ON_CLOSE :
      com.jogamp.nativewindow.WindowClosingProtocol.WindowClosingMode
      .DISPOSE_ON_CLOSE);
  } else if (canvas instanceof processing.awt.PGraphicsJava2D) {
    final javax.swing.JFrame f = (javax.swing.JFrame)
      ((processing.awt.PSurfaceAWT.SmoothCanvas) surf).getFrame(); 

    for (java.awt.event.WindowListener wl : f.getWindowListeners())
      if (wl.toString().startsWith("processing.awt.PSurfaceAWT"))
        f.removeWindowListener(wl);

    f.setDefaultCloseOperation(keepOpen?
      f.DO_NOTHING_ON_CLOSE : f.DISPOSE_ON_CLOSE);
  }
}

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
  
  public void setup() {
    setDefaultClosePolicy(this, false); 
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
  
  public void setForceRange(float f) {
    forceRange = f;
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
