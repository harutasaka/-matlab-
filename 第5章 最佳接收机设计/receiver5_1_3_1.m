%% ============================================================
%% 第5章 最佳接收机设计 - 完整MATLAB代码
%% 匹配滤波器验证：证明匹配滤波器使输出信噪比最大化
%% ============================================================
clear; clc; close all;
% 1. 产生长度为N的随机2-PAM信号
N = 2^15;                           % 符号数 = 32768
m = pam(N, 2, 1);                   % 产生N个符号的2-PAM序列（幅度±1）

% 2-3. 过采样
M = 20;                             % 过采样因子 = 20
mup = zeros(1, N*M);                % 初始化过采样序列（全0）
mup(1:M:end) = m;                   % 每隔M个点插入一个符号

% 4-5. 定义发送脉冲形状（α=0的升余弦，即sinc函数）
L = 10;                             % 脉冲截断长度（半符号数）
ps = SRRC(L, 0, M);                 % 产生SRRC脉冲

% 6. 归一化脉冲能量为1
ps = ps / sqrt(sum(ps.^2));

% 7. 产生高斯白噪声（标准差0.5）
n = 0.5 * randn(size(mup));

% 8. 发送脉冲与数据序列卷积（成型滤波）
g = filter(ps, 1, mup);

% 9-10. 定义接收滤波器（与发送脉冲相同，匹配滤波器）
recfilt = SRRC(L, 0, M);
recfilt = recfilt / sqrt(sum(recfilt.^2));

% 11. 对信号序列匹配滤波（时间反转 = fliplr）
v = filter(fliplr(recfilt), 1, g);

% 12. 对噪声序列匹配滤波
w = filter(fliplr(recfilt), 1, n);

% 13-14. 降采样至符号速率
vdownsamp = v(1:M:end);             % 降采样后信号
wdownsamp = w(1:M:end);             % 降采样后噪声

% 15-16. 计算功率和信噪比
powv = pow(vdownsamp);              % 降采样后信号的功率
poww = pow(wdownsamp);              % 降采样后噪声的功率

% 17. 输出信噪比
SNR = powv / poww;
fprintf('输出信噪比 SNR = %.4f (%.2f dB)\n', SNR, 10*log10(SNR));

%% ============================================================
%% 辅助函数
%% ============================================================

% pam函数：产生M-PAM信号序列
% 输入: len - 序列长度
%       M   - 电平数（如M=2为2-PAM）
%       Var - 目标功率（方差）
% 输出: seq - PAM信号序列
function seq = pam(len, M, Var)
    % rand(1,len): 产生[0,1]均匀分布随机数
    % M*rand: 缩放至[0,M]
    % floor: 取整得到0,1,...,M-1
    % 2*floor-M+1: 映射到-(M-1),-(M-3),...,M-1（M个对称电平）
    % sqrt(3*Var/(M^2-1)): 归一化使功率=Var
    seq = (2*floor(M*rand(1,len)) - M + 1) * sqrt(3*Var/(M^2-1));
end

% SRRC函数：产生平方根升余弦（Square Root Raised Cosine）脉冲
% 输入: N     - 脉冲截断的半符号数（脉冲从-N*T到+N*T）
%       alf   - 滚降系数α（0≤α≤1），α=0退化为sinc
%       P     - 每符号采样点数（过采样因子）
%       t_off - 时间偏移（可选，默认0）
% 输出: g     - SRRC脉冲时域波形
function g = SRRC(N, alf, P, t_off)
    % 若未提供t_off参数，默认=0
    if nargin == 3
        t_off = 0;
    end
    
    % 时间轴：从-N*P到+N*P，步长=1
    % 1e-8: 避免k=0处的除零问题
    % t_off: 时间偏移量
    k = -N*P + 1e-8 + t_off : N*P + 1e-8 + t_off;
    
    % 若α=0，设极小值避免除零（sinc极限情况）
    if alf == 0
        alf = 1e-8;
    end
    
    % 平方根升余弦脉冲时域表达式
    % 公式: g(t) = [4α/√P] * [cos((1+α)πt/T) + sin((1-α)πt/T)/(4αt/T)] 
    %              / [π(1-(4αt/T)²)]
    % 其中 k/P = t/T（归一化时间）
    g = 4*alf/sqrt(P) * (cos((1+alf)*pi*k/P) + sin((1-alf)*pi*k/P) ./ (4*alf*k/P)) ...
        ./ (pi*(1 - 16*(alf*k/P).^2));
end

% pow函数：计算信号功率（能量）
% 输入: x - 信号向量
% 输出: y - 功率 = 欧几里得范数的平方 = Σ|x_i|²
function y = pow(x)
    y = norm(x)^2;                  % norm(x) = sqrt(sum(abs(x).^2))
end
