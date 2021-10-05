// import libraries
import java.awt.Frame;
import java.awt.BorderLayout;
import java.util.Calendar;
import java.util.TimeZone;
import processing.serial.*;

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

// Button and recording objects
Temp temp;
Vibration vibrate;
Label currentTemp;
Label currentForce;
Recording recording;

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

void setup() {
  for (String element : Serial.list()) { 
    println(element);
  }
  port = new Serial(this, "/dev/serial/by-id/usb-Arduino__www.arduino.cc__0043_55739323837351610172-if00", 9600);
  port.bufferUntil(lf);
  //set up window
  surface.setTitle("Punctate Pressure Interface");
  surface.setResizable(true);
  size(1000, 800);
  font = loadFont("Verdana-20.vlw");
  textFont(font, 50);

  currentcolor = baseColor;
  fontcolor = 255;

  color buttoncolor = color(100, 100, 200);
  color highlight = color(0, 0, 255);
  
  temp = new Temp(xspacing, lineheight, 100, "Goal temperature");
  lineheight += yspacing;
  currentTemp = new Label(xspacing, lineheight, 100, "Current temperature");
  lineheight += yspacing;
  currentForce = new Label(xspacing, lineheight, 100, "Current force");
  lineheight += yspacing;
  vibrate = new Vibration(xspacing, lineheight, yspacing, "Vibration");
  lineheight += yspacing;
  recording = new Recording(xspacing, lineheight, 125, "Recording");
  lineheight += yspacing;
}

void draw() {
  background(20);
  if (newString) {
    if (inString.length() > 4 && inString.substring(0, 3).equals("FBK")) {
      String[] fbk = split(inString, ' ');
      tempData = float(fbk[2]);
      forceData = float(fbk[1]);
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

  // log
  //log.display();
  //log.update();  

  // time
  h = String.valueOf(hour());
  mi = String.valueOf(minute());
  time = "Time: " + h + ":" + mi;
  fill(0);
  textSize(20);
  text(time, 50 + xspacing * date.length() * 4 + yspacing, 65 - yspacing);  


  // draw buttons and labels
  vibrate.display();
  temp.display();
  currentTemp.setInput(str(tempData));
  currentTemp.display();
  currentForce.setInput(str(forceData));
  currentForce.display();
  recording.updateRecording(tempData, forceData);
  recording.display();

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

  //if(locked == false) {
  //   if(mousePressed) {
  //     if(rect1.pressed()) { 
  //       if (rect1.am == false) {
  //         rect1.am = true;
  //         port.write("v");
  //       } else {
  //         rect1.am = false;
  //         port.write("nv");
  //       }
  //     } 
  //  }
  //  locked = false;
  //} else {
  //   locked = false;
  //}

  //   if (!start.on){
  //     tog1.setValue(0);
  //     tog2.setValue(0);
  //   }
}


void mousePressed() {
  println(mouseX, ", ", mouseY);
  update(mouseX, mouseY);
  temp.updateMouse();
  vibrate.updateMouse();
  recording.updateMouse();
}

void keyPressed() {
  temp.updateKey(key);
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
      if(selected) {
        inputbg = color(100, 200, 100);
        port.write("v\n");
      } else {
        port.write("nv\n");
        inputbg = color(200, 100, 100);
      }
    }
  }
  
}

class Temp extends Label {
  boolean selected;
  String savedText;
  boolean clear;

  Temp(int ix, int iy, int iw, String ilabel) {
    super(ix, iy, iw, ilabel);
    input = str(goalTemp);
    clear = false;
    centered = true;
    inputbg = color(50);
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
        if (input.length() > 0) {
          goalTemp = int(input);
          goalTemp = min(41, max(25, goalTemp));  //bound in 25 to
          port.write(String.format("%d\n",goalTemp));
        }
        input = str(goalTemp);
        inputbg = color(50);
      } else if  (k == BACKSPACE) {
        input = input.substring(0, max(0, input.length()-1));
      } else {
        if(!clear) { 
          input = "";
          clear = true;
        }
        int num = k - '0';
        if (num >=0 && num <=9) {
          input = input + k;
        }
      }
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
      } else {
        inputbg = color(50);
        output.flush(); // Writes the remaining data to the file
        output.close(); // Finishes the file
      }
    }
  }
  
  String filenameGen() {
    return nf(year(), 4) + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "_" + nf(hour(),2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2) + ".txt";
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
      String nextLine = date + ", " + nfs(temp, 3, 3) + ", " + nfs(force, 3, 3);
      output.println(nextLine);
      println(nextLine);
    }
  }
  
}
