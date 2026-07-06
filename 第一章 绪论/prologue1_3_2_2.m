fl=20;
fh=60;
Wo=2*pi*sqrt(fl*fh);
Bw=2*pi*(fh-fl);
[bt,at]=lp2bs(b,a,Wo,Bw);
freqs(bt,at);