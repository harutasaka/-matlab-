function p = ldpcLinearencode(H, msg)
% p = ldpcLinearencode(H, msg)
% LDPC 基于近似下三角矩阵的线性编码
% 输入：
%   H   - 近似下三角校验矩阵 (m x n)
%   msg - 信息比特向量 (1 x k)
% 输出：
%   p   - 校验比特向量

%% 1. 获取矩阵维度
[k, n] = size(H);          % k: 行数(校验节点数), n: 列数(变量节点数)
m = n - k;                 % m: 校验位长度（这里注意：k是行数，不是信息位长度！）

%% 2. 寻找间隙长度 g（gap length）
% Hr = H(:, end) 取最后一列
Hr = H(:, end);            % find the gap length

% 从最后一列往前找，找到第一个1的位置
g = 0;
for i = 1:n
    if Hr(i) == 1
        g = i;
        break;
    end
end

% 修正：g = k - g
% 这里 g 表示下三角部分的大小
% 注意：教材中 k 是行数（校验方程数），不是信息位长度
% 实际信息位长度 = n - m = n - (n-k) = k ? 不对，需要重新理解
% 
% 实际上：
%   n = 码字总长度
%   m = 校验方程数 = size(H,1) = k（这里的k是行数）
%   信息位长度 = n - m = n - k
% 
% 但教材中 [k,n] = size(H)，k是行数，所以这里变量名有点混淆
% 我们按教材原样保留

g = k - g;                 % 矩阵分块参数：g 是间隙大小

%% 3. 矩阵分块：将 H 分为 A, B, C, D, E, T 六个子矩阵
% 
% H 的分块结构（近似下三角形式）：
% 
%     [ A      B      T  ]
% H = [                ]
%     [ C      D      E  ]
% 
% 其中 T 是 (m-g) x (m-g) 的下三角矩阵
% 
% 分块尺寸：
%   A: (m-g) x (n-m)      = (k-g) x (n-k)
%   B: (m-g) x g          = (k-g) x g
%   T: (m-g) x (m-g)      = (k-g) x (k-g)
%   C: g x (n-m)          = g x (n-k)
%   D: g x g              = g x g
%   E: g x (m-g)          = g x (k-g)

% 子矩阵提取
A = H(1:m-g, 1:n-m);           % A: 左上
B = H(1:m-g, n-m+1:n-m+g);     % B: 中上
T = H(1:m-g, n-m+g+1:end);     % T: 右上（下三角矩阵）

C = H(m-g+1:end, 1:n-m);       % C: 左下
D = H(m-g+1:end, n-m+1:n-m+g); % D: 中下
E = H(m-g+1:end, n-m+g+1:end); % E: 右下

%% 4. 计算 p1 和 p2
% 根据近似下三角编码公式：
% 
% [ p1^T ]   [ -(-ET^{-1}B + D)^{-1}(-ET^{-1}A + C)u^T ]
% [      ] = [                                           ]
% [ p2^T ]   [ -T^{-1}(Au^T + Bp1^T)                    ]

invT = inv(T);                 % T 的逆矩阵（T 是下三角，可逆）
% 注意：inv(T) 在 GF(2) 中应该是模2逆，但这里用实数域运算后再取模

ET1 = -(E * invT);             % -E * T^{-1}
phi = ET1 * B + D;             % phi = -ET^{-1}B + D
xtra = ET1 * A + C;            % xtra = -ET^{-1}A + C

% 计算 p1
% p1 = mod(phi * xtra * msg, 2)'
% 注意：这里需要 phi 可逆，即 phi 在 GF(2) 上可逆
p1 = mod(phi * xtra * msg', 2)';

% 计算 p2
% p2 = mod(invT * (A * msg' + B * p1'), 2)'
p2 = mod(invT * (A * msg' + B * p1'), 2)';

%% 5. 合并校验位
p = [p1, p2];

end
