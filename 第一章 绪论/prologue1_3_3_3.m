Wp = 40/500;
Ws = 150/500;

Rp = 3;
Rs = 50;
[n,Wp] = cheb1ord(Wp,Ws,Rp,Rs);
[b,a] = cheby1(n,Rp,Wp);
sos = zp2sos(z,p,k);
freqz(b,a,512,1000);
title(sprintf('n=%d ChebyshevI低通滤波器',n));