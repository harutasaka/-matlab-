%三个离散信号合并的周期
N = 128;
nn = 0:1:N;
x1 = 0.2*cos(2*pi*nn/8);
x2 = cos(2*pi*nn/64);
x3 = 0.5*cos(2*pi*nn/16);
figure,
subplot(211),stem(nn,[x1',x2',x3']);
grid;
xlabel('(a)n');
ylabel('幅度函数');
xlim([0 128]);
subplot(212),stem(nn,x1+x2+x3);
grid;
xlabel('(b)n');
ylabel('和幅度函数');
xlim([0 128]);