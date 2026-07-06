%求解DTFT频率分布
nn = -4:1:4;
w = -pi:pi/100:pi;
xn = [0 1 1 1 1 1 1 1 0];
Xw = 1+2*cos(w)+2*cos(2*w)+2*cos(3*w);
figure(1),subplot(211);
stem(nn,xn),grid;
xlabel('(a)n');
ylabel('x[n]');
subplot(212);
plot(w,Xw);
grid;
xlabel('(b)/omega');
ylabel('X(e^{j\omega})');
axis('tight');