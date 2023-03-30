resistance = [1:10:1000];
voltage = 9;
current = voltage./resistance;

figure
plot(current, resistance, '-r')