M = 16;
data = randi([0 M-1],1e4,1);
txSig = qammod(data,M);
rxSig = awgn(txSig,18,"measured");
rxData = qamdemod(rxSig.*exp(-1i*pi/M),M);
refpts = qammod((0:M-1)',M).*exp(1i*pi/M);
plot(rxSig(rxData==0),'g.');
hold on
plot(rxSig(rxData==3),'c.');
plot(refpts,'r*');
text(real(refpts)+0.1,imag(refpts),num2str((0:M-1)'));
xlabel('同相幅度');
ylabel('正交幅度');
xlim([-4,4]);
ylim([-4,4]);
legend('对应为0的点','对应为3的点','参考星座图','location','se');
