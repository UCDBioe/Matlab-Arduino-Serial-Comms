

sTest.temperature = 20.2;
sTest.setpoint = 30;
sTest.P = 1.1;
jsonString = jsonencode(sTest);


fid = fopen("tempJsonData.txt", 'w');

fprintf(fid, '%s', jsonString);

fclose(fid);

%fid2 = fopen("tempJsonData.txt", 'wt');


