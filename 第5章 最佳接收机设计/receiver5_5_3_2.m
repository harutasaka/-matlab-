clear;
clc;
close all;

trainL = 200;
M = 2;
hMode = comm.BPSKModulator;
msg = randi([0 1], 1000, 1);
x = step(hMode, msg);

% 信道：复数多径
rxsig = filter([1+0.5j, 0.8-0.2j, 0.3+0.1j], 1, x);
rxsig = rxsig + 0.15*randn(size(rxsig)) + 0.15j*randn(size(rxsig));

% 均衡器
eqlms = comm.LinearEqualizer(...
    'Algorithm', 'LMS', ...
    'NumTaps', 8, ...
    'StepSize', 0.02, ...
    'Constellation', complex([-1 1]), ...
    'ReferenceTap', 4);

% 训练 + 均衡（训练序列直接传前200个，无需补长）
[y, err] = eqlms(rxsig, x(1:trainL));

% ========== 关键修复：补偿 ReferenceTap-1 = 3 的延迟 ==========
delay = eqlms.ReferenceTap - 1;  % = 3

% BPSK硬判决（均衡器输出是复数软值，取实部符号）
yd = sign(real(y));

% 解调
hDemod = comm.BPSKDemodulator;
demodmsg = step(hDemod, complex(yd));

% 误码率计算：严格对齐延迟
% demodmsg(201) 对应 msg(198)，所以 msg 要往前移 delay 位
hErrorCalc = comm.ErrorRate;
reset(hErrorCalc);

% 训练后部分：msg(201:997) 对应 demodmsg(204:1000)
txMsg = msg(trainL+1:end-delay);        % 发射端参考
rxMsg = demodmsg(trainL+1+delay:end);    % 接收端估计

ser_Eq = step(hErrorCalc, txMsg, rxMsg);

% 作为对比，计算未均衡的 BER
demodRaw = step(hDemod, sign(real(rxsig)));
ser_Raw = step(comm.ErrorRate, msg(trainL+1:end), demodRaw(trainL+1:end));

% 画图
h = scatterplot(rxsig, 1, trainL, 'bx');
hold on;
scatterplot(y, 1, trainL, 'g.', h);
axis('tight');
legend('接收信号', '均衡后的信号', 'Location', 'se');
title({['均衡后 BER = ', num2str(ser_Eq(1))], ...
       ['未均衡 BER = ', num2str(ser_Raw(1))]});