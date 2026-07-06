f = [0 0.3 0.4 0.6 0.7 1];
a = [0 0 1 1 0 0];
b = firpm(15,f,a);
[h,w] = freqz(b,1,256);
plot(f,a,w/pi,abs(h));
legend('理想','firpm');
xlabel('角频率(\omega/\pi)');
ylabel('幅度');