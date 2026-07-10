h = rcosdesign(0.25,6,4);
mx = max(abs(h-rcosdesign(0.25,6,4,'sqrt')));
fvtool(h,'Analysis','impulse')
