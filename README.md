Required Libraries
-------------------
* PID_v1
* DallasTemperature
* OneWire

TODO
-----
* students update P,I,D vals in file
* cutoff for 45C heater
* cutoff for low voltage 

Bioe3090_Incubator
------------------

* **class TimeCheck(\_timeTrigger)** - Simple time trigger, needs to be polled to work. When polled with check\_trigger the model will return true if enough time has elapsed to satisfy the condition `(current_time - initial_time) > time_trigger`. If this condition has been met, the poll resets initial_time to current time and returns the boolean true, else false is returned.

* **void check_serial()** - Function that checks the serial port to see if data is available. If data is available, the function reads the data until a newline character is reached. The data is validated to be a correctly formatted JSON string. The JSON string is decoded and the decoded string is stored into global variables for the PID values and heater setpoint.

* **void assign_sensors()** - Startup function to assign the DS18B20 temperature sensors to the outside and inside positions within the incubator.

* **double convert_battery\_voltage(int analog\_reading)** - Converts an analogreading into the voltage of the battery. Uses the global values for the resistors in the voltage divider (resistV1, resistV2)

* **double print_temperature(DeviceAddress deviceAddress, bool jsonFlag)** - Function to print the temperature of a DS18B20 temperature device and to update temperature input for PID control. The temperature of the given device is printed to serial. This is useful for debugging. The temperature value is returned as a double. This can be used to update the temperature input for PID control in the main loop.

* **void json\_output(&double)** - Gathers data, builds JSON message and outputs message to the serial port of theArduino. JSON output string is encoded to contain information for the inside and outside tempertures, the PID output value and the time of the request. This data is then output on the serial port. Takes an address to a double as an input. This double is the input heater value for the PID control. Therefore, the PID heater input value is updated within the json\_output function.

* **void print_address(DeviceAddress deviceAddress)** - Prints the address of the given DS18B20 device.

* **void startup()** - Standard Arduino startup function. Starts serial coms, assigns sensors, set PID mode and sets heater setpoint.

* **void loop()** - Main Arduino program loop. 
