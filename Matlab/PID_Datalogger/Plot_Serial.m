% PID_DATALOGGER UI for logging data from a PID-enabled microcontroller
%   PID_DATALOGGER() top-level main function that does not accept arguments
%   
%   - P-value, I-value, D-value and Temperature Setpoint are user definable
%   these textboxes can be changed in real-time as the program is running
%   and they update the correspoinding control variables in the arduino
%   by communicating the data over serial in JSON format.
%
%   - Inside Temperature and Outside Temperature show the last recieved
%   temperature value.
%
%   - "Write to file" pushbutton opens a dialog box to save data to a given
%   file. Data is written in csv format. Existing files will be 
%   overwritten. Data will be written from the time when the pushbutton is
%   clicked onward. Any data recieved or plotted from the start of the
%   PID_datalogger UI until pressing the "Write to file" pushbutton will be
%   lost.
%
%   "Stop" pushbutton closes open files and exits program
%
% Created by: Steve Lammers, 12/11/2017
% Released to the public domain. 



function varargout = Plot_Serial(varargin)
    % PLOT_SERIAL MATLAB code for Plot_Serial.fig
    %      PLOT_SERIAL, by itself, creates a new PLOT_SERIAL or raises the existing
    %      singleton*.
    %
    %      H = PLOT_SERIAL returns the handle to a new PLOT_SERIAL or the handle to
    %      the existing singleton*.
    %
    %      PLOT_SERIAL('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in PLOT_SERIAL.M with the given input arguments.
    %
    %      PLOT_SERIAL('Property','Value',...) creates a new PLOT_SERIAL or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before Plot_Serial_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to Plot_Serial_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help Plot_Serial

    % Last Modified by GUIDE v2.5 19-Jan-2018 08:21:11
    
    % TODO - add PI&D test fields to change those values programmatically
    % on the Arduino. This will be done using json. This will also require
    % changing the existing serial output to set the temperature setpoint
    % using json.

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @Plot_Serial_OpeningFcn, ...
                       'gui_OutputFcn',  @Plot_Serial_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
end
% End initialization code - DO NOT EDIT


% --- Executes just before Plot_Serial is made visible.
function Plot_Serial_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to Plot_Serial (see VARARGIN)

    % Reset the com ports in case the Arduino was not properly disconnected
    % before the program quit previously.
    % instrreset - this function was removed ny MatLab 2022
    clear serialObj

    global temperatureInsideBuffer
    temperatureInsideBuffer = zeros(100,1);
    global temperatureOutsideBuffer
    temperatureOutsideBuffer = zeros(size(temperatureInsideBuffer));
    global temperatureSetpointBuffer
    temperatureSetpointBuffer = zeros(size(temperatureInsideBuffer));
    global pidOutputBuffer
    pidOutputBuffer = zeros(size(temperatureInsideBuffer));
    global timeBuffer
    timeBuffer = zeros(size(temperatureInsideBuffer));
    global batteryBuffer
    batteryBuffer = zeros(size(temperatureInsideBuffer));
    
    global dataFile 
    dataFile = NaN;
    
    
    % Choose default command line output for Plot_Serial
    handles.output = hObject;
    
    handles.temperatureInsideBuffer = zeros(10,1);
    handles.temperatureSetpointBuffer = zeros(size(handles.temperatureInsideBuffer));
    
    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes Plot_Serial wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
    
    % Plot for the inside, outside and setpoint temperatures
    %x_data = 1:1:length(temperatureInsideBuffer);
    x_data = timeBuffer;
    handles.hTempPlot = plot(handles.axesTemp, x_data, temperatureInsideBuffer);
    hold on
    handles.hTempOutPlot = plot(handles.axesTemp, x_data, temperatureOutsideBuffer);
    handles.hSPPlot = plot(handles.axesTemp, x_data, temperatureSetpointBuffer);
    hold off
    set(handles.axesTemp, 'YLim', [15,45]);
    title('Temperature');
    handles.axesTemp.YLabel.String = 'Degrees Celsius';
    handles.axesTemp.XLabel.String = 'Time (s)';
    legend('Temp Inside', 'Temp Outside', 'Setpoint', 'Location', 'southwest');
    
    % Plot PID output
    handles.hPIDPlot = plot(handles.axesPID, x_data, pidOutputBuffer);
    set(handles.axesPID, 'YLim', [0,260]);
    %set(handles.axesPID, 'Title', 'PID Output Signal 8-bit');
    handles.axesPID.Title.String='PID Output Signal 8-bit';
    handles.axesPID.XLabel.String = 'Time (s)';
    guidata(hObject, handles);
    
    % Setup structure to hold temperature setpoint and PID values. This
    % will be used to send/receieve data from the Arduino
    handles.arduinoVals.pVal = 2;
    handles.arduinoVals.iVal = 5;
    handles.arduinoVals.dVal = 1;
    handles.arduinoVals.tSP = temperatureSetpointBuffer(1); 
    
    
    comPort = choose_usb_dialog;
    serialObj = setup_serial(comPort, hObject, handles);
    handles.comPort = comPort;
    handles.serialObj = serialObj;
    guidata(hObject, handles);
    
end


% --- Outputs from this function are returned to the command line.
function varargout = Plot_Serial_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end


% --- Executes on button press in pushbuttonStop.
function pushbuttonStop_Callback(hObject, eventdata, handles) %#ok<DEFNU>
    % hObject    handle to pushbuttonStop (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    fclose(handles.serialObj);
    close(handles.figure1);
end

% --- Executes during object creation, after setting all properties.
function axesTemp_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU,*INUSD>
% hObject    handle to axesTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesTemp


end



%%
function usbChoice = choose_usb_dialog()
    % Creates Popup to select serial port from drop-down list. 
    % Returns the usb selection as a string, usbChoice.

    % Get the list of available ports connected to the computer
    ports = cellstr(serialportlist);
    
    % Prepend 'none' selection to ports cell array to allow for running
    %  the UI without a connected Arduino, FUTURE FEATURE
    ports = [{'none'},ports];
    
    d = dialog('Position',[300 300 250 150],'Name','Select Port');

    txt = uicontrol('Parent',d,...
               'Style','text',...
               'Position',[20 80 210 40],...
               'String','Select Arduino Port.'); %#ok<NASGU>
           
    popup = uicontrol('Parent',d,...
           'Style','popup',...
           'Position',[75 70 100 25],...
           'String',ports,...
           'Callback',@popup_callback); %#ok<NASGU>

    btn = uicontrol('Parent',d,...
               'Position',[85 20 70 25],...
               'String','Close',...
               'Callback','delete(gcf)'); %#ok<NASGU>
           
    % Make default selection the first cell array element
    usbChoice = ports{1};
       
    % Wait for d to close before running to completion
    uiwait(d);
   
   function popup_callback(popup,event)
      idx = popup.Value;
      popup_items = popup.String;
      % This code uses dot notation to get properties.
      % Dot notation runs in R2014b and later.
      % For R2014a and earlier:
      % idx = get(popup,'Value');
      % popup_items = get(popup,'String');
      usbChoice = char(popup_items(idx,:));
   end
end


%%
function[obj,flag] = setup_serial(comPort, hObject, handles)
  % SETUP_SERIAL accepts the string of the serial port Arduino is connected 
  % to (comPort), and as output values it returns the serial 
  % element obj and a flag value used to check if when the script is compiled
  % the serial element exists yet.
  flag = 1;
  % Initialize Serial object
  obj = serial(comPort);
  set(obj,'DataBits',8);
  set(obj,'StopBits',1);
  set(obj,'BaudRate',9600);
  set(obj,'Parity','none');
  
  
  % Set serial to read the data when terminator is reached
  %obj.BytesAvailableFcnCount = 128;
  obj.BytesAvailableFcnMode = 'terminator';
  %obj.BytesAvailableFcn = {@(h,event) instrcallback(obj,h,event), handles};
  obj.BytesAvailableFcn = {@instrcallback, hObject, handles};
  %obj.BytesAvailableFcn = @instrcallback;
  
  fopen(obj);
  flushinput(obj);
  %fread(obj, obj.BytesAvailable)
  %mbox = msgbox('Serial Communication setup'); uiwait(mbox);
end


function instrcallback(serialObj, event, hObject, handles)
    %  INSTRCALLBACK - callback for serial.BytesAvailableFunction 
    %  This gets called whenever new data is available on the serial port.
    %  This is a callback function, so the state of the handles is the same
    %  state as when this function was first called. Handles is passed as 
    %  copy. This also means that handles cannot be updated from this 
    %  method so guidata(hObject, handles) will not work here.
    global temperatureInsideBuffer;
    global temperatureOutsideBuffer;
    global temperatureSetpointBuffer;
    global pidOutputBuffer;
    global timeBuffer;
    global batteryBuffer;
    global dataFile;
    %byteNum = serialObj.BytesAvailable;
    a = fscanf(serialObj,'%s\n');
    % Check that the json data is intact by checking that there is a { at
    % the beginning and a } at the end of the string.
    if length(regexp(a,'^{\w*|\W*}$')) == 2
        try % Error handling in case the JSON message is poorly formed
            data = jsondecode(a);
        catch ME
            fprintf(2,'Error thrown in JSON decode\n');
            fprintf(2,'JSON msg poorly formatted?\n');
            fprintf(2,'%s\n', ME.message);
            return
        end
%         data = jsondecode(a);
        % Gather data to update axes
        temperatureInsideBuffer= circshift(temperatureInsideBuffer,1);
        temperatureInsideBuffer(1) = data.temperatureInside;
        temperatureOutsideBuffer= circshift(temperatureOutsideBuffer,1);
        temperatureOutsideBuffer(1) = data.temperatureOutside;
        temperatureSetpointBuffer = circshift(temperatureSetpointBuffer,1);
        temperatureSetpointBuffer(1) = data.temperatureSetpoint;
        pidOutputBuffer = circshift(pidOutputBuffer,1);
        pidOutputBuffer(1) = data.PIDoutput;
        batteryBuffer = circshift(batteryBuffer,1);
        batteryBuffer(1) = data.batteryVolts;
        timeBuffer = circshift(timeBuffer,1);
        timeBuffer(1) = data.time/1000;
        % Update Plots
        handles.axesTemp.XLim = [timeBuffer(end), timeBuffer(1)];
        handles.axesPID.XLim  = [timeBuffer(end), timeBuffer(1)];
        handles.hTempPlot.XData = timeBuffer;
        handles.hTempPlot.YData = temperatureInsideBuffer;
        handles.hTempOutPlot.XData = timeBuffer;
        handles.hTempOutPlot.YData = temperatureOutsideBuffer;
        handles.hSPPlot.XData = timeBuffer;
        handles.hSPPlot.YData = temperatureSetpointBuffer;
        handles.hPIDPlot.XData = timeBuffer;
        handles.hPIDPlot.YData = pidOutputBuffer;
        drawnow()
        % Update textbox values
        set(handles.editInTemp, 'string', num2str(data.temperatureInside));
        set(handles.editOutTemp,'string', num2str(data.temperatureOutside));
        set(handles.editBatteryVolts,'string', num2str(data.batteryVolts));
        % Save data to disk
        if ~isnan(dataFile)
            save_data(temperatureInsideBuffer(1),...
                      temperatureOutsideBuffer(1),...
                      temperatureSetpointBuffer(1),...
                      pidOutputBuffer(1),...
                      timeBuffer(1),...
                      batteryBuffer(1));
        end
    end
end

function updateArduinoVals(handles)
    % update the PID and temperature setpoint values in the arduino
    serialData = jsonencode(handles.arduinoVals);
    
    
    fprintf(handles.serialObj,serialData);
end

function editTempSP_Callback(hObject, eventdata, handles) %#ok<DEFNU>
    % hObject    handle to editTempSP (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of editTempSP as text
    %        str2double(get(hObject,'String')) returns contents of editTempSP as a double

    % Get the datat from the text field and send it by serial to the attached
    % Arduino
    handles.arduinoVals.tSP = str2double(get(hObject,'String'));
    guidata(hObject, handles);
    updateArduinoVals(handles);
     
end


% --- Executes during object creation, after setting all properties.
function editTempSP_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
    % hObject    handle to editTempSP (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

end



function editPval_Callback(hObject, eventdata, handles)%#ok<DEFNU>
% hObject    handle to editPval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPval as text
%        str2double(get(hObject,'String')) returns contents of editPval as a double
% Get the datat from the text field and send it by serial to the attached
    % Arduino
    handles.arduinoVals.pVal = str2double(get(hObject,'String'));
    guidata(hObject, handles);
    updateArduinoVals(handles);
end

% --- Executes during object creation, after setting all properties.
function editPval_CreateFcn(hObject, eventdata, handles)%#ok<DEFNU>
% hObject    handle to editPval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function editIIval_Callback(hObject, eventdata, handles)%#ok<DEFNU>
% hObject    handle to editIIval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIIval as text
%        str2double(get(hObject,'String')) returns contents of editIIval as a double
% Get the datat from the text field and send it by serial to the attached
    % Arduino
    handles.arduinoVals.iVal = str2double(get(hObject,'String'));
    guidata(hObject, handles);
    updateArduinoVals(handles);
end

% --- Executes during object creation, after setting all properties.
function editIIval_CreateFcn(hObject, eventdata, handles)%#ok<DEFNU>
% hObject    handle to editIIval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function editDval_Callback(hObject, eventdata, handles)%#ok<DEFNU>
% hObject    handle to editDval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDval as text
%        str2double(get(hObject,'String')) returns contents of editDval as a double
% Get the datat from the text field and send it by serial to the attached
    % Arduino
    handles.arduinoVals.dVal = str2double(get(hObject,'String'));
    guidata(hObject, handles);
    updateArduinoVals(handles);
end

% --- Executes during object creation, after setting all properties.
function editDval_CreateFcn(hObject, eventdata, handles)%#ok<DEFNU>
% hObject    handle to editDval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function editInTemp_Callback(hObject, eventdata, handles)%#ok<DEFNU>
% hObject    handle to editInTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editInTemp as text
%        str2double(get(hObject,'String')) returns contents of editInTemp as a double
end

% --- Executes during object creation, after setting all properties.
function editInTemp_CreateFcn(hObject, eventdata, handles)%#ok<DEFNU>
% hObject    handle to editInTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function editOutTemp_Callback(hObject, eventdata, handles)%#ok<DEFNU>
% hObject    handle to editOutTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editOutTemp as text
%        str2double(get(hObject,'String')) returns contents of editOutTemp as a double
end

% --- Executes during object creation, after setting all properties.
function editOutTemp_CreateFcn(hObject, eventdata, handles)%#ok<DEFNU>
% hObject    handle to editOutTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function save_data(tIn,tOut,tSP,pid,time,volts)
% Save data to the open csv file. This file is opened in 
% PBfile_Callback function.
global dataFile;
dlmwrite(dataFile,[tIn,tOut,tSP,pid,time,volts], '-append')
end

function PBfile_Callback(hObject, eventdata, handles)%#ok<DEFNU>
% Create file and open fid for saving data to disk.
%
% hObject    handle to PBfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dataFile;
[filename,pathname] = uiputfile('*.csv', 'Select file to save data');
handles.filename = filename;
handles.pathname = pathname;
dataFile = fullfile(pathname, filename);
fid = fopen(dataFile,'w');
fprintf(fid,'InsideTempC,OutsideTempC,SetpointTempC,PidOutput,TimeS,BatteryVolts\n');
fclose(fid);
guidata(hObject, handles);
end



function editBatteryVolts_Callback(hObject, eventdata, handles)%#ok<DEFNU>
% hObject    handle to editBatteryVolts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBatteryVolts as text
%        str2double(get(hObject,'String')) returns contents of editBatteryVolts as a double

end

% --- Executes during object creation, after setting all properties.
function editBatteryVolts_CreateFcn(hObject, eventdata, handles)%#ok<DEFNU>
% hObject    handle to editBatteryVolts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbuttonStop.
%function pushbuttonStop_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbuttonStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
