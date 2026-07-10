N = 1000;
M = 4;
errorRate = comm.ErrorRate;
SNR = 0:2:20;
LEbNo = length(SNR);
symerrR = zeros(1,LEbNo);
BER = symerrR;
for i=1:LEbNo
    dataIn = randi([0 3],N,1);
    txSig = pskmod(dataIn,M,pi/4,'gray');
    rxSig = awgn(txSig,SNR(i));
    dataOut = pskdemod(rxSig,M,pi/4,'gray');
    [~,symerrR(i)] = symerr(dataIn,dataOut);
end


figure(1)
semilogy(SNR,symerrR,'k--','lineWidth',2);
xlabel('SNR(dB)');
ylabel('SER');