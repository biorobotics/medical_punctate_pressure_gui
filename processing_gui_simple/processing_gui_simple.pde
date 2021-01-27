// import libraries
import java.awt.Frame;
import java.awt.BorderLayout;
import processing.serial.*;

// Serial variables
Serial port;      // The serial port
String inString;  // Input string from serial port
boolean newString = false; // Whether a new string is available
int lf = 10;      // ASCII linefeed

// Button variables
color currentcolor;
color fontcolor;

float forceData = 0;
float tempData = 0;

Temp temp;

int yspacing = 40;
int xspacing = 4;

int goalTemp = 27;
int prevGoalTemp = 0;
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

void setup() {
  for (String element : Serial.list()) { 
     println(element);
   }
   port = new Serial(this, Serial.list()[0], 9600);
   port.bufferUntil(lf);
   //set up window
   surface.setTitle("Punctate Pressure Interface");
   size(1000,800);
   font = loadFont("Verdana-20.vlw");
   textFont(font,50);

   currentcolor = baseColor;
   fontcolor = 255;
   //int x = 30;
   //int y = 200;
   int size = 20;
   color buttoncolor = color(100,100,200);
   //color buttoncolor2 = color(1,1,1);
   color highlight = color(0,0,255);
   
   
   temp = new Temp(153+ xspacing*40, 70, 100);
}

void draw() {
  background(20);
  if(newString) {
    if(inString.length() > 4 && inString.substring(0,3).equals("FBK")){
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
  fill(fontcolor);
  text("vibration", 30, 70 + 2*yspacing);
   
   
  // goal temp;
  fill(fontcolor);
  text("Goal Temperature: ", 30, 70);
  if (goalTemp != prevGoalTemp) {
    port.write(goalTemp + "\n");
    prevGoalTemp = goalTemp;
  }
   
  // current temp
  fill(fontcolor);
  temp.display();
  text("Current Temperature: ", 350, 250 + 30);
  text(tempData, 350, 250 + yspacing + 30);
   
   
  // draw distance
  fill(fontcolor);
  text("distance: ", 30, 70 + 3*yspacing);
  //dist.display();
   
  //draw force sensor reading
  fill(fontcolor);
  text("force sensor reading: ", 30, 70 + 4 * yspacing + 20 + 30);
  text(forceData, 30 + xspacing * 10, 70 + 5 * yspacing + 20 + 30);
  delay(10);
   
  // log
  //log.display();
  //log.update();
   
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
  
}

void keyPressed() {
  if (key == 'v') {
    port.write("v\n");
  } else if ( key == 'n') {
    port.write("nv\n");
  } else {
    temp.updateKey(key);
  }
}

boolean overRect(int x, int y, int width, int height) {
   if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) {
      return true;
   } else {
      return false;
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
