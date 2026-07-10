M = 4;
dataIn = randi([0 M-1],1e4,1);
txSig = dpskmod(dataIn,M);
rxSig = txSig*exp(2i*pi*rand);
dataOut = dpskdemod(rxSig,M);
[errs,ratio] = symerr(dataIn,dataOut);
disp(errs);
disp(ratio);