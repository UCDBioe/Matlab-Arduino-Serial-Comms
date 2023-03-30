close all
clear all
clc

usbPort = choose_usb_dialog;

function usbChoice = choose_usb_dialog

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