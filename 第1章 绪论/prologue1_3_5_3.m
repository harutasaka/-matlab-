[z,p,k] = cheby2(10,20,300/1e3,'high');%切比雪夫2型阻带默认有等幅纹波
sos = zp2sos(z,p,k);
fvtool(sos,'Analysis','freq');