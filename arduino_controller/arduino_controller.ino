/**************************************************************************************
  May 23, 2019

  vibration motor
  temp sensor
  peltier cooler <- motor controller
  processing control

  no PID or damping for temp control
  // 11.12 4.8
  Hardware connections for Arduino Uno:
  VDD (white) to 3.3V DC
  SCL (yellow) to A5
  SDA (green) to A4
  GND (blue) to common ground


**************************************************************************************/

#include <Wire.h>
#include "Protocentral_MAX30205.h"

MAX30205 max30205;

// Peltier variables
float temperature;
float targetTemp = 27;
float temp_error;
const float pwm = 255;
const float stableRange = 0.5;
bool isTempStable = false;

// Force sensor variables
float forceReading = 0;
const float zero_output = 206.0;
const float force_scaling = 2.414 * 0.0098;
const float maxTemp = 41;
const float minTemp = 25;

// Serial variables
String inputString = "";         // a String to hold incoming data
bool stringComplete = false;  // whether the string is complete

// Vibration variables
const int vMotorPwm = 153;

//Pins
const int pwm_pin = 9;
const int high_switch = 8;
const int low_switch = 7;
const int vMotor = 5;
const int forcePin = 0;


void setup()
{
  Serial.begin(9600);
  Wire.begin();

  // reserve 200 bytes for the inputString:
  inputString.reserve(200);

  //scan for temperature in every 30 sec untill a sensor is found. Scan for both addresses 0x48 and 0x49
  while (!max30205.scanAvailableSensors()) {
    Serial.println("Error: Couldn't find the temperature sensor, please connect the sensor." );
    delay(30000);
  }
  max30205.begin();
  Serial.println("STARTING");
  pinMode(high_switch, OUTPUT);
  pinMode(low_switch, OUTPUT);
  pinMode(pwm_pin, OUTPUT);
  pinMode(vMotor, OUTPUT);
  pinMode(forcePin, INPUT);
  digitalWrite(pwm_pin, HIGH);
  analogWrite(pwm_pin, 0);
}

void loop()
{
  // Receive data
  if (stringComplete) {
    Serial.println(inputString);
    if (inputString.equals("v")) {
      analogWrite(vMotor, vMotorPwm);
    } else if (inputString.equals("nv")) {
      analogWrite(vMotor, 0);
    } else if (inputString.toInt() != 0) {
      targetTemp = max(minTemp, min(maxTemp, inputString.toInt()));
    }
    // clear the string:
    inputString = "";
    stringComplete = false;
  }

  // force
  forceReading = analogRead(forcePin); // /1023
  // Serial.println("f" + String((forceReading-zero_output)*2.414* 0.0098));
  delay(50);

  // temp control
  temperature = max30205.getTemperature();
  temp_error = targetTemp - temperature;
  Serial.println("FBK " + String((forceReading - zero_output)*force_scaling) + " " + String(temperature));

  delay(50);

  float deadzone = stableRange / (isTempStable ? 1 : 2);

  if (temp_error < - deadzone) {
    digitalWrite(high_switch, HIGH);
    digitalWrite(low_switch, LOW);
    analogWrite(pwm_pin, pwm);
    isTempStable = false;
  } else if (temp_error > deadzone) {
    digitalWrite(high_switch, LOW);
    digitalWrite(low_switch, HIGH);
    analogWrite(pwm_pin, pwm);
    isTempStable = false;
  } else {
    digitalWrite(high_switch, LOW);
    digitalWrite(low_switch, LOW);
    analogWrite(pwm_pin, 0);
    isTempStable = true;
  }

}


void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read();
    // if the incoming character is a newline, set a flag so the main loop can
    // do something about it:
    if (inChar == '\n') {
      stringComplete = true;
    } else {
      // add it to the inputString:
      inputString += inChar;
    }
  }
}
