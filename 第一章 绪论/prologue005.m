%归一化模拟低通转换为模拟带通
n = 14;
[z,p,k] = buttap(n);
[b,a] = zp2tf(z,p,k);
freqs(b,a);
fl = 30;
fh = 100;
Wo = 2*pi*sqrt(fl*fh);
Bw = 2*pi*(fh-fl);
[bt,at] = lp2bp(b,a,Wo,Bw);
freqs(bt,at);

