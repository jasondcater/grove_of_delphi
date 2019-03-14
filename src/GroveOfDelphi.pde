import processing.serial.*;

int NUM_SOLENOIDS = 27;

Serial myPort;      // The serial port

int inByte = -1;    // Incoming serial data

char[] relayChannel = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V'};


int lf = 10;    // Linefeed in ASCII
String myString = null;

//JODY: change this to match the switch case index of the setup you want to test
int sketchIdeaNum = 0;

// time variable for time based effects
int t = 0;


void setup() {
  //size(400, 300);
  // create a font with the third font available to the system:
  //PFont myFont = createFont(PFont.list()[2], 14);
  //textFont(myFont);

  // List all the available serial ports:
  printArray(Serial.list());

  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // In Windows, this usually opens COM1.
  // Open whatever port is the one you're using.
  //JODY: You'll likely have to change this
  //      Output is printed to console
  //      Just select the number most like 1 or 4 below
  //      and put that in String portName = Serial.list()[HERE];
  //[0] "/dev/cu.Bluetooth-Incoming-Port"
  //[1] "/dev/cu.usbmodem14111"
  //[2] "/dev/cu.usbserial-FT1JHNQE"
  //[3] "/dev/tty.Bluetooth-Incoming-Port"
  //[4] "/dev/tty.usbmodem14111"
  //[5] "/dev/tty.usbserial-FT1JHNQE
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600);
  myPort.clear();
  // Throw out the first reading, in case we started reading 
  // in the middle of a string from the sender.
  myString = myPort.readStringUntil(lf);
  myString = null;
  
  allOff();
}

void draw() {

  //JODY: here are a number of quick sketches that translate to different sounds
  switch(sketchIdeaNum) {
  case 0: 
    sparseDensityLFOSineWaveRandom(); 
    break;
  case 1: 
    mediumDensityLFOSineWaveRandom();
    break;
  case 2: 
    highDensityLFOSineWaveRandom();
    break;
  case 3: 
    lowWaveDensityLFOSineWaveRandom();
    break;
  case 4: 
    medWaveDensityLFOSineWaveRandom();
    break;
  case 5: 
    highWaveDensityLFOSineWaveRandom();
    break;
  case 6: 
    waveLFOSineWaveRandom();
    break;
  }

  //text("Last Received: " + inByte, 10, 130);
}


//---------------------Density Feeling(low, medium, high)---------------------
// TRACK 0
// pretty sparse sounds
// Period = 1/0.01Hz = 100 seconds ~ 1.5 min
void sparseDensityLFOSineWaveRandom() {
  float lfoFreq = 0.1;
  float delayMax = 1200;

  int i = int(random(NUM_SOLENOIDS));
  triggerSolenoid(i);

  int delayTime = (int)random(20, delayMax*(1+sin(2*PI*lfoFreq*t/1000)));
  delay(delayTime);

  println("Low Density: solenoid= " + i + ", delayTime= " + delayTime);
}

// TRACK 1
// medium density sounds
// Period = 1/0.1Hz = 10 seconds
void mediumDensityLFOSineWaveRandom() {
  float lfoFreq = 0.1;
  float delayMax = 300;

  int i = int(random(NUM_SOLENOIDS));
  triggerSolenoid(i);

  int delayTime = (int)random(20, delayMax*(1+sin(2*PI*lfoFreq*t/1000)));
  delay(delayTime);

  println("Medium Density: solenoid= " + i + ", delayTime= " + delayTime);
}

// TRACK 2
// high density sounds
// Period = 1/0.1Hz = 10 seconds
void highDensityLFOSineWaveRandom() {
  float lfoFreq = 0.1;
  float delayMax = 200;

  int i = int(random(NUM_SOLENOIDS));
  triggerSolenoid(i);

  int delayTime = (int)random(20, delayMax*(1+sin(2*PI*lfoFreq*t/1000)));
  delay(delayTime);

  println("High Density: solenoid= " + i + ", delayTime= " + delayTime);
}

//---------------------LFO Feeling(low, medium, high)---------------------
// TRACK 3
// pretty sparse sounds
// Period = 1/0.01Hz = 100 seconds ~ 1.5 min
void lowWaveDensityLFOSineWaveRandom() {
  float lfoFreq = 0.01;
  float delayMax = 3000;
  float randomNoisePercent = 0.1;

  int i = int(random(NUM_SOLENOIDS));
  triggerSolenoid(i);

  int delayTime = (int)(delayMax*(1+sin(2*PI*lfoFreq*t)) + random(randomNoisePercent * delayMax));
  delay(delayTime);

  println("LFO Feeling, Low: solenoid= " + i + ", delayTime= " + delayTime);
  t++;
}

// TRACK 4
// pretty sparse sounds
// Period = 1/0.01Hz = 100 seconds 
void medWaveDensityLFOSineWaveRandom() {
  float lfoFreq = 0.01;
  float delayMax = 300;
  float randomNoisePercent = 0.1;

  int i = int(random(NUM_SOLENOIDS));
  triggerSolenoid(i);

  sineCalc("Medium Wave Density LFO Sine Wave Random", lfoFreq, t, delayMax, i);

  t++;
}


// TRACK 5
// pretty sparse sounds
// Period = 1/0.1Hz = 10 seconds 
void highWaveDensityLFOSineWaveRandom() {
  float lfoFreq = 0.4;
  float delayMax = 300;
  float randomNoisePercent = 0.8;

  int i = int(random(NUM_SOLENOIDS));
  triggerSolenoid(i);

  sineCalc("High Wave Density LFO Sine Wave Random", lfoFreq, t, delayMax, i);

  //t++;
  t = millis();
}


// TRACK 6
// pretty sparse sounds
// Period = 1 second 
void waveLFOSineWaveRandom() {
  float lfoFreq = 10.0;
  float delayMax = 300.0;

  int i = int(random(NUM_SOLENOIDS));
  triggerSolenoid(i);

  sineCalc("Wave LFO Sine Wave Random", lfoFreq, t, delayMax, i);

  t++;
  //t = millis();
}


void sineCalc(String title, float lfoFreq, float t, float delayMax, int i) {
  float sine = sin(2.0*PI*lfoFreq*(float)t/1000);
  float delayTimeFloat = (delayMax*(1.0+sine));
  int delayTime = (int)delayTimeFloat;
  delay(delayTime);

  println(title + ": t= " + t + ", solenoid= " + i + ", delayTime= " + delayTime + ", delayTimeF= " + delayTimeFloat + ", sine= " + sine);
}

/*
void serialEvent(Serial myPort) {
 inByte = myPort.read();
 }
 */


void setSolenoidOn(int index) {
  //myPort.write("\r");
  myPort.write("relay on " + relayChannel[index] + "\r");
}

void setSolenoidOff(int index) {
  //myPort.write("\r");               
  myPort.write("relay off " + relayChannel[index] + "\r");
  //println("relay off " + relayChannel[index] + "\r");
}

void triggerSolenoid(int index) {
  setSolenoidOn(index);
  delay(10);
  setSolenoidOff(index);
}

/*
NEEEEEEVER USE THESE!!!!!!!!!!!!!
 This is the worst case for power draw and could be dangerous
 void allOn(){
 myPort.write("\r");               
 myPort.write("relay writeall ffffffff\r");  
 }
 */
void allOff() {
  //myPort.write("\r");               
  myPort.write("relay writeall 00000000\r");
}
