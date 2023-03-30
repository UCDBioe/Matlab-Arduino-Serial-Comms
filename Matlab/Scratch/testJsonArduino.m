%sTest.temperature = 20.2;
%sTest.setpoint = 30;
%sTest.P = 1.1;

obj = serial('/dev/cu.usbmodem14421');
  set(obj,'DataBits',8);
  set(obj,'StopBits',1);
  set(obj,'BaudRate',9600);
  set(obj,'Parity','none');
  fopen(obj);

%fid = fopen("tempJsonData.txt", 'w');

%fprintf(fid, '%s', jsonString);
%a=fread(obj,1,'uchar');
a = fscanf(obj,'%s\n');

data = jsondecode(a);

fclose(obj);

%fid2 = fopen("tempJsonData.txt", 'wt');
