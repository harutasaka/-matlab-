M = 4;
trainLen = 200;
msg = randi([0 M-1],5e3,1);
hMod = comm.QPSKModulator('PhaseOffset',0);
modmsg = step(hMod,msg);
chan = [.986;.845;.237;.123+.31i];
rxsig = filter(chan,1,modmsg);
filtmsg = rxsig+0.1*randn(size(rxsig))+0.1j*randn(size(rxsig));

% ========== 替换部分：新版 DFE 均衡器 ==========
dfeObj = comm.DecisionFeedbackEqualizer(...
    'Algorithm', 'LMS', ...               % LMS 算法
    'NumForwardTaps', 5, ...               % 前馈抽头 = 5（对应旧版第1个参数）
    'NumFeedbackTaps', 3, ...              % 反馈抽头 = 3（对应旧版第2个参数）
    'StepSize', 0.03, ...                   % 步长
    'Constellation', step(hMod,(0:M-1)'), ...% QPSK 星座点
    'ReferenceTap', 2, ...                   % 主抽头位置（初始权重第2个为1）
    'InitialWeightsSource', 'Property', ...  % 启用自定义初始权重
    'InitialWeights', [0; 1; 0; 0; 0; 0; 0; 0]); % 列向量：[前馈5个; 反馈3个]

% 直接均衡（无训练序列，纯判决反馈模式）
eqRxSig = dfeObj(filtmsg,modmsg(1:trainLen));
% ==============================================

initial = eqRxSig(1:200);
plot(real(initial),imag(initial),'+');
hold on;
final = eqRxSig(end-200:end);
plot(real(final),imag(final),'ro');
xlabel('同相幅度');
ylabel('正交幅度');
axis('tight');
legend('接收信号','均衡后的信号','location','se');