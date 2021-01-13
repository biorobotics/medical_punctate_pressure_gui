// import libraries
import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*; // http://www.sojamo.de/libraries/controlP5/
import processing.serial.*;
// interface stuff
ControlP5 cp5;
JSONObject plotterConfigJSON;

// If you want to debug the plotter without using a real serial port set this to true
// TODO: make mockupSerial work
boolean mockupSerial = false;

// Serial variables
Serial port;      // The serial port
String inString;  // Input string from serial port
boolean newString = false; // Whether a new string is available
int lf = 10;      // ASCII linefeed

// Button variables
color currentcolor;
color fontcolor;
RectButton rect1; //vibration

Distance dist;
Temp temp;
LogButton log;
LogButton start;
boolean locked = false;
String readVal;
Toggle tog1;
Toggle tog2;

float forceData = 0;
int tempData = 0;

String s = "25";
int yspacing = 40;
int xspacing = 4;

int goalTemp;
int prevGoalTemp;
color baseColor = color(50);
boolean vMode = false;
HScrollbar hs1;  
PFont font;

String d = String.valueOf(day());    // Values from 1 - 31
String m = String.valueOf(month());  // Values from 1 - 12
String y = String.valueOf(year());   // 2003, 2004, 2005, etc.
String h = String.valueOf(hour());
String mi = String.valueOf(minute());
String sec = String.valueOf(second());


String date = "Date: " + m + "-" + d + "-" + y;
String time = "Time: " + h + ":" + mi;

// plots
Graph LineGraph = new Graph(225, 460, 600, 200, color (20, 20, 200));
float[][] lineGraphValues = new float[2][100]; // was 6
float[] lineGraphSampleNumbers = new float[100];
color[] graphColors = new color[2]; //was 6

// hing path
String topSketchPath = "";

void setup() {
   //set up window
   surface.setTitle("Punctate Pressure Interface");
   size(1000,800);
   font = loadFont("Verdana-20.vlw");
   textFont(font,50);

   currentcolor = baseColor;
   //port = new Serial(this, Serial.list()[1], 9600);

   fontcolor = 255;
   //int x = 30;
   //int y = 200;
   int size = 20;
   color buttoncolor = color(100,100,200);
   //color buttoncolor2 = color(1,1,1);
   color highlight = color(0,0,255);
   rect1 = new RectButton(100+xspacing*7, 85+6*yspacing/5, size, buttoncolor, highlight);
   start = new LogButton(400, 370, "hello.txt","start", buttoncolor, highlight);
   prevGoalTemp = goalTemp;
   noStroke();
   hs1 = new HScrollbar(240, 65 + yspacing, 190, 16, 1);
   dist = new Distance(120+xspacing*20, 70 + 3*yspacing, 100);
   temp = new Temp(153+ xspacing*40, 70, 100);
   log = new LogButton(510, 370, "hello.txt", "log",buttoncolor, highlight);

   // set line graph colors
    graphColors[0] = color(131, 255, 20);
    graphColors[1] = color(232, 158, 12);
    //graphColors[2] = color(255, 0, 0);
    //graphColors[3] = color(62, 12, 232);
    //graphColors[4] = color(13, 255, 243);
    //graphColors[5] = color(200, 46, 232);

    // settings save file  
    topSketchPath = sketchPath();
    plotterConfigJSON = loadJSONObject(topSketchPath+"/plotter_config.json");

    // gui
    cp5 = new ControlP5(this);
    
    // build x axis values for the line graph
    for (int i=0; i<lineGraphValues.length; i++) {
      for (int k=0; k<lineGraphValues[0].length; k++) {
        lineGraphValues[i][k] = 0;
        if (i==0)
        lineGraphSampleNumbers[k] = k;
      }
    }
    
    // start serial communication
    if (!mockupSerial) {
      //String serialPortName = Serial.list()[3];
      port = new Serial(this, Serial.list()[0], 9600);
      //serialPort = new Serial(this, serialPortName, 115200);
    }
    else
      port = null;
      
    // build the gui for recording
    int x1 = 170;
    int y1 = 460;
    cp5.addTextfield("lgMaxY").setPosition(x1, y1-10).setText(getPlotterConfigString("lgMaxY")).setWidth(40).setAutoClear(false);
    cp5.addTextfield("lgMinY").setPosition(x1, y1=y1+185).setText(getPlotterConfigString("lgMinY")).setWidth(40).setAutoClear(false);
      
    cp5.addTextlabel("label").setText("on/off").setPosition(x1=13, y1=y1-160).setColor(255);
    cp5.addTextlabel("multipliers").setText("multipliers").setPosition(x1=55, y1).setColor(255);
    cp5.addTextfield("lgMultiplier1").setPosition(60, y1=y1+30).setText(getPlotterConfigString("lgMultiplier1")).setColorCaptionLabel(255).setWidth(40).setAutoClear(false);
    cp5.addTextfield("lgMultiplier2").setPosition(60, y1=y1+40).setText(getPlotterConfigString("lgMultiplier2")).setColorCaptionLabel(255).setWidth(40).setAutoClear(false);
   
    tog1 = cp5.addToggle("lgVisible1").setPosition(x1 = 13, y1=y1-40).setValue(int(getPlotterConfigString("lgVisible1"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[0]);
    tog2 = cp5.addToggle("lgVisible2").setPosition(x1 = 13, y1=y1+40).setValue(int(getPlotterConfigString("lgVisible2"))).setMode(ControlP5.SWITCH).setColorActive(graphColors[1]);
}
 
byte[] inBuffer = new byte[100]; // holds serial message
int i = 0; // loop variable

void draw() {
  background(20);
  // * Read serial and update values */
  if ((mockupSerial || port.available() > 0) && start.on) {
    String myString = "";
    if (!mockupSerial) {
      try {
        port.readBytesUntil('\r', inBuffer);
      }
      catch (Exception e) {
      }
      myString = new String(inBuffer);
    }
    else {
      myString = mockupSerialFunction();
    }
    println(myString);

    // split the string at delimiter (space)
    String[] nums = split(myString, ' ');
    println(nums.length);
    
    // count number of bars and line graphs to hide
    int numberOfInvisibleLineGraphs = 0;
    for (i=0; i<6; i++) {
      if (int(getPlotterConfigString("lgVisible"+(i+1))) == 0) {
        numberOfInvisibleLineGraphs++;
      }
    }
    
    for (i=0; i<nums.length; i++) {
      // update line graph
      try {
        if (i<lineGraphValues.length) {
          for (int k=0; k<lineGraphValues[i].length-1; k++) {
            lineGraphValues[i][k] = lineGraphValues[i][k+1];
          }

          lineGraphValues[i][lineGraphValues[i].length-1] = float(nums[i])*float(getPlotterConfigString("lgMultiplier"+(i+1)));
        }
      }
      catch (Exception e) {
      }
    }
  }
  
  // draw the line graphs
  LineGraph.DrawAxis();
  for (int i=0;i<lineGraphValues.length; i++) {
    LineGraph.GraphColor = graphColors[i];
    if (int(getPlotterConfigString("lgVisible"+(i+1))) == 1)
      LineGraph.LineGraph(lineGraphSampleNumbers, lineGraphValues[i]);
  }
  
  // draw date and time
  fill(220);
  noStroke();
  rect(0, 0, width-1, 20 + 15);
  rect(0, 230, width - 1, 4);
  rect(0, 0, xspacing * date.length() * 5, 20 + 15);
  fill(0);
  rect(300, 0, 2, 50);
  fill(0);
  textSize(20);
  textAlign(LEFT);
  text(date , 30, 70 - yspacing);
 
  // time
  h = String.valueOf(hour());
  mi = String.valueOf(minute());
  time = "Time: " + h + ":" + mi;
  fill(0);
  textSize(20);
  text(time , 30 + xspacing * date.length() * 4 + yspacing, 70 - yspacing);  

   
  // draw vibration
  rect1.display();
  fill(fontcolor);
  text("vibration", 30, 70 + 2*yspacing);
   
   
  // goal temp;
  fill(fontcolor);
  text("Goal Temperature: ", 30, 70);
  rect1.update();
  hs1.update2();
  hs1.display2();
   
  goalTemp = hs1.getTemp();
  if (goalTemp != prevGoalTemp) {
    port.write(goalTemp);
    prevGoalTemp = goalTemp;
  }
   
  fill(fontcolor);
  temp.display();
   
   
  // current temp
  text("Current Temperature: ", 350, 250 + 30);
  while (port.available() > 0) {
    s = port.readString();
  }   
   
  //println(s);
  if ( float(s) < 60 && float(s) > 10) {
    tempData = int(float(s));
  }
  else if ( float(s) > 20 && float(s) < 1024) {
    forceData = float(s);
  }
  //println(forceData);

  text(tempData, 350, 250 + yspacing + 30);
   
   
  // draw distance
  fill(fontcolor);
  text("distance: ", 30, 70 + 3*yspacing);
  dist.display();
   
  //draw force sensor reading
  fill(fontcolor);
  text("force sensor reading: ", 30, 70 + 4 * yspacing + 20 + 30);
  text(int(forceData), 30 + xspacing * 10, 70 + 5 * yspacing + 20 + 30);
  delay(20);
   
  // log
  log.display();
  log.update();
   
  // draw start & stop
  start.display();start.update();
}
 
 
void serialEvent(Serial p) {
  inString = p.readString();
  newString = true;
}
 
void update(int x, int y) {
  
   if(locked == false) {
      if(mousePressed) {
        if(rect1.pressed()) { 
          if (rect1.am == false) {
            rect1.am = true;
            port.write("v");
          } else {
            rect1.am = false;
            port.write("nv");
          }
        } 
     }
     locked = false;
   } else {
      locked = false;
   }
   
//   if (!start.on){
//     tog1.setValue(0);
//     tog2.setValue(0);
//   }
}
 
class Distance {
  String input;
  String savedText;
  int x, y;
  int w;
  int h = yspacing*3/4;
  boolean selected;
  
  Distance(int ix, int iy, int iw) {
    x = ix;
    y = iy;
    w = iw;
    selected = false;
    savedText = "0";
    input = "";
  }
  
  boolean over() {
    if(overRect(x-w/2, y-h*3/4, w, h) ) {
       return true;
     } else {
       return false;
     }
   }
   void display() {
      noStroke();
      fill(100);
      rect(x-w/2, y-h*3/4, w, h);
      fill(fontcolor);
      if (selected) {
        text(input, x, y);
      } else {
        text(savedText, x, y);
      }
      textAlign(BASELINE);
   }
   
   void updateMouse() {
     if (over()) {
       selected = true;
     } else {
       selected = false;
     }
   }
   
   void updateKey(char k) {
     if (selected) {
       if (k == '\n') {
         selected = false;
         savedText = input;
         input = "";
       } else if  (k == BACKSPACE){
         input = input.substring(0, max(0, input.length()-1));
       } else {
         int num = k - '0';
         if (num >=0 && num <=9) {
           input = input + k;
         }
       }
     }
   }
}

class LogButton {
  String[] savedString;
  String filename;
  String name;
  int x;
  int y;
  int w, h;
  color basecolor, highlightcolor,currentcolor;
  boolean on = false;

  
  LogButton(int ix, int iy, String ifilename, String iname, color icolor, color ihighlight) {
    filename = ifilename;
    savedString = new String[1];
    x = ix;
    y = iy;
    w = yspacing*10/5 ;
    h = yspacing*3/4;
    highlightcolor = ihighlight;
    currentcolor = icolor;
    name = iname;
  }


  boolean over() {
   if(overRect(x-w/2, y-h*3/4, w, h) ) {
     return true;
   } else {
     //print(x-w/2, y-h*3/4, w, h);
    
     return false;
   }
  }
  
  void display() {
    noStroke();
    fill(currentcolor);
    rect(x-w/2, y-h*3/4, w, h);
    fill(fontcolor);
    text(name, x- w/4, y);
   }
   
   void update() {
      //println(currentcolor);

      if (over() && mousePressed){
        currentcolor = color(100);
        if (name == "start"){
          name = "stop";
          on = true;
        }else if (name == "stop"){
          name = "start";
          on = false;
        }
      }else if(over()) {
        currentcolor = color(190); 
      } else {
        currentcolor = basecolor;
      }
   }
   
  void updateMouse() {
   if (over()) {
     sec = String.valueOf(second());
     //println(time);
     filename = m+"-"+d+"-"+ String.valueOf(year()) + " at " + String.valueOf(hour()) + "." + mi + "." + sec;
     save(filename);
   }
 }
}

 
class Temp {
  String input;
  String savedText;
  int x, y;
  int w;
  int h = yspacing*3/4;
  boolean selected;
  
  Temp(int ix, int iy, int iw) {
    x = ix;
    y = iy;
    w = iw;
    selected = false;
    input = "";
  }
  
  boolean over() {
    if(overRect(x-w/2, y-h*3/4, w, h) ) {
       return true;
     } else {
       //print(x-w/2, y-h*3/4, w, h);
      
       return false;
     }
   }
   void display() {
      noStroke();
      fill(100);
      rect(x-w/2, y-h*3/4, w, h);
      fill(fontcolor);
      if (selected) {
        text(input, x, y);
      } else {
        text(goalTemp, x, y);
      }
      textAlign(BASELINE);
   }
   
   void updateMouse() {
     if (over()) {
       selected = true;
     } else {
       selected = false;
     }
   }
   
   void updateKey(char k) {
     if (selected) {
       if (k == '\n') {
         selected = false;
         if (int(input) < 50) {
           goalTemp = int(input);
           goalTemp = min(41, max(25,goalTemp));  //bound in 25 to 
           hs1.updateGoal(goalTemp);
         }
         input = "";
       } else if  (k == BACKSPACE){
         input = input.substring(0, max(0, input.length()-1));
       } else {
         int num = k - '0';
         if (num >=0 && num <=9) {
           input = input + k;
         }
       }
     }
   }
}

class Button {
   int x, y;
   int size;
   color basecolor, highlightcolor;
   color currentcolor;
   boolean over = false;
   boolean pressed = false;
   boolean am;
   
   void update() {
      if(over()) {
        currentcolor = highlightcolor;
      } else {
         currentcolor = basecolor;
      }
   }
   boolean pressed() {
      if(over) {
          locked = true;
          return true;
      } else {
          locked = false;
          return false;
      }
   }
   boolean over() {
      return true;
   }
   void display() {
   }
}
 
class RectButton extends Button {
   RectButton(int ix, int iy, int isize, color icolor, color ihighlight) {
      x = ix;
      y = iy;
      size = isize;
      basecolor = icolor;
      highlightcolor = ihighlight;
      currentcolor = basecolor;
      am = false;
   }
   boolean over() {
      if( overRect(x, y, size, size) ) {
         over = true;
         return true;
       } else {
         over = false;
         return false;
       }
    }
    
   void display() {
      noStroke();

      if (am || (currentcolor == highlightcolor)) {
        fill(currentcolor);
      } else {
        fill(255);
      }
      rect(x, y, size, size);
   }

}

boolean overRect(int x, int y, int width, int height) {
   if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) {
      return true;
   } else {
      return false;
   }
}

class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked2;
  float ratio;
  int minTemp;
  int maxTemp;

  HScrollbar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
    minTemp = 25;
    maxTemp = 41;
  }

  void update2() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked2 = true;
    }
    if (!mousePressed) {
      locked2 = false;
    }
    if (locked2) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display2() {
    noStroke();
    fill(204);
    rect(xpos, ypos, swidth, sheight);
    if (over || locked2) {
      fill(60, 60, 60);
    } else {
      fill(102, 102, 102);
    }
    rect(spos, ypos, sheight, sheight);
    labelScrollbar();
  }

  float getPos() {
    return spos * ratio;
  }
  
  int getTemp(){
    return int((spos - sposMin)/(sposMax- sposMin) * (maxTemp - minTemp) + minTemp);
  }
  void updateGoal(int goal) {
    newspos = int((goal - minTemp) * (sposMax - sposMin) / (maxTemp - minTemp) + sposMin);
    spos = newspos;
    if (getTemp() > goalTemp) {
      spos -= (sposMax - sposMin) / (maxTemp - minTemp);
      newspos = spos;
    } else if (getTemp() < goalTemp) {
      spos += (sposMax - sposMin) / (maxTemp - minTemp);
      newspos = spos;
    }
    println("updated!!");
  }
  
  void labelScrollbar(){
    fill(255);
    textAlign(CENTER, BOTTOM);
    text(minTemp, xpos - 20, ypos + sheight);
    text(maxTemp, xpos + swidth + 20, ypos + sheight);
    textAlign(BASELINE);
   }
}


void mousePressed() {
  println(mouseX, ", ", mouseY);
  update(mouseX, mouseY);
  dist.updateMouse();
  temp.updateMouse();
  log.updateMouse();
  
}

void keyPressed() {
  if (key == 'v') {
    port.write("v");
  } else if ( key == 'n') {
    port.write("nv");
  } else {
    dist.updateKey(key);
    temp.updateKey(key);
  }
}

// called each time the chart settings are changed by the user 
void setChartSettings() {
  LineGraph.xLabel=" Samples ";
  LineGraph.yLabel="Value";
  LineGraph.Title="";  
  LineGraph.xDiv=20;  
  LineGraph.xMax=0; 
  LineGraph.xMin=-100;  
  LineGraph.yMax=int(getPlotterConfigString("lgMaxY")); 
  LineGraph.yMin=int(getPlotterConfigString("lgMinY"));
}

// handle gui actions
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isAssignableFrom(Textfield.class) || theEvent.isAssignableFrom(Toggle.class) || theEvent.isAssignableFrom(Button.class)) {
    String parameter = theEvent.getName();
    String value = "";
    if (theEvent.isAssignableFrom(Textfield.class))
      value = theEvent.getStringValue();
    else if (theEvent.isAssignableFrom(Toggle.class) || theEvent.isAssignableFrom(Button.class))
      value = theEvent.getValue()+"";

    plotterConfigJSON.setString(parameter, value);
    saveJSONObject(plotterConfigJSON, topSketchPath+"/plotter_config.json");
  }
  setChartSettings();
}

// get gui settings from settings file
String getPlotterConfigString(String id) {
  String r = "";
  try {
    r = plotterConfigJSON.getString(id);
  } 
  catch (Exception e) {
    r = "";
  }
  return r;
}
