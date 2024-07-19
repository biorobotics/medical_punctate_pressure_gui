// import libraries
import java.awt.Frame;
import java.awt.BorderLayout;
import processing.serial.*;
import processing.sound.*;
import java.util.Random;
import java.util.List;
import java.util.Arrays;
import java.util.Collections;
  
// Safety + Sound variables
processing.sound.SinOsc osc;
float maxForce = 7;

// Experiment varialbes
float successTime = 0.3;
float[] trialForces = {1, 1.67, 2.34, 3.01};

// Serial variables
Serial port;      // The serial port
String inString;  // Input string from serial port
boolean newString = false; // Whether a new string is available
int lf = 10;      // ASCII linefeed

// Button variables
color fontcolor = 255;

// Data variables
float rawForceData = 0;
float forceData = 0;
float forceZero = 0.0;
float tempData = 0;
boolean markPoint;
int subjectNo = 0;
int locationNo = 0;
int trialNo = 0;


// Other windows
PressureWindow pressureWindow;

// Button and recording objects
Vibration b_vibrate;
Label b_currentTemp;
Label b_currentForce;
Recording b_recording;
SerialDropdown b_serialDropdown;
GuiDropdown b_guiDropdown; //<>//
TextBox b_temp, b_targetForce, b_forceRange, b_beepForce, b_subjectNumber, b_trialNumber, b_locationNumber;
Checkbox b_randomizedTrial;
ZeroSensor b_zeroSensor;

int yspacing = 40;
int xspacing = 4;

int goalTemp = 27;
color baseColor = color(50);
boolean vMode = false;

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
  
  PFont font = loadFont("Verdana-20.vlw");
  textFont(font, 50);
  
  pressureWindow = new PressureWindow(1, 0.5, successTime);
  
  b_serialDropdown = new SerialDropdown(xspacing, lineheight, 600, "SerialPort", this);
  lineheight += yspacing;
  b_guiDropdown = new GuiDropdown(xspacing, lineheight, 600, "Force GUI", this);
  lineheight += yspacing;
  b_temp = new TextBox(xspacing, lineheight, 100, "Goal temperature");
  lineheight += yspacing;
  b_currentTemp = new Label(xspacing, lineheight, 100, "Current temperature");
  lineheight += yspacing;
  b_currentForce = new Label(xspacing, lineheight, 100, "Current force");
  lineheight += yspacing;
  b_targetForce = new TextBox(xspacing, lineheight, 100, "Target force");
  b_targetForce.input = str(pressureWindow.targetForce);
  lineheight += yspacing;
  b_forceRange = new TextBox(xspacing, lineheight, 100, "Target force range");
  b_forceRange.input = str(pressureWindow.forceRange);
  lineheight += yspacing;
  b_beepForce = new TextBox(xspacing, lineheight, 100, "Beep force");
  b_beepForce.input = str(maxForce);
  lineheight += yspacing;
  b_vibrate = new Vibration(xspacing, lineheight, yspacing, "Vibration");
  lineheight += yspacing;
  b_recording = new Recording(xspacing, lineheight, 125, "Recording");
  lineheight += yspacing;
  b_zeroSensor = new ZeroSensor(xspacing, lineheight, 100, "Zero sensor");
  lineheight += yspacing;
  b_randomizedTrial = new Checkbox(xspacing, lineheight, yspacing, "Randomized trial mode");
  lineheight += yspacing;
  b_subjectNumber = new TextBox(xspacing, lineheight, 100, "Subject number");
  b_subjectNumber.input = "0";
  b_subjectNumber.numeric = true;
  b_locationNumber = new TextBox(xspacing + 300, lineheight, 100, "Location number");
  b_locationNumber.input = "0";
  b_locationNumber.numeric = true;
  b_trialNumber = new TextBox(xspacing + 600, lineheight, 100, "Trial number");
  b_trialNumber.input = "0";
  b_trialNumber.numeric = true;
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
      rawForceData = float(fbk[1]);
      forceZero = b_zeroSensor.getZero();
      forceData = rawForceData - forceZero;
      b_recording.updateRecording(tempData, forceData, forceZero);
      b_zeroSensor.updateRecording(rawForceData);
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
  
  if(b_temp.updated & !b_randomizedTrial.selected) {
    if (b_temp.input.length() > 0) {
      goalTemp = int(b_temp.input);
      goalTemp = min(41, max(25, goalTemp));  //bound in 25 to
      if(port != null)
        port.write(String.format("%d\n",goalTemp));
    }
    b_temp.input = str(goalTemp);
    b_temp.updated = false;
  }
  
  if(b_targetForce.updated & !b_randomizedTrial.selected) {
    if (b_targetForce.input.length() > 0) {
      pressureWindow.setTargetForce(float(b_targetForce.input));
      pressureWindow.randomize();
    }
    b_targetForce.updated = false;
  }
  
  if(b_forceRange.updated & !b_randomizedTrial.selected) {
    if (b_forceRange.input.length() > 0) {
      pressureWindow.setForceRange(float(b_forceRange.input));
      pressureWindow.randomize();
    }
    b_forceRange.updated = false;
  }
  if(b_beepForce.updated) {
    if (b_beepForce.input.length() > 0) {
      maxForce = int(b_beepForce.input);
    }
    b_beepForce.updated = false;
  }
  
  if((b_subjectNumber.updated | b_trialNumber.updated | b_locationNumber.updated) &
     !(b_subjectNumber.selected | b_trialNumber.selected | b_locationNumber.selected)){
     int subject = int(b_subjectNumber.input);
     int trial = int(b_trialNumber.input);
     int location = int(b_locationNumber.input);
     if (trial >= trialForces.length)
       trial = trialForces.length;
     if (trial < 1)
       trial = 1;
     if (location < 1)
       location = 1;
     if (subject < 1)
       subject = 1;
     if (b_subjectNumber.updated)
       b_recording.writeInfo();
     b_subjectNumber.input = str(subject);
     b_locationNumber.input = str(location);
     b_trialNumber.input = str(trial);
     float targetForce = generateRandomTrialValue(subject, location, trial);
     b_targetForce.input = str(targetForce);
     pressureWindow.randomize();
     b_subjectNumber.updated = false;
     b_locationNumber.updated = false;
     b_trialNumber.updated = false;
  }

  
  // draw buttons and labels
    b_currentForce.setInput(str(forceData));
    b_currentForce.display();
    b_targetForce.display();
  b_vibrate.display();
  if (!b_randomizedTrial.selected) {
    b_temp.display();
    b_currentTemp.setInput(str(tempData));
    b_currentTemp.display();
    b_forceRange.display();
  } else {
    b_subjectNumber.display();
    b_locationNumber.display();
    b_trialNumber.display();
  }
  b_beepForce.display();
  b_recording.display();
  b_serialDropdown.display();
  b_guiDropdown.display();
  b_randomizedTrial.display();
  b_zeroSensor.display();

  // Update rate
  delay(10);

  // draw start & stop
  //start.display();start.update();
}

void serialEvent(Serial p) {
  inString = p.readString();
  newString = true;
}

void mousePressed() {
  println(mouseX, ", ", mouseY);
  if (!b_randomizedTrial.selected) {
    b_temp.updateMouse();
    b_targetForce.updateMouse();
  } else {
    b_subjectNumber.updateMouse();
    b_locationNumber.updateMouse();
    b_trialNumber.updateMouse();
  }
  b_forceRange.updateMouse();
  b_beepForce.updateMouse();
  b_vibrate.updateMouse();
  b_recording.updateMouse();
  b_serialDropdown.updateMouse();
  b_guiDropdown.updateMouse();
  b_randomizedTrial.updateMouse();
  b_zeroSensor.updateMouse();
  
}

void keyPressed(KeyEvent event) {
  if (keyCode == 67) { // C KEY 
    markPoint = true;
  }
  if (!b_randomizedTrial.selected) {
    b_temp.updateKey(key);
    b_targetForce.updateKey(key);
    b_forceRange.updateKey(key);
  } else {
    b_subjectNumber.updateKey(key);
    b_locationNumber.updateKey(key);
    b_trialNumber.updateKey(key);
  }
  b_beepForce.updateKey(key);
}

void mouseWheel(MouseEvent event) {
  int e = event.getCount();
  b_serialDropdown.scroll(e);
  b_guiDropdown.scroll(e);
}

float generateRandomTrialValue(int subjectNumber, int locationNumber, int trialNumber) {
  Random r = new Random(subjectNumber << 16 + locationNumber);
  List<Float> arrayCopy = new ArrayList<Float>();
  for(int i=0; i< trialForces.length; i++) {
    arrayCopy.add(trialForces[i]);
  }
  Collections.shuffle(arrayCopy, r);
  return arrayCopy.get(trialNumber - 1);
}
