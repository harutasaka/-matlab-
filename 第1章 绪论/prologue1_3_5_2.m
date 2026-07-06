[z,p,k] = cheby1(9,0.5,300/1e3,'high');%切比雪夫1型通带默认有等幅纹波
sos = zp2sos(z,p,k);
fvtool(sos,'Analysis','freq');