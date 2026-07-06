Wp = [100 200]/500;
Ws = [40 260]/500;

Rp = 3;
Rs = 40;
[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[z,p,k] = butter(n,Wn);
sos = zp2sos(z,p,k);
freqz(sos,128,1000);
title(sprintf('n=%d Butterworth低通滤波器',n));