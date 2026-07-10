rf = 0.5;
span = 4;
sps = 3;
hl = rcosdesign(rf,span,sps,'normal');
fvtool(hl,'impulse')