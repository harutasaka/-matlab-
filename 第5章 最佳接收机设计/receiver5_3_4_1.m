M = 4;
k = log2(M);
EbNo = 5;
Fs = 2e2;
nsamp = 8;
freqseq = 20;
data = randi([0 M-1],1e4,1);
txsig = fskmod(data,M,freqseq,nsamp,Fs);
rxsig = awgn(txsig,EbNo+10*log10(k)-10*log10(nsamp),'measured',[],'dB');

dataOut = fskdemod(rxsig,M,freqseq,nsamp,Fs);
[num,BER] = biterr(data,dataOut);
BER_theory = berawgn(EbNo,'fsk',M,'noncoherent');
[BER BER_theory]