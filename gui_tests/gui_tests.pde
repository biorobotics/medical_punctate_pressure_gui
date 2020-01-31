import controlP5.*;

ControlP5 cp5;
Controller startButton;
Controller logButton;

int col = color(255);
boolean isRunning = false;

// plots
Graph LineGraph = new Graph(100, 100, 600, 200, color (20, 20, 200));
float[][] lineGraphValues = new float[2][100]; // was 6
float[] lineGraphSampleNumbers = new float[100];
color[] graphColors = new color[2]; //was 6

void setup() {
  size(400,400);
  smooth();
  cp5 = new ControlP5(this);
  
  // create a toggle
  startButton = cp5.addToggle("startStop")
                   .setLabel("Start")
                   .setPosition(40,40)
                   .setSize(50,20)
                   ;
     
  logButton =   cp5.addButton("logData")
                   .setLabel("Log")
                   .setPosition(100,40)
                   .setSize(50,20)
                   ;
     
}

void updateGraph() {
  for (int i=0; i<lineGraphValues.length; i++) {
    for (int k=0; k<lineGraphValues[i].length-1; k++) {
      lineGraphValues[i][k] = lineGraphValues[i][k+1];
    }
    lineGraphValues[i][lineGraphValues[i].length-1] = sin(second()/10);
  }
}

void draw() {
  background(0);
  
  updateGraph();
  
  // draw the line graphs
  LineGraph.DrawAxis();
  for (int i=0;i<lineGraphValues.length; i++) {
    LineGraph.GraphColor = graphColors[i];
    LineGraph.LineGraph(lineGraphSampleNumbers, lineGraphValues[i]);
  }
  
  pushMatrix();
  popMatrix();
}

void startStop(boolean theFlag) {
  isRunning = theFlag;
  if(theFlag)  startButton.setLabel("Stop");
  else         startButton.setLabel("Start");
}

void logData(float theValue) {
  
}
