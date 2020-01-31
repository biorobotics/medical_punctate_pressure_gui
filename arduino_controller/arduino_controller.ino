/**************************************************************************************
May 23, 2019

vibration motor
temp sensor
peltier cooler <- motor controller
processing control

no PID or damping for temp control
// 11.12 4.8
for temp sensor
A5 yellow
A4 green
GND blue
3.3v white


**************************************************************************************/

#include <Wire.h>
#include "ClosedCube_MAX30205.h"
#include <SoftwareSerial.h>

ClosedCube_MAX30205 max30205;

float temperature;
float prev_error = 0;
float targetTemp = 33;
float roomTemp = 26;
float forceReading=0;
float zero_output = 206.0;

float error;
float pwm = 255;
String Message;


//Pins

const int pwm_pin = 6;
const int high_switch = 8;
const int low_switch = 7;
const int vMotor = 5;
const int forcePin = 0;

const int maxTemp = 41;
const int minTemp = 25;

void setup()
{
  Serial.begin(9600);
  pinMode(high_switch, OUTPUT);
  pinMode(low_switch, OUTPUT);
  pinMode(pwm_pin, OUTPUT);
  pinMode(vMotor, OUTPUT);
  pinMode(forcePin, INPUT);
  max30205.begin(0x48);
  digitalWrite(pwm_pin, HIGH);
  analogWrite(pwm_pin,0);
}

void loop()
{
  //from processsing
  while(Serial.available() > 0){
    Message = Serial.readString();
    Serial.println(Message);
    if (Message.equals("v")) {
      analogWrite(vMotor, 153);
      Serial.println("hello");
    } else if (Message.equals("nv")) {
      analogWrite(vMotor, 0);
      //Serial.print("world");
    } else {
      if (Message.toInt() != 0) {
        targetTemp = Message.toInt();
      }
    }
  } 

  // force
  forceReading = analogRead(forcePin); // /1023
  // Serial.println("f" + String((forceReading-zero_output)*2.414* 0.0098));
  delay(90);

  // temp control
  temperature = max30205.readTemperature();
  // Serial.println("t" + String(int(temperature)));
  Serial.println(String((forceReading-zero_output)*2.414* 0.0098)+" "+String(int(temperature)));

  delay(50);
  error = targetTemp - temperature;
  digitalWrite(pwm_pin, HIGH);
//  Serial.print(targetTemp);
//  Serial.print("   ");
//
//  Serial.println(temperature);

  // set direction
  if (error < 0) {
    digitalWrite(high_switch, HIGH);
    digitalWrite(low_switch, LOW);
  } else {
    digitalWrite(high_switch, LOW);
    digitalWrite(low_switch, HIGH);    
  }

  // set pwm
//  if (error > 0) {
//    digitalWrite(pwm_pin, HIGH);
//  } else if (error < -0.4) {
//    digitalWrite(pwm_pin, HIGH);
//  } else {
//    digitalWrite(pwm_pin, LOW);
//  }
  
}





  
