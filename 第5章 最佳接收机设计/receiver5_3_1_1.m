%PSK调制器
% 1. 创建 PSK 调制器
pskModulator = comm.PSKModulator;
% 2. 生成随机 8PSK 调制数据 (2000个符号，范围0-7)
modData = pskModulator(randi([0 7], 2000, 1));
% 3. 创建 AWGN 信道，初始 Eb/N0 = 20 dB，每符号3比特
channel = comm.AWGNChannel('EbNo', 20, 'BitsPerSymbol', 3);
% 4. 信号通过 AWGN 信道
channelOutput = channel(modData);
% 5. 创建新图窗
figure(1);
% 6. 子图1：原始调制信号的星座图
subplot(221);
plot(real(modData), imag(modData), 'k.');
ylabel('正交分量');
title('(a) 原始信号');
% 8. 子图2：Eb/N0 = 20 dB 时的接收信号星座图
subplot(222);
plot(real(channelOutput), imag(channelOutput), 'k.');
channel.EbNo = 10;
title('(b) EbNo=20 dB');
% 10. 重新通过信道 (Eb/N0 已改为 10 dB)
channelOutput = channel(modData);
% 11. 子图3：Eb/N0 = 10 dB 时的接收信号星座图
subplot(223);
plot(real(channelOutput), imag(channelOutput), 'k.');
xlabel('同相分量');
ylabel('正交分量');
title('(c) EbNo=10 dB');
% 13. 将信道 Eb/N0 改为 0 dB
channel.EbNo = 0;
% 14. 再次通过信道
channelOutput = channel(modData);
% 15. 子图4：Eb/N0 = 0 dB 时的接收信号星座图
subplot(224);
plot(real(channelOutput), imag(channelOutput), 'k.');
xlabel('同相分量');
axis('tight');
title('(d) EbNo=0 dB');
