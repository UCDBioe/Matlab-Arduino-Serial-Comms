%% README.m for Plot_Serial
%
% Plot_Serial.m and Plot_Serial.fig are used to define the Graphical User
% Interface (GUI, or UI) for the incubator.
%
%% Plot_Serial.m Functions
% * *varargout = Plot_Serial(varargin)* - Creates the UI object, not much
% to edit here
% 
% * *Plot_Serial_OpeningFcn(hObject, eventdata, handles, varargin)* -
% Executes just before the UI is made visible. Setup information goes here.
% Global buffers are created here to pass data between the other methods of
% the UI. Globals are used in this context because UI operations are 
% conducted through callbacks (functions that are passed as a parameter to 
% other functions) and variables cannot be passed directly with callbacks 
% in Matlab. See:
% <https://www.mathworks.com/help/matlab/creating_guis/share-data-among-callbacks.html#bt9p4xi
% help document> for details. *This will be fixed to not use globals but to
% use guidata structure to pass data between callbacks in the UI*
%
% * *varargout = Plot_Serial_OutputFcn(hObject, eventdata, handles)* - 
% Outputs from this function are returned to the command line. Currently
% Unused.
%
% * *pushbuttonStop_Callback(hObject, eventdata, handles)* - Callback 
% action that occurs when the pushbuttonStop is pressed, which is the Stop 
% button. 
%
% * *axesTemp_CreateFcn(hObject, eventdata, handles)* - Creates the axes
% used to plot the Temperature data.
%
% * *usbChoice = choose_usb_dialog()* - Creates Popup to select serial
% port from drop-down list. Returns the usb selection as a string, usbChoice.
%
% * *[obj,flag] = setup_serial(comPort, hObject, handles)* - accepts the string 
% of the serial port Arduino is connected to (comPort), and as output values it 
% returns the serial element obj and a flag value used to check if when the 
% script is compiled the serial element exists yet.
%
% * *instrcallback(serialObj, event, hObject, handles)* - 
% callback for serial.BytesAvailableFunction. 
% This gets called whenever new data is available on the serial port.
% This is a callback function, so the state of the handles is the same
% state as when this function was first called. Handles is passed as 
% copy. This also means that handles cannot be updated from this 
% method so guidata(hObject, handles) will not work here.
%
% * *updateArduinoVals(handles)* -
% Update the PID and temperature setpoint values in the arduino.
%
% * *save_data(tIn,tOut,tSP,pid,time,volts)*
% Save data to the open csv file. This file is opened in 
% PBfile_Callback function.
%
% * *PBfile_Callback(hObject, eventdata, handles)* - 
% Create file and open fid for saving data to disk.
%
%
%% Callbacks for UI objects 
% * *editTempSP_Callback(hObject, eventdata, handles)*
% * *editTempSP_CreateFcn(hObject, eventdata, handles)*
% * *editPval_Callback(hObject, eventdata, handles)*
% * *editPval_CreateFcn(hObject, eventdata, handles)*
% * *editIIval_Callback(hObject, eventdata, handles)*
% * *editIIval_CreateFcn(hObject, eventdata, handles)*
% * *editDval_Callback(hObject, eventdata, handles)*
% * *editDval_CreateFcn(hObject, eventdata, handles)*
% * *editInTemp_Callback(hObject, eventdata, handles)*
% * *editInTemp_CreateFcn(hObject, eventdata, handles)*
% * *editOutTemp_Callback(hObject, eventdata, handles)*
% * *editOutTemp_CreateFcn(hObject, eventdata, handles)*
% * *editBatteryVolts_Callback(hObject, eventdata, handles)*
% * *editBatteryVolts_CreateFcn(hObject, eventdata, handles)*
