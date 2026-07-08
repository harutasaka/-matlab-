%% QC-LDPC 码在 AWGN 信道上的 BER 性能仿真
% 基于 IEEE 802.11n 的 QC-LDPC 基矩阵，扩展因子 Z = 27
% 采用对数域 BP (Log-BP) 译码算法
% 对比 15次迭代 和 30次迭代 的译码性能

clear; close all;

%% ========== 参数设置 ==========
SNR = -2:0.5:5;          % SNR 范围 (dB)
itermax = 15;             % 最大迭代次数
blocks = 100;              % 每个 SNR 点仿真的码块数
MAX_R = 1000;              % 最大 LLR 值（限幅）
Z = 27;                    % 扩展因子（circulant size）

%% ========== QC-LDPC 基矩阵 (IEEE 802.11n, R=1/2, 12x24) ==========
Base_matrix = [
    0  -1  -1  -1   0   0  -1  -1   0  -1  -1   0   1   0  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1;
   22   0  -1  -1  17  -1   0   0  12  -1  -1  -1  -1   0   0  -1  -1  -1  -1  -1  -1  -1  -1  -1;
    6  -1   0  -1  10  -1  -1  -1  24  -1   0  -1  -1  -1   0   0  -1  -1  -1  -1  -1  -1  -1  -1;
    2  -1  -1   0  20  -1  -1  -1  25   0  -1  -1  -1  -1  -1   0   0  -1  -1  -1  -1  -1  -1  -1;
   23  -1  -1  -1   3  -1  -1  -1   0  -1   9  11  -1  -1  -1  -1   0   0  -1  -1  -1  -1  -1  -1;
   24  -1  23   1  17  -1   3  -1  10  -1  -1  -1  -1  -1  -1  -1  -1   0   0  -1  -1  -1  -1  -1;
   25  -1  -1  -1   8  -1  -1  -1   7  18  -1  -1   0  -1  -1  -1  -1  -1   0   0  -1  -1  -1  -1;
   13  24  -1  -1   0  -1   8  -1   6  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1   0   0  -1  -1  -1;
    7  20  -1  16  22  10  -1  -1  23  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1   0   0  -1  -1;
   11  -1  -1  -1  19  -1  -1  -1  13  -1   3  17  -1  -1  -1  -1  -1  -1  -1  -1  -1   0   0  -1;
   25  -1   8  -1  23  18  -1  14   9  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1   0   0;
    3  -1  -1  -1  16  -1  -1   2  25   5  -1  -1   1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1   0
];

%% ========== 从基矩阵扩展得到完整校验矩阵 H ==========
% QC-LDPC: 每个基矩阵元素对应一个 ZxZ 的循环移位矩阵
%   -1  →  ZxZ 全零矩阵
%   k   →  ZxZ 单位矩阵循环右移 k 位

H = zeros(size(Base_matrix) * Z);   % H 维度: (12*27) x (24*27) = 324 x 648
P0 = eye(Z);                         % ZxZ 单位矩阵

for r = 1:size(Base_matrix, 1)
    for c = 1:size(Base_matrix, 2)
        shift = Base_matrix(r, c);
        if shift > -1
            % 循环右移 shift 位
            Pi = circshift(P0, [0, shift]);
        else
            % -1 表示全零矩阵
            Pi = zeros(Z);
        end
        % 将 Pi 放入 H 的对应位置
        R = (r-1)*Z + 1 : r*Z;       % 行索引范围
        C = (c-1)*Z + 1 : c*Z;       % 列索引范围
        H(R, C) = Pi;
    end
end

%% ========== 获取校验矩阵维度 ==========
[m, n] = size(H);                    % m = 324 (校验方程数), n = 648 (码字长度)
MAX_j = max(sum(H, 2));              % 校验节点的最大度（最大行重）

%% ========== 预分配变量 ==========
Q = zeros(1, n);                     % 变量节点总 LLR
P = zeros(1, n);                     % 变量节点外部 LLR
R = zeros(m, MAX_j);                 % 校验节点→变量节点消息
R_1 = zeros(size(R));                % 上一次迭代的 R（用于排除自身）

%% ========== 遍历每个 SNR 点 ==========
for ii = 1:length(SNR)
    noisevar = 10^(-SNR(ii)/10);     % 噪声方差 σ² = 10^(-SNR/10)

    % 每次 SNR 点重新初始化
    v = 0;
    Q = zeros(1, n);
    P = zeros(1, n);
    R = zeros(m, MAX_j);
    R_1 = zeros(size(R));
    bit_errors = 0;

    %% ========== 遍历每个码块 ==========
    for b = 1:blocks
        % 显示进度
        if mod(b, blocks/10) == 0
            fprintf('%d%%\n', b/blocks * 100);
        end

        %% --- 编码 ---
        u = randi([0, 1], 1, m);       % 产生随机信息比特 (1 x m)
        c = LDPC_generator(H, u);      % 调用编码函数生成码字

        %% --- BPSK 调制 ---
        s = 2*c - 1;                   % 0 → -1, 1 → +1

        %% --- AWGN 信道 ---
        r = s + randn(size(s)) * sqrt(noisevar);  % 接收信号

        %% --- 初始化 LLR ---
        % Lci = 2*r/σ²  (BPSK AWGN 信道的 LLR)
        Lci = (-2 * r ./ noisevar);    % 注意：教材这里是 -2*r/σ²，对应 0→+1, 1→-1 的映射
        P = Lci;                       % 变量节点外部信息初始化为信道 LLR
        Q = Lci;                       % 变量节点总 LLR 初始化为信道 LLR
        k = 0;                         % 迭代计数器

        %% --- BP 迭代译码 ---
        while k < itermax

            %% ===== 校验节点更新 (CN Update) =====
            for i = 1:m
                Vi = find(H(i, :));    % 找到第 i 个校验节点连接的所有变量节点

                % z 矩阵：全1矩阵减去单位矩阵，用于排除自身
                % z(j,k) = 1 表示第 j 个变量节点向第 k 个变量节点传递消息时排除自身
                z = ones(length(Vi)) - eye(length(Vi));

                % Rij: 变量节点→校验节点消息 = 总LLR - 上一次校验节点→该变量节点消息
                Rij = Q(Vi) - R_1(i, 1:length(Vi));

                % 数值稳定性：避免太小值导致下溢
                Rij(abs(Rij) < 1e-8) = 1e-8;

                % === 对数域校验节点更新公式 ===
                % R(i→j) = [Π sign(Rj'i)] * Φ(Σ Φ(|Rj'i|))
                % 其中 Φ(x) = -ln(tanh(x/2)) = ln((e^x+1)/(e^x-1))
                %
                % 实现：利用 tanh 性质
                % Φ(ΣΦ(|R|)) = -ln(tanh(ΣΦ(|R|)/2))
                %            = -ln(tanh(Σ(-ln(tanh(|R|/2)))/2))
                %
                % 教材代码中的实现：
                % -log(tanh(z * (-log(tanh(abs(Rij)/2))')/2)) 是矩阵运算形式
                % 实际上是对每个元素计算：
                %  temp = sum(-log(tanh(abs(Rij)/2))) - (-log(tanh(abs(Rij(j))/2)))
                %  R = -log(tanh(temp/2))
                %
                % 然后乘以符号：prod(sign(Rij)) * sign(Rij(j))  （排除自身）

                R(i, 1:length(Vi)) = -log(tanh(z * (-log(tanh(abs(Rij)/2))')/2)) ...
                    .* prod(sign(Rij)) .* sign(Rij(1:length(Vi)))';

                % LLR 限幅：防止数值溢出
                R(i, abs(R(i, :)) > MAX_R) = sign(R(i, abs(R(i, :)) > MAX_R)) * MAX_R;

                % 变量节点更新：Q_j = Lci_j + Σ R_i→j
                P(Vi) = P(Vi) + R(i, 1:length(Vi));
            end

            %% ===== 迭代准备 =====
            R_1 = R;                     % 保存本次 R 用于下次排除自身
            Q = P;                       % 更新总 LLR
            P = Lci;                     % 重置外部信息为信道 LLR
            v = Q < 0;                   % 硬判决：LLR < 0 判为 1

            %% ===== 校验检查 =====
            % 如果 H * v' = 0 (mod 2)，说明译码成功，提前终止
            if ~sum(mod(H * v', 2))
                break;                   % 有效码字，跳出迭代
            end

            k = k + 1;                   % 迭代计数+1
        end

        %% --- 统计误码 ---
        % 只比较信息位部分：u(1:m) 与 v(1:m)
        errors = sum(u ~= v(1:m));
        bit_errors = bit_errors + errors;
    end

    %% --- 计算 BER ---
    BER(ii) = bit_errors / (m * blocks);
end

%% ========== 保存结果 ==========
saveFilename = ['LDPC', num2str(itermax)];
save(saveFilename, 'SNR', 'BER');

%% ========== 绘图 ==========
semilogy(SNR, BER, '-*');
xlabel('SNR(dB)');
ylabel('BER');
grid on;