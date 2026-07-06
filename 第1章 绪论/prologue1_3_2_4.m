%切比雪夫模拟低通滤波器转新的低通滤波器
[z,p,k] = cheb1ap(8,3);
[b,a] = zp2tf(z,p,k);
freqs(b,a);
Wo = 2*pi*30;
[bt,at] = lp2lp(b,a,Wo);
freqs(bt,at);