import SimpleOpenNI.*;
import processing.serial.*;

//Generate a SimpleOpenNI object
SimpleOpenNI kinect;


// START RELAY STUFF ----------------------------------------
// Create object from Serial class
Serial myPort;  // Create object from Serial class

int NUM_SOLENOIDS = 27;

int inByte = -1;    // Incoming serial data

char[] relayChannel = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V'};


int lf = 10;    // Linefeed in ASCII
String myString = null;

//JODY: change this to match the switch case index of the setup you want to test
int sketchIdeaNum = 0;

// time variable for time based effects
int t = 0;
// END RELAY STUFF ----------------------------------------




//Vectors used to calculate the center of the mass
PVector com = new PVector();
PVector com2d = new PVector();

//Up
float LeftshoulderAngle = 0;
float LeftelbowAngle = 0;
float RightshoulderAngle = 0;
float RightelbowAngle = 0;

//Legs
float RightLegAngle = 0;
float LeftLegAngle = 0;

void settings() {
  size(500, 420);
}

void setup() {
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  //kinect.enableIR();
  kinect.enableUser();// because of the version this change
  //size(640, 480);
  fill(255, 0, 0);
  //size(kinect.depthWidth()+kinect.irWidth(), kinect.depthHeight());
  kinect.setMirror(false);
  //Open the serial port for Arduino
  //String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port
  //myPort = new Serial(this, portName, 115200);


  // RELAY SETUP STUFF ----------------------------------------
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
  // END RELAY SETUP STUFF ----------------------------------------
}

void draw() {
  kinect.update();
  //image(kinect.depthImage(), 0, 0);
  //image(kinect.irImage(),kinect.depthWidth(),0);
  image(kinect.userImage(), 0, 0);
  IntVector userList = new IntVector();
  kinect.getUsers(userList);



  // ----------------------------------------------------------------------------
  // ------------------- JODY: This is what connects the Kinect to the relays
  // this is a hack for testing: I'm overwriting how many people are present to test all the conditons 0-9
  long numberOfPeople = 5; // comment this out when you want Kinect connection and uncomment "long numberOfPeople = userList.size();" on the next line
  //long numberOfPeople = userList.size(); 

  // basic idea: more people -> more sound density, while 0 people isn't too silent
  // convert number of people into a delay
  // more people --> less delay : more sound density


  // WARNING: lower delays get more and more risky AKA blowing power supplies / lots of current
  //          Make sure to feel the 5V power supplies to make sure they aren't over heating.
  //          You're dealing with a lot of power so bring the system up parts at a time:
  //          1 board of 9 (run it, check power supply heat etc.), then 2 boards (more checks), then 3 (many more checks over seconds and minutes)
  float delayWith0People = 1200.0;
  float delayWith9People = 150.0; // ACHTUNG!  DANGER! DO NOT MAKE THIS MUCH SMALLER
  float maxNumPeople = 9.0;

  float delayWindow = delayWith0People - (constrain((float)numberOfPeople, 0, maxNumPeople)/maxNumPeople)*(delayWith0People - delayWith9People);

  // this is the function that triggers all the relays
  variableDensityRandom((int)delayWindow);

  // for debugging in the console
  println("numberOfPeople= " + numberOfPeople + ", delayWindow= " + delayWindow);  
  // ------------------- END of Kinect -> Relay Connection section -------------------
  // ----------------------------------------------------------------------------




  // ------------------- START Kinect Drawing Section -------------------
  if (userList.size() > 0) {
    int userId = userList.get(0);
    //If we detect one user we have to draw it
    if ( kinect.isTrackingSkeleton(userId)) {
      //DrawSkeleton
      //drawSkeleton(userId);
      //drawUpAngles
      //ArmsAngle(userId);
      //Draw the user Mass
      MassUser(userId);
      //AngleLeg
      LegsAngle(userId);
    }
  }
  // ------------------- END Kinect Drawing Section -------------------
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



// TRACK 7
// pretty sparse sounds
// Period = 1/0.01Hz = 100 seconds ~ 1.5 min
void variableDensityRandom(int delayMax) {
  float lfoFreq = 0.1;


  int i = int(random(NUM_SOLENOIDS));
  triggerSolenoid(i);

  int delayTime = (int)random(20, delayMax*(1+sin(2*PI*lfoFreq*t/1000)));
  delay(delayTime);

  println("Low Density: solenoid= " + i + ", delayTime= " + delayTime);
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
NEEEEEEVER USE THIS!!!!!!!!!!!!!
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
// ----------------- END OF RELAY FUNCTIONS -----------------












// ----------------- KINECT FUNCTIONS -----------------
//Draw the skeleton
void drawSkeleton(int userId) {
  stroke(0);
  strokeWeight(5);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);
  noStroke();
  fill(255, 0, 0);
  drawJoint(userId, SimpleOpenNI.SKEL_HEAD);
  drawJoint(userId, SimpleOpenNI.SKEL_NECK);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawJoint(userId, SimpleOpenNI.SKEL_NECK);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawJoint(userId, SimpleOpenNI.SKEL_TORSO);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
}

void drawJoint(int userId, int jointID) {
  PVector joint = new PVector();
  float confidence = kinect.getJointPositionSkeleton(userId, jointID, 
    joint);
  if (confidence < 0.5) {
    return;
  }
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
}
//Generate the angle
float angleOf(PVector one, PVector two, PVector axis) {
  PVector limb = PVector.sub(two, one);
  return degrees(PVector.angleBetween(limb, axis));
}

//Calibration not required

void onNewUser(SimpleOpenNI kinect, int userID) {
  println("Start skeleton tracking");
  kinect.startTrackingSkeleton(userID);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
}

void MassUser(int userId) {
  if (kinect.getCoM(userId, com)) {
    kinect.convertRealWorldToProjective(com, com2d);
    stroke(100, 255, 240);
    strokeWeight(3);
    beginShape(LINES);
    vertex(com2d.x, com2d.y - 5);
    vertex(com2d.x, com2d.y + 5);
    vertex(com2d.x - 5, com2d.y);
    vertex(com2d.x + 5, com2d.y);
    endShape();
    fill(0, 255, 100);
    text(Integer.toString(userId), com2d.x, com2d.y);
  }
}

public void ArmsAngle(int userId) {
  // get the positions of the three joints of our right arm
  PVector rightHand = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
  PVector rightElbow = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, rightElbow);
  PVector rightShoulder = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, rightShoulder);
  // we need right hip to orient the shoulder angle
  PVector rightHip = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HIP, rightHip);
  // get the positions of the three joints of our left arm
  PVector leftHand = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
  PVector leftElbow = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, leftElbow);
  PVector leftShoulder = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, leftShoulder);
  // we need left hip to orient the shoulder angle
  PVector leftHip = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HIP, leftHip);
  // reduce our joint vectors to two dimensions for right side
  PVector rightHand2D = new PVector(rightHand.x, rightHand.y);
  PVector rightElbow2D = new PVector(rightElbow.x, rightElbow.y);
  PVector rightShoulder2D = new PVector(rightShoulder.x, rightShoulder.y);
  PVector rightHip2D = new PVector(rightHip.x, rightHip.y);
  // calculate the axes against which we want to measure our angles
  PVector torsoOrientation = PVector.sub(rightShoulder2D, rightHip2D);
  PVector upperArmOrientation = PVector.sub(rightElbow2D, rightShoulder2D);
  // reduce our joint vectors to two dimensions for left side
  PVector leftHand2D = new PVector(leftHand.x, leftHand.y);
  PVector leftElbow2D = new PVector(leftElbow.x, leftElbow.y);
  PVector leftShoulder2D = new PVector(leftShoulder.x, leftShoulder.y);
  PVector leftHip2D = new PVector(leftHip.x, leftHip.y);
  // calculate the axes against which we want to measure our angles
  PVector torsoLOrientation = PVector.sub(leftShoulder2D, leftHip2D);
  PVector upperArmLOrientation = PVector.sub(leftElbow2D, leftShoulder2D);
  // calculate the angles between our joints for rightside
  RightshoulderAngle = angleOf(rightElbow2D, rightShoulder2D, torsoOrientation);
  RightelbowAngle = angleOf(rightHand2D, rightElbow2D, upperArmOrientation);
  // show the angles on the screen for debugging
  fill(255, 0, 0);
  scale(1);
  text("Right shoulder: " + int(RightshoulderAngle) + "\n" + " Right elbow: " + int(RightelbowAngle), 20, 20);
  // calculate the angles between our joints for leftside
  LeftshoulderAngle = angleOf(leftElbow2D, leftShoulder2D, torsoLOrientation);
  LeftelbowAngle = angleOf(leftHand2D, leftElbow2D, upperArmLOrientation);
  // show the angles on the screen for debugging
  fill(255, 0, 0);
  scale(1);
  text("Left shoulder: " + int(LeftshoulderAngle) + "\n" + " Left elbow: " + int(LeftelbowAngle), 20, 55);
  //Arduino serial for legs
  //ArduinoSerialArms();
}

void ArduinoSerialArms() {
  if (RightelbowAngle <= 110) {
    //if we clicked in the window
    myPort.write("1");         //send a 1
    println("1");
  } else {                           //otherwise
    myPort.write("0");          //send a 0
    println("0");
  }
  if (LeftelbowAngle <= 110) {
    //if we clicked in the window
    myPort.write('2');         //send a 2
    println('2');
  } else {
    //otherwise
    myPort.write('3');          //send a 0
    println('3');
  }
}

void LegsAngle(int userId) {
  // get the positions of the three joints of our right leg
  PVector rightFoot = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_FOOT, rightFoot);
  PVector rightKnee = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, rightKnee);
  PVector rightHipL = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HIP, rightHipL);
  // reduce our joint vectors to two dimensions for right side
  PVector rightFoot2D = new PVector(rightFoot.x, rightFoot.y);
  PVector rightKnee2D = new PVector(rightKnee.x, rightKnee.y);
  PVector rightHip2DLeg = new PVector(rightHipL.x, rightHipL.y);
  // calculate the axes against which we want to measure our angles
  PVector RightLegOrientation = PVector.sub(rightKnee2D, rightHip2DLeg);
  // calculate the angles between our joints for rightside
  RightLegAngle = angleOf(rightFoot2D, rightKnee2D, RightLegOrientation);
  fill(255, 0, 0);
  scale(1);
  text("Right Knee: " + int(RightLegAngle), 500, 20);
  // get the positions of the three joints of our left leg
  PVector leftFoot = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_FOOT, leftFoot);
  PVector leftKnee = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_KNEE, leftKnee);
  PVector leftHipL = new PVector();
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HIP, leftHipL);
  // reduce our joint vectors to two dimensions for left side
  PVector leftFoot2D = new PVector(leftFoot.x, leftFoot.y);
  PVector leftKnee2D = new PVector(leftKnee.x, leftKnee.y);
  PVector leftHip2DLeg = new PVector(leftHipL.x, leftHipL.y);
  // calculate the axes against which we want to measure our angles
  PVector LeftLegOrientation = PVector.sub(leftKnee2D, leftHip2DLeg);
  // calculate the angles between our joints for left side
  LeftLegAngle = angleOf(leftFoot2D, leftKnee2D, LeftLegOrientation);
  // show the angles on the screen for debugging
  fill(255, 0, 0);
  scale(1);
  text("Leftt Knee: " + int(LeftLegAngle), 500, 55);
  //ArduinoSerialLegs();
}

void ArduinoSerialLegs() {
  if (RightLegAngle <= 150) {
    myPort.write("4");         //send a 4
    println("4");
  } else {                           //otherwise
    myPort.write("5");          //send a 5
    println("5");
  }  
  if (LeftLegAngle <= 150) {
    myPort.write("6");         //send a 6
    println("6");
  } else {
    //otherwise
    myPort.write("7");          //send a 7
    println("7");
  }
}
