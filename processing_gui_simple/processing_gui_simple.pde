// import libraries
import java.awt.Frame;
import java.awt.BorderLayout;
import java.util.Calendar;
import java.util.TimeZone;
import processing.serial.*;
import processing.sound.*;


  
// Force + Sound variables
processing.sound.SinOsc osc;
float maxForce = 7;
float successTime = 0.3;

// Serial variables
Serial port;      // The serial port
String inString;  // Input string from serial port
boolean newString = false; // Whether a new string is available
int lf = 10;      // ASCII linefeed

// Button variables
color currentcolor;
color fontcolor;

// Recording variables
float forceData = 0;
float tempData = 0;
Calendar calendar;
boolean markPoint;

// Other windows
PressureWindow pressureWindow;

// Button and recording objects
Vibration vibrate;
Label currentTemp;
Label currentForce;
Recording recording;
SerialDropdown serialDropdown;
GuiDropdown guiDropdown; //<>//
TextBox temp, targetForce, forceRange, beepForce;

int yspacing = 40;
int xspacing = 4;

int goalTemp = 27;
color baseColor = color(50);
boolean vMode = false;
PFont font;

String d = String.valueOf(day());    // Values from 1 - 31
String m = String.valueOf(month());  // Values from 1 - 12
String y = String.valueOf(year());   // 2003, 2004, 2005, etc.
String h = String.valueOf(hour());
String mi = String.valueOf(minute());
String sec = String.valueOf(second());


String date = "Date: " + m + "-" + d + "-" + y;
String time = "Time: " + h + ":" + mi;

// hing path
String topSketchPath = "";

String[] record;

int lineheight = yspacing;

void settings() {
  size(1000, 800);
  osc = new processing.sound.SinOsc(this);
  osc.amp(.1);
}

void setup() {
  
  //set up window
  surface.setTitle("Punctate Pressure Interface");
  surface.setResizable(true);
  
  font = loadFont("Verdana-20.vlw");
  textFont(font, 50);

  currentcolor = baseColor;
  fontcolor = 255;
  
  pressureWindow = new PressureWindow(1, 0.5, successTime);
  
  serialDropdown = new SerialDropdown(xspacing, lineheight, 600, "SerialPort", this);
  lineheight += yspacing;
  guiDropdown = new GuiDropdown(xspacing, lineheight, 600, "Force GUI", this);
  lineheight += yspacing;
  temp = new TextBox(xspacing, lineheight, 100, "Goal temperature");
  lineheight += yspacing;
  currentTemp = new Label(xspacing, lineheight, 100, "Current temperature");
  lineheight += yspacing;
  currentForce = new Label(xspacing, lineheight, 100, "Current force");
  lineheight += yspacing;
  targetForce = new TextBox(xspacing, lineheight, 100, "Target force");
  targetForce.input = str(pressureWindow.targetForce);
  lineheight += yspacing;
  forceRange = new TextBox(xspacing, lineheight, 100, "Target force range");
  forceRange.input = str(pressureWindow.forceRange);
  lineheight += yspacing;
  beepForce = new TextBox(xspacing, lineheight, 100, "Beep force");
  beepForce.input = str(maxForce);
  lineheight += yspacing;
  vibrate = new Vibration(xspacing, lineheight, yspacing, "Vibration");
  lineheight += yspacing;
  recording = new Recording(xspacing, lineheight, 125, "Recording");
  lineheight += yspacing;
}

void draw() {
  background(20);
  if(port == null && (pressureWindow.finished || pressureWindow.frameCount > 0))
  {
    // Fake force data using mouse
    float f = sqrt(pow(width - pressureWindow.mouseX,2) + pow(height - pressureWindow.mouseY,2)) / pressureWindow.width * pressureWindow.targetForce;
    inString = "FBK " + str(f) + " 0";
    newString = true;
  } 
  if (newString) {
    if (inString.length() > 4 && inString.substring(0, 3).equals("FBK")) {
      String[] fbk = split(inString, ' ');
      tempData = float(fbk[2]);
      forceData = float(fbk[1]);
      recording.updateRecording(tempData, forceData);
      pressureWindow.setForce(forceData);
      if(forceData > maxForce)
        osc.play();
      else
        osc.stop();
    }
    newString = false;
  }

  // draw date and time
  fill(220);
  noStroke();
  rect(0, 0, width-1, 20 + 15);
  rect(0, lineheight, width - 1, 4);
  rect(0, 0, xspacing * date.length() * 5, 20 + 15);
  fill(0);
  rect(300, 0, 2, 50);
  fill(0);
  textSize(20);
  textAlign(LEFT);
  text(date, 30, 70 - yspacing);

  // time
  h = String.valueOf(hour());
  mi = String.valueOf(minute());
  time = "Time: " + h + ":" + mi;
  fill(0);
  textSize(20);
  text(time, 50 + xspacing * date.length() * 4 + yspacing, 65 - yspacing);  
  
  // Update from user input
  
  if(temp.updated) {
    if (temp.input.length() > 0) {
      goalTemp = int(temp.input);
      goalTemp = min(41, max(25, goalTemp));  //bound in 25 to
      if(port != null)
        port.write(String.format("%d\n",goalTemp));
    }
    temp.input = str(goalTemp);
    temp.updated = false;
  }
  
  if(targetForce.updated) {
    if (targetForce.input.length() > 0) {
      pressureWindow.setTargetForce(float(targetForce.input));
      pressureWindow.randomize();
    }
    targetForce.updated = false;
  }
  
  if(forceRange.updated) {
    if (forceRange.input.length() > 0) {
      pressureWindow.setForceRange(float(forceRange.input));
      pressureWindow.randomize();
    }
    forceRange.updated = false;
  }
  if(beepForce.updated) {
    if (beepForce.input.length() > 0) {
      maxForce = int(beepForce.input);
    }
    beepForce.updated = false;
  }

  
  // draw buttons and labels
  vibrate.display();
  temp.display();
  currentTemp.setInput(str(tempData));
  currentTemp.display();
  currentForce.setInput(str(forceData));
  currentForce.display();
  targetForce.display();
  forceRange.display();
  beepForce.display();
  recording.display();
  serialDropdown.display();
  guiDropdown.display();

  // Update rate
  delay(10);

  // draw start & stop
  //start.display();start.update();
}

void serialEvent(Serial p) {
  inString = p.readString();
  newString = true;
}

void update(int x, int y) {
}


void mousePressed() {
  println(mouseX, ", ", mouseY);
  update(mouseX, mouseY);
  temp.updateMouse();
  targetForce.updateMouse();
  forceRange.updateMouse();
  beepForce.updateMouse();
  vibrate.updateMouse();
  recording.updateMouse();
  serialDropdown.updateMouse();
  guiDropdown.updateMouse();
}

void keyPressed(KeyEvent event) {
  temp.updateKey(key);
  if (keyCode == 67) { // C KEY 
    markPoint = true;
  }
  targetForce.updateKey(key);
  forceRange.updateKey(key);
  beepForce.updateKey(key);
}

void mouseWheel(MouseEvent event) {
  int e = event.getCount();
  serialDropdown.scroll(e);
  guiDropdown.scroll(e);
}

boolean overRect(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

class Label {
  int x, y, w, h;
  String label;
  String input;
  color inputbg;
  boolean centered;
  
  Label(int ix, int iy, int iw, String ilabel) {
    // Drawing variables
    x = ix;
    y = iy;
    w = iw;
    h = yspacing*3/4;
    label = ilabel + ": ";
    input = "";
    inputbg = color(20);
    centered = false;
  }
  
  void display() {
    int labelwidth = int(textWidth(label));
    int centerheight = y + yspacing / 2;
    fill(fontcolor);
    textAlign(LEFT, CENTER);
    text(label, x, centerheight);
    noStroke();
    fill(inputbg);
    rect(x + labelwidth, centerheight - h/2, w, h);
    fill(fontcolor);
    textAlign(LEFT, CENTER);
    if (centered) {
      text(input, x + labelwidth + w/2 - textWidth(input) / 2, centerheight);
    } else {
      text(input, x + labelwidth, centerheight);
    }
  }
  
  void setInput(String in) {
     input = in;
  }

  boolean over() {
    int labelwidth = int(textWidth(label));
    int centerheight = y + yspacing / 2;
    if (overRect(x + labelwidth, centerheight - h/2, w, h) ) {
      return true;
    } else {
      return false;
    }
  }
}

class Vibration extends Label{
  boolean selected;
  
  Vibration(int ix, int iy, int iw, String ilabel) {
    super(ix, iy, iw, ilabel);
    selected = false;
    inputbg = color(200, 100, 100);
  }
  
  void updateMouse() {
    if (over()) {
      selected = !selected;
      String text = "";
      if(selected) {
        text = "v\n";
        inputbg = color(100, 200, 100);
      } else {
        text = "nv\n";
        inputbg = color(200, 100, 100);
      }
      if (port != null)
        port.write(text);
    }
  }
  
}

class TextBox extends Label {
  boolean selected;
  String savedText;
  boolean clear;
  boolean numeric;
  boolean updated = false;

  TextBox(int ix, int iy, int iw, String ilabel) {
    super(ix, iy, iw, ilabel);
    input = "";
    clear = true;
    centered = true;
    inputbg = color(50);
    numeric = false;
  }
  
  void updateMouse() {
    if (over()) {
      inputbg = color(100);
      selected = true;
    } else {
      inputbg = color(50);
      selected = false;
      updateKey('\n');
    }
  }
  
  void updateKey(char k) {
    if (selected) {
      if (k == '\n') {
        selected = false;
        clear = false;
        updated = true;
        inputbg = color(50);
      } else if  (k == BACKSPACE) {
        input = input.substring(0, max(0, input.length()-1));
      } else {
        if(!clear) { 
          input = "";
          clear = true;
        }
        int num = k - '0';
        if (!numeric) {
          input = input + k;
        } else if(num >=0 && num <=9) {
          input = input + k;
        }
      }
    }
  }
  
  void display() {
    super.display();
    int labelwidth = int(textWidth(label));
    int centerheight = y + yspacing / 2;
    int cursorPadding = int((yspacing - yspacing * 0.7) / 2);
    if (selected && centered) {
      rect(x + labelwidth + w/2 + textWidth(input) / 2 + 3, y + cursorPadding, 2, yspacing - cursorPadding * 2);
    } else if(selected) {
      rect(x + labelwidth + textWidth(input) + 3, y + cursorPadding, 2, yspacing - cursorPadding * 2);
    }
  }
  
}

class Recording extends Label {
  boolean recording;
  int startTime; 
  PrintWriter output;

  Recording(int ix, int iy, int iw, String ilabel) {
    super(ix, iy, iw, ilabel);
    startTime = currentSec();
    input = "00:00:00";
    centered = true;
    inputbg = color(50);
    recording = false;
  }
  
  int currentSec() {
    return hour() * 60 * 60 + minute() * 60 + second();
  }
  
  void updateMouse() {
    if (over()) {
      recording = !recording;
      if(recording) {
        output = createWriter(filenameGen()); 
        startTime = currentSec();
        inputbg = color(200, 100, 100);
        String infoLine = "Goal temperature: " + nf(goalTemp);
        infoLine += " Target force: " + targetForce.input;
        infoLine += " Force range: " + forceRange.input;
        infoLine += " Beep force: " + beepForce.input;
        output.println(infoLine);
        String firstLine = "Date, Temperature, Force, Mark, Vibration";
        output.println(infoLine);
      } else {
        inputbg = color(50);
        output.flush(); // Writes the remaining data to the file
        output.close(); // Finishes the file
      }
    }
  }
  
  String filenameGen() {
    return nf(year(), 4) + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "_" + nf(hour(),2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2) + ".csv";
  }
  
  void updateRecording(float temp, float force) {
    if (recording) {
      // Display time
      int secs = currentSec() - startTime;
      input = nf(secs / 60 / 60 % 60, 2) + ":" + nf(secs / 60 % 60, 2) + ":" + nf(secs % 60, 2);
      // Recording line
      calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
      float seconds = calendar.get(Calendar.SECOND) + calendar.get(Calendar.MILLISECOND) / 1000.0;
      String date = nf(year(), 4) + "-" + nf(month(), 2) + "-" + nf(day(), 2) + " " + nf(hour(),2) + ":" + nf(minute(), 2) + ":" + nf(seconds, 2, 3); 
      String nextLine = date + ", " + nfs(temp, 3, 3) + ", " + nfs(force, 3, 3) + ", ";
      if (markPoint) {
        nextLine += "MARK, ";
      }
      else {
        nextLine += " , ";
      }
      if (vibrate.selected) {
        nextLine += "True";
      }
      else {
        nextLine += "False";
      }
      output.println(nextLine);
    }
    markPoint = false;
  }
  
}

class Dropdown extends Label {
  int index;
  int selected;
  String[] options;
  boolean dropped;
  PApplet parent;
  int scroll_offset;

  Dropdown(int ix, int iy, int iw, String ilabel, PApplet app) {
    super(ix, iy, iw, ilabel);
    index = 0;
    centered = false;
    dropped = false;
    inputbg = color(50);
    getOptions();
    input = "";
    selected = -1;
    parent = app;
    scroll_offset = 0;
  }

  void getOptions() {
    return;
  }
  
  int getIndex() {
    int centerheight = y + yspacing / 2;
    if(over()) {
      for (int i = 0; i < options.length; i += 1) {
        if(mouseY > centerheight - h/2 + h * (i + 1) &&
           mouseY < centerheight - h/2 + h * (i + 2)) {
          return i;
        }
      }
   }
   return -1;
  }

  void display() {
    super.display();
    int labelwidth = int(textWidth(label));
    int centerheight = y + yspacing / 2;
    fill(fontcolor);
    rect(x + labelwidth + w - h, centerheight - h/2, h, h);
    fill(inputbg);
    beginShape();
    float angle = TWO_PI / 3;
    float offset = -PI/6;
    for (float a = 0; a < TWO_PI; a += angle) {
      float sx = x + labelwidth + w - h/2 + cos(a + offset) * h / 4;
      float sy = centerheight + sin(a + offset) * h / 4;
      vertex(sx, sy);
    }
    endShape(CLOSE);

    if (dropped)
    {
      selected = getIndex();
      fill(inputbg);
      int n_lines = 0;
      for (String element : subset(options, scroll_offset)) {
        n_lines ++;
        if(n_lines % 2 == 0) {
          fill(inputbg);
        } else {
          fill(inputbg + color(10));
        }
        if(n_lines - 1 == selected) {
          fill(inputbg + color(50));
        }
        rect(x + labelwidth, centerheight - h/2 + h * n_lines, w, h);
        fill(fontcolor);
        text(element, x + labelwidth, centerheight + h * n_lines);
      }
    }
  }
  
  boolean over() {
    int labelwidth = int(textWidth(label));
    if (!dropped)
    {
      return super.over();
    } else {
      if (overRect(x + labelwidth, y + h, w, h * options.length)) {
        return true;
      }
    }
    return false;
  }
  
  void updateMouse() {
    return;
  }
  
  void scroll(int n) {
    scroll_offset += n;
    int max_offset = max(options.length - 3, 0);
    scroll_offset = constrain(scroll_offset, 0, max_offset);
  }
}

class SerialDropdown extends Dropdown {

  SerialDropdown(int ix, int iy, int iw, String ilabel, PApplet app) {
    super(ix, iy, iw, ilabel, app);
  }

  void getOptions() {
    options = Serial.list();
  }
  
  void updateMouse() {
    if (over()) {
      getOptions();
      if(dropped)
      {
        try{
          port = new Serial(parent, options[selected], 9600);
          port.bufferUntil(lf);
          input = options[selected];
        } catch(Exception e) {
          input = "FAILED TO OPEN SERIAL PORT";
          port = null;
          println(e);
        }
      } 
      dropped = !dropped;
      println(dropped);
    } else {
      dropped = false;
    }
  }
};

class GuiDropdown extends Dropdown {

  GuiDropdown(int ix, int iy, int iw, String ilabel, PApplet app) {
    super(ix, iy, iw, ilabel, app);
  }

  void getOptions() {
    options = new String[] {"None", "Circle", "Bar", "Green / Red"};
  }
  
  void updateMouse() {
    if (over()) {
      if(dropped)
      {
        float targetForceSet = float(targetForce.input);
        float forceRangeSet = float(forceRange.input);
        println(pressureWindow.frameCount);
        if (pressureWindow.frameCount > 0){
          pressureWindow.dispose();
        }
        if (options[selected] == "None") {
          pressureWindow = new PressureWindow(targetForceSet, forceRangeSet, successTime);
        }
        else if (options[selected] == "Circle") {
          pressureWindow = new PressureCircleWindow(targetForceSet, forceRangeSet, successTime);
        }
        else if (options[selected] == "Bar") {
          pressureWindow = new PressureWindowArrow(targetForceSet, forceRangeSet, successTime);
        }
        else if (options[selected] == "Green / Red") {
          pressureWindow = new PressureVelocityWindow(targetForceSet, forceRangeSet, successTime);
        }
        String[] args = {"PressureWindow"};
        PApplet.runSketch(args, pressureWindow);
      } 
      dropped = !dropped;
      println(dropped);
    } else {
      dropped = false;
    }
  }
};
