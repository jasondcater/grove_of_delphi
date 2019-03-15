/*
 * This script will run each solinoid one at a time to test acutation.
 */

import processing.serial.*;

char[] relayChannel = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 
'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 
'R', 'S', 'T', 'U', 'V'};

String myString = null;

void setup() {

  // List all the available serial ports.
  printArray(Serial.list());

  /*
   * The following section selects the output on your computer to the relay
   * board.
   *
   * I know that the first port in the serial list on my mac is always my  FTDI 
   * adaptor, so I open Serial.list()[0]. In Windows, this usually opens COM1.
   * Open whatever port is the one you're using.
   *
   * JODY: You'll likely have to change this. Output is printed to console. Just
   * select the number most like 1 or 4 below.
   *
   * ex:
   * [0] "/dev/cu.Bluetooth-Incoming-Port"
   * [1] "/dev/cu.usbmodem14111"
   * [2] "/dev/cu.usbserial-FT1JHNQE"
   * [3] "/dev/tty.Bluetooth-Incoming-Port"
   * [4] "/dev/tty.usbmodem14111"
   * [5] "/dev/tty.usbserial-FT1JHNQE
   */
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600);
  myPort.clear();

  /*
   * Throw out the first reading, in case we started reading in the middle of a 
   * string from the sender.
   */
  myString = myPort.readStringUntil(lf);
  myString = null;
}

void draw() {

  /*
   * Set a number from 0 to 26 to test the solinoid channel.
   */
  int relayChannelNumber = 0;
  int index = 0;
  while(index < 2){
    index++; 
    delay(750);
    triggerSolenoid(relayChannelNumber);
  }
}

void setSolenoidOn(int index) {
  myPort.write("relay on " + relayChannel[index] + "\r");
}

void setSolenoidOff(int index) {
  myPort.write("relay off " + relayChannel[index] + "\r");
}

void triggerSolenoid(int index) {
  setSolenoidOn(index);
  delay(10);
  setSolenoidOff(index);
}
