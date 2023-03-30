/* ArduinoMatlabSerialComms.ino - Communicate between Arduino and Matlab GUI
  Simple communication app for passing data between Arduino and Matlab 
  using JSON. The data communication is bidirectional. Matlab App Designer is
  used to create the GUI.
	Created by: Steve Lammers, 03/30/2023
	Released to the public domain.
*/

// JSON Library
#include <ArduinoJson.h>

// Pin Values
// Refresh rate for checking temperatures and updating PID input milliseconds, default 1000
#define TEMP_CHK_MS 100

// Define global variables
String inString = "";
// Create a heaterPID object of type PID - class loaded by thge PID_v1 library
//
double pVal = 20;

// Create JSON object.
bool jsonFlag = true; 

// Create a timer class. This works better than using "delay" functions 
//  since it allows the main loop to continue executing rather than sit
//  at the delay point doing nothing. 
class TimeCheck{
	unsigned long timeNow, timePrevious, timeTrigger;

	public:
	TimeCheck(unsigned long _timeTrigger){
		timePrevious = millis();
		timeNow = millis();
		timeTrigger = _timeTrigger;
	}
	
	void set_trigger(unsigned long _timeTrigger){
		timeTrigger = _timeTrigger;
	} 

	bool check_trigger(){
		bool triggered = false;
		timeNow = millis();
		unsigned long deltaTime = timeNow - timePrevious;
		if (deltaTime > timeTrigger ){
			timePrevious = timeNow;
			triggered = true;
		}
		else{ triggered = false; }
		
		return triggered;
	}
}; // class TimeCheck

// Create a clock to print the current temperature every second
TimeCheck printTempClock(TEMP_CHK_MS);


// Serial Event triggers when there is something to read on the 
//  Adruino's serial port. 
void serialEvent(){

  // read the incoming byte:
    int incomingByte = Serial.peek();

    // Check if the incoming byte is a newline character
    //  Skip the newline character since it is not JSON
    if (incomingByte != '\n'){

      // Create a JSON object so you can use it in this function.
      StaticJsonDocument<200> doc;
    
      // Deserialize the JSON document
      DeserializationError error = deserializeJson(doc, Serial);
      
      // Test if parsing succeeds.
      if (error) {
        Serial.print(F("deserializeJson() failed: "));
        Serial.println(error.f_str());
        return;
      }
    
      // Read the value named "pVal" from the JSON string
      //  Example JSON string: {"pVal":"1.23"}
      //  This string can be modified to suit your needs
      pVal = doc["pVal"];
      //Serial.print("pVal is:" ); // For DEBUG if needed
      //Serial.println(pVal);      // For DEBUG if needed
    
      // Turn the board-mounted Arduino LED if pVal == 1.23
      //  Otherwise turn the LED off
      if (pVal == 1.23)
      {
        digitalWrite(LED_BUILTIN, HIGH);   // turn the LED on (HIGH is the voltage level)
      }
      else
      {
        digitalWrite(LED_BUILTIN, LOW);    // turn the LED off by making the voltage LOW
      }


    }
    else
    {
      // If the character was a newline, read it to clear it from the serial port      
      Serial.read();
    }

    // Cleanup the serial port
    Serial.flush();

}





// Gathers output data, format as JSON and output as serial communication
//  The JSON string is formatted as: {"temperatureInside":16.00681,"time":18088}
//  This string can be modified to suit your needs
double json_output(double tempVal)
{ 
  // Create JSON object.
  StaticJsonDocument<200> jsonDoc;
  jsonDoc["temperatureInside"] = tempVal;
  jsonDoc["time"] = millis();//(millis() * 205 ) >> 11; //millis()/1000;
  // Send the JSON string to the serial port
  serializeJson(jsonDoc, Serial);
  Serial.println();
}

// Generic function to generate fake data
//  Used here to make a sin wave signal to output over the serial port
double fake_data_fcn()
{
  double fake_out = 11 + 10*sin(millis()/(TEMP_CHK_MS/10) * 2 * 3.14);
  return fake_out;
}



void setup(){
  // Start serial comms
	Serial.begin(9600);

	while (!Serial) {
		; // Wait for serial to connect
	}

 // initialize digital pin LED_BUILTIN as an output.
  pinMode(LED_BUILTIN, OUTPUT);

}


void loop(){
  // Check the clock to see if enough time has passed to trigger sending
  //  data over the serial port. 
	if (printTempClock.check_trigger()){   
    // Output data to serial.
    double tempVal = fake_data_fcn();
    json_output(tempVal);
	}
}
