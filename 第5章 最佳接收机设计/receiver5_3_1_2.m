%% 16PSK调制解调BER仿真
% 结合比特信噪比参数，采用调制与解调进行MATLAB仿真

% 1. 自定义符号映射表
custMap = [0 2 4 6 8 10 12 14 15 13 11 9 7 5 3 1];

% 2. 创建PSK调制器（16进制，比特输入，自定义符号映射）
pskModulator = comm.PSKModulator(16, 'BitInput', true, ...
    'SymbolMapping', 'Custom', 'CustomSymbolMapping', custMap);

% 4. 创建PSK解调器（16进制，比特输出，自定义符号映射）
pskDemodulator = comm.PSKDemodulator(16, 'BitOutput', true, ...
    'SymbolMapping', 'Custom', 'CustomSymbolMapping', custMap);

% 6. 创建AWGN信道（每符号比特数 = log2(16) = 4）
awgnChannel = comm.AWGNChannel('BitsPerSymbol', log2(16));

% 7. 创建误码率计算器
errorRate = comm.ErrorRate;

% 8. 定义Eb/No范围 (dB)
ebnoVec = 1:20;

% 9. 初始化BER数组
ber = zeros(size(ebnoVec));

% 10. 遍历每个Eb/No值进行仿真
for k = 1:length(ebnoVec)
    % 11. 重置误码率计算器
    reset(errorRate);
    
    % 12. 初始化误差向量 [误码数, 误比特数, 总比特数]
    errVec = [0 0 0];
    
    % 13. 设置当前Eb/No
    awgnChannel.EbNo = ebnoVec(k);
    
    % 14. 循环直到收集足够的错误（误码数<200 且 总比特数<1e7）
    while errVec(2) < 200 && errVec(3) < 1e7
        % 15. 生成随机二进制数据 (4000个比特)
        data = randi([0 1], 4000, 1);
        
        % 16. PSK调制
        modData = pskModulator(data);
        
        % 17. 通过AWGN信道
        rxSig = awgnChannel(modData);
        
        % 18. PSK解调
        rxData = pskDemodulator(rxSig);
        
        % 19. 计算误码率
        errVec = errorRate(data, rxData);
    end
    
    % 21. 保存当前Eb/No下的BER
    ber(k) = errVec(1);
end

% 23. 计算理论BER（16PSK非相干检测理论值）
berTheory = berawgn(ebnoVec, 'psk', 16, 'nondiff');

% 24. 绘制结果
figure;
% 25. 半对数坐标绘制仿真和理论BER曲线
semilogy(ebnoVec, ber, 'b-', ebnoVec, berTheory, 'k--', 'linewidth', 2);
% 26. 设置坐标轴标签
xlabel('Eb/No (dB)');
ylabel('BER');
% 27. 添加网格和图例
grid;
legend('仿真', '理论', 'location', 'ne');
