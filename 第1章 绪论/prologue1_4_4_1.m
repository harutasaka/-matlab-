%希尔伯特变换
clear;
clc;
close all;
fs = 1e4;
t = 0:1/fs:1;
x = 2.5+cos(2*pi*203*t)+sin(2*pi*721*t)+cos(2*pi*1001*t);
y = hilbert(x);
figure(1);
subplot(211);
plot(t,real(y),t,imag(y));
xlim([0.01 0.03]);
legend('实部','虚部');
title('希尔伯特变换');
xlabel('时间(s)');
subplot(212);
pwelch([x;y].',256,0,[],fs,'centered')
legend('Original','Hilbert')
