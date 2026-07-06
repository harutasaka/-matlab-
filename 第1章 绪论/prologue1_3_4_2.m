clear
Fc = 200;
Fs = 2000;
[z,p,k] = ellip(6,3,90,2*pi*Fc,'s');
[num,den] = zp2tf(z,p,k);
[h,w] = freqs(num,den);
plot(w/(2*pi),mag2db(abs(h)));
hold on
xlim([0 Fs/2])
[l1,l2] = meshgrid(Fc,[-120 0]);
plot(l1,l2)
grid
legend('Magnitude response','Passband Edge')
xlabel('Frequency(Hz)');
ylabel('Magnitude(dB)');
[numd,dend] = bilinear(num,den,Fs,Fc);
fvtool(numd,dend,'Fs','Fs')