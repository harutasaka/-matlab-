load chirp

t = (0:length(y)-1)/Fs;
N = 40;
bhi = fir1(N,0.48,'high',chebwin(N+1,30));
freqz(bhi,1);