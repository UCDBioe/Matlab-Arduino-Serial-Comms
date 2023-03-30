close all
clear all
clc
% instrfindall
instrreset

comPort = choose_usb_dialog;
%global serialObj
serialObj = setup_serial(comPort);
%serialObj = 1;

simple_gui2(serialObj)

%% Create UI
%  Create and then hide the GUI as it is being constructed.
function simple_gui2(USBcom)
% SIMPLE_GUI2 Select a data set from the pop-up menu, then
% click one of the plot-type push buttons. Clicking the button
% plots the selected data in the axes.

  %  Create and then hide the GUI as it is being constructed.
  f = figure('Visible','off','Position',[360,500,450,285]);
  
  hPBclose = uicontrol('Style','pushbutton','String','Close',...
          'Position',[315,220,70,25],...
          'Callback',@closebutton_Callback);
      
  ha = axes('Units','pixels','Position',[50,60,200,185]);
  
  % Align pushbuttons
  %align([hsurf,hmesh,hcontour,htext,hpopup],'Center','None');
  
  % Make the figure visible
  f.Visible = 'on';
  
  % Callbacks
  function closebutton_Callback(source,eventdata) 
    % Close the USB connection
    close_serial_con(USBcom);
    % Close the figure
    close(f);
  end

  
end

% --- Executes just before untitled is made visible.
function untitled_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled (see VARARGIN)

% Choose default command line output for untitled
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);
end




%% Functions
function[obj,flag] = setup_serial(comPort)
  % It accept as the entry value, the index of the serial port
  % Arduino is connected to, and as output values it returns the serial 
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
  obj.BytesAvailableFcnCount = 8;
  obj.BytesAvailableFcnMode = 'terminator';
  obj.BytesAvailableFcn = @instrcallback;
  
  fopen(obj);
  
  %mbox = msgbox('Serial Communication setup'); uiwait(mbox);
end

function []=instrcallback(serialObj, event)
    %byteNum = serialObj.BytesAvailable;
    a = fscanf(serialObj,'%s\n');   
    %test = 12
    %data = jsondecode(a);
    % send data to update axes in figure
end

function close_serial_con(serialObj)
  fclose(serialObj);
  %test = 1
end

function usbChoice = choose_usb_dialog()

    ports = cellstr(seriallist);
    
    d = dialog('Position',[300 300 250 150],'Name','Select Port');

    txt = uicontrol('Parent',d,...
               'Style','text',...
               'Position',[20 80 210 40],...
               'String','Select Arduino Port.');
           
    popup = uicontrol('Parent',d,...
           'Style','popup',...
           'Position',[75 70 100 25],...
           'String',ports,...
           'Callback',@popup_callback);

    btn = uicontrol('Parent',d,...
               'Position',[85 20 70 25],...
               'String','Close',...
               'Callback','delete(gcf)');
           
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