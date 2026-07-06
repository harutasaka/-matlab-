%40阶FIR高通滤波器，指定标准化截止频率0.48Hz
load chirp

y = y+randn(size(y))/25;
t = (0:length(y)-1)/Fs;
f = [0 0.48 0.48 1];
mhi = [0 0 1 1];
N = 40;
bhi = fir2(N,f,mhi);
freqz(bhi,1,[],Fs);