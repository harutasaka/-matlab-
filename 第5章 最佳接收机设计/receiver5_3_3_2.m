M = 64;
x = randi([0 M-1],20,4,2);
wlanSymMap = randintrlv([0:M-1],1);
y = qammod(x,M,wlanSymMap,'UnitAveragePower',true,'PlotConstellation',true);
z = qamdemod(y,M,wlanSymMap,'UnitAveragePower',true);
disp(isequal(x,z));