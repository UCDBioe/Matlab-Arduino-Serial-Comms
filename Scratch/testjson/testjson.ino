
#include <ArduinoJson.h>

float testTemp = 0;

void setup () {

  Serial.begin(9600);

}

void loop () {
  // Encode the message in JSON.

  // First create the JSON object.
  StaticJsonBuffer<200> jsonBuffer;
  JsonObject& root = jsonBuffer.createObject();

  testTemp = testTemp + 1;

  // Put the data into the JSON object.
  root["temperature"] = String(testTemp);
  root["setpoint"] = "30.3";
  root["P"] = "1.5";

  // -----------------------------------
  // Place temperature and humidity into the JSON object here.
  // -----------------------------------

  // Write out the message for debugging.
  root.printTo(Serial);
  Serial.println();

  delay(1000);
  // Turn the JSON structure into a string for sending over the MQTT topic.
  //char jsonOutputBuffer[512];
  //root.printTo(jsonOutputBuffer, sizeof(jsonOutputBuffer));
  //Serial.println();
}
