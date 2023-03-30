/* Bioe3090_Incubator.ino - Example controls for Bioe 3090 Incubator Project
	Created by: Steve Lammers, 12/11/2017
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

// Create a timer class 
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


void serialEvent(){

  //while (Serial.available() > 0) {
      
  // read the incoming byte:
    int incomingByte = Serial.peek();

    // Check if the incoming byte is a newline character
    if (incomingByte != '\n'){

      StaticJsonDocument<200> doc;
      //deserializeJson(doc, Serial);
    
      // Deserialize the JSON document
      DeserializationError error = deserializeJson(doc, Serial);
    
      
      // Test if parsing succeeds.
      if (error) {
        Serial.print(F("deserializeJson() failed: "));
        Serial.println(error.f_str());
        return;
      }
    
      // Display the serial text recieved for pVal
      pVal = doc["pVal"];
      //Serial.print("pVal is:" );
      //Serial.println(pVal);
    
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
      Serial.read();
    }
    Serial.flush();
  
    // Clear the input string 
    //    inString = "";

  //}
  

}


void check_serial(){
  // Ask user to input the setpoint for the heater.
  //Serial.print("Enter temperature setpoint in degrees Celsius: ");
  // send data only when you receive data:
  // Clear the input string 
  while (Serial.available() > 0) { 
    // read the incoming byte:
    int incomingByte = Serial.read();
    
    inString += (char)incomingByte;
    // Check if the incoming byte is a newline character
    if (incomingByte == '\n'){
      // say what you got:
      Serial.print("I received: ");
      // Set temperature setpoint to the inString number
      //heaterSetpoint = inString.toFloat();
      //Serial.println(heaterSetpoint);

      // json format: {"pVal":2}
      Serial.println(inString);
      // Create JSON object, must create json object as a local objet here, not
      //  as a global as typical in the example docs in the ArduinoJson library.
      //  Otherwise the object is not destroyed after the loop is complete and
      //  if the parsing does not succeed then future calls to parse incomming
      //  correctly formatted json strings will also fail. Making the object local
      //  fixes this problem.
      StaticJsonDocument<200> jsonDoc;

      // JSON input string.
      //
      // Using a char[], as shown here, enables the "zero-copy" mode. This mode uses
      // the minimal amount of memory because the JsonDocument stores pointers to
      // the input buffer.
      // If you use another type of input, ArduinoJson must copy the strings from
      // the input to the JsonDocument, so you need to increase the capacity of the
      // JsonDocument.
      char json[] =
          "{\"pVal\":1.23}";
    
      // Deserialize the JSON document
      DeserializationError error = deserializeJson(jsonDoc, json);
    
      // Test if parsing succeeds.
      if (error) {
        Serial.print(F("deserializeJson() failed: "));
        Serial.println(error.f_str());
        return;
      }



      // Display the serial text recieved for pVal
      pVal = jsonDoc["pVal"];
      Serial.print("pVal is:" );
      Serial.println(pVal);

      /*
      if (pVal == 1.23)
      {
        digitalWrite(LED_BUILTIN, HIGH);   // turn the LED on (HIGH is the voltage level)
      }
      else
      {
        digitalWrite(LED_BUILTIN, LOW);    // turn the LED off by making the voltage LOW
      }

      */
      }
      
      // Clear the input string 
      inString = "";
    

  } 
} // << check_serial






// Gathers output data, format as JSON and output as serial communication
double json_output(double tempVal)
{ 

  // Create JSON object.
  StaticJsonDocument<200> jsonDoc;
  jsonDoc["temperatureInside"] = tempVal;
  jsonDoc["time"] = millis();//(millis() * 205 ) >> 11; //millis()/1000;
  serializeJson(jsonDoc, Serial);
  Serial.println();
}

// Generic function to generate fake data
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
  // Check the serial comms to see if the heater setpoint changed
  //check_serial();
  //try_serial();
	if (printTempClock.check_trigger()){
		// Get new temperature reading, compute PID and control heater 
		//heaterInput = print_temperature(insideThermometer); 
    //heaterPID.Compute(); 
    // move compute out of the check_trigger
    //analogWrite(HEATER_PIN, heaterOutput);
    
    // Output data to serial.
    double tempVal = fake_data_fcn();
    json_output(tempVal);

	}
 
  //DEL delay(1000);
}
