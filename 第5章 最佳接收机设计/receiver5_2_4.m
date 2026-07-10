rolloff = 0.25;
span = 6;
sps = 4;
b = rcosdesign(rolloff,span,sps);
d = 2*randi([0 1],100,1)-1;
x = upfirdn(d,b,sps);
r = x+randn(size(x))*0.01;
y = upfirdn(r,b,1,sps);
dy = y(span+1:end-span);
figure(1)
subplot(211);plot(d);xlabel('(a)原始信号');ylabel('幅度');
subplot(212);plot(dy);xlabel('(b)恢复信号');ylabel('幅度');


