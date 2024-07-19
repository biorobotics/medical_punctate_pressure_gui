import java.util.TimeZone;
import java.util.Calendar;

Calendar calendar;

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
  
  void display(String textToShow) {
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
      text(textToShow, x + labelwidth + w/2 - textWidth(textToShow) / 2, centerheight);
    } else {
      text(textToShow, x + labelwidth, centerheight);
    }
  }
  
  void display() {
    display(input);
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

class Checkbox extends Label {
  boolean selected = false;
  
  Checkbox(int ix, int iy, int iw, String ilabel) {
    super(ix, iy, iw, ilabel);
    selected = false;
    inputbg = color(200, 100, 100);
  }
  
  void updateMouse() {
    if (over()) {
      selected = !selected;
      if(selected) {
        inputbg = color(100, 200, 100);
      } else {
        inputbg = color(200, 100, 100);
      }
    }
  }
  
}

class ZeroSensor extends Label{
  ArrayList<Float> buffer;
  float zeroValue;
  boolean recording = false;
  int bufferMax = 50;
  
  ZeroSensor(int ix, int iy, int iw, String ilabel) {
    super(ix, iy, iw, ilabel);
    buffer = new ArrayList<Float>();
    centered = true;
  }
  
  
  void updateMouse() {
    if (over()) {
      recording = true;
      buffer.clear();
      println(buffer.size());
    }
  }
  
  float getZero() {
    if (buffer.size() == 0)
      return 0.0;
    float sum = 0;
    for (float v : buffer)
      sum += v;
    return sum / buffer.size();
  }
  
  void display() {
    if (buffer.size() == 0)
      inputbg = color(200, 100, 100);
    else if (buffer.size() >= bufferMax)
        inputbg = color(100, 200, 100);
    else
        inputbg = color(50);
     super.display(nf(getZero(), 0,3));
  }
  
  void updateRecording(float in) {
    if(!recording)
      return;
    buffer.add(in);
    if (buffer.size() >= bufferMax) {
      recording = false;
      input = nf(getZero(), 0, 3);
    }
  }
  
}   

class Vibration extends Checkbox{
  
  Vibration(int ix, int iy, int iw, String ilabel) {
    super(ix, iy, iw, ilabel);
  }
  
  void updateMouse() {
    super.updateMouse();
    if (over()) {
      if (port != null) {
        port.write(selected ? "nv\n" : "v\n");
      }
    }
  }
  
}

class TextBox extends Label {
  boolean selected;
  boolean numeric;
  boolean updated = false;
  String currentInput;

  TextBox(int ix, int iy, int iw, String ilabel) {
    super(ix, iy, iw, ilabel);
    input = "";
    currentInput = "";
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
      updateKey('\n');
    }
  }
  
  boolean validateInput(String val) {
    if(val == "")
      return false;
    return true;
  }
  
  void updateKey(char k) {
    if (selected) {
      if (k == '\n') {
        selected = false;
        updated = true;
        inputbg = color(50);
        if(validateInput(currentInput))
          input = currentInput;
        currentInput = "";
      } else if  (k == BACKSPACE) {
        currentInput = currentInput.substring(0, max(0, currentInput.length()-1));
      } else {
        int num = k - '0';
        if (!numeric) {
          currentInput = currentInput + k;
        } else if(num >=0 && num <=9) {
          currentInput = currentInput + k;
        }
      }
    }
  }
  
  void display() {
    int labelwidth = int(textWidth(label));
    int cursorPadding = int((yspacing - yspacing * 0.7) / 2);
    if (selected) {
      super.display(currentInput);
      if(centered)
        rect(x + labelwidth + w/2 + textWidth(currentInput) / 2 + 3, y + cursorPadding, 2, yspacing - cursorPadding * 2);
      else
        rect(x + labelwidth + textWidth(currentInput) + 3, y + cursorPadding, 2, yspacing - cursorPadding * 2);
    } else {
      super.display(); 
    }
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
        float targetForceSet = float(b_targetForce.input);
        float forceRangeSet = float(b_forceRange.input);
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
  
  void writeInfo() {
    if(recording) {
        String infoLine = "Subject: " + b_subjectNumber.input;
        infoLine += " Goal temperature: " + nf(goalTemp);
        infoLine += " Force range: " + b_forceRange.input;
        infoLine += " Beep force: " + b_beepForce.input;
        output.println(infoLine);
        String firstLine = "Date, Temperature, Force, Zero, Mark, Vibration, Target Force, Subject, Location, Trial";
        output.println(firstLine);
    }
  }
  
  void updateMouse() {
    if (over()) {
      recording = !recording;
      if(recording) {
        output = createWriter(filenameGen()); 
        startTime = currentSec();
        inputbg = color(200, 100, 100);
        writeInfo();
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
  
  void updateRecording(float temp, float force, float zero) {
    if (recording) {
      // Display time
      int secs = currentSec() - startTime;
      input = nf(secs / 60 / 60 % 60, 2) + ":" + nf(secs / 60 % 60, 2) + ":" + nf(secs % 60, 2);
      // Recording line
      calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
      float seconds = calendar.get(Calendar.SECOND) + calendar.get(Calendar.MILLISECOND) / 1000.0;
      String date = nf(year(), 4) + "-" + nf(month(), 2) + "-" + nf(day(), 2) + " " + nf(hour(),2) + ":" + nf(minute(), 2) + ":" + nf(seconds, 2, 3); 
      String nextLine = date + ", " + nfs(temp, 3, 3) + ", " + nfs(force, 3, 3) + ", " + nfs(zero, 3, 3) + ", ";
      if (markPoint) {
        nextLine += "MARK, ";
      }
      else {
        nextLine += " , ";
      }
      if (b_vibrate.selected) {
        nextLine += "True, ";
      }
      else {
        nextLine += "False, ";
      }
      Label[] toRecord =  new Label[] {b_targetForce, b_subjectNumber, b_locationNumber, b_trialNumber};
      for (Label b : toRecord) {
         nextLine += b.input + ", ";
      }
      output.println(nextLine);
    }
    markPoint = false;
  }
  
}
