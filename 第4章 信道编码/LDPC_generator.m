function c = LDPC_generator(h, u)
% c = LDPC_generator(h, u)
% LDPC 基于近似下三角矩阵的编码函数 (Richardson-Urbanke 方法)
% 输入：
%   h  - 校验矩阵 (m x n)
%   u  - 信息比特向量 (1 x mlen)
% 输出：
%   c  - 完整码字 [u, p1, p2]

%% 1. 获取矩阵维度
mlen = size(h, 1);           % 校验矩阵行数 = 校验方程数
clen = size(h, 2);           % 校验矩阵列数 = 码字长度
m = clen - mlen;             % 信息位长度 (n - m)

%% 2. 寻找间隙长度 g（gap length）
% 从最后一列的最后一个1开始往前找
hrow1 = h(:, end);           % 取最后一列
for i = 1:clen
    if hrow1(i) == 1
        g = i;               % 找到最后一个1所在的行
        break;
    end
end

%% 3. 修正 g
g = mlen - g;                % 间隙大小

%% 4. 定义分块参数
wa = clen - m;               % 信息位长度
wb = g;                      % p1 的长度
ea = wa;                     % A 矩阵的列数 = 信息位长度
eb = wa + wb;                % A+B 的列数

%% 5. 矩阵分块 (Richardson-Urbanke 近似下三角形式)
% H = [ A  B  T ]
%     [ C  D  E ]
% 其中 T 是 (mlen-g) x (mlen-g) 的下三角矩阵

a = h(1:mlen-g, 1:ea);           % A: 左上
b = h(1:mlen-g, ea+1:eb);        % B: 中上
t = h(1:mlen-g, eb+1:end);       % T: 右上（下三角）
c = h(mlen-g+1:end, 1:ea);       % C: 左下
d = h(mlen-g+1:end, ea+1:eb);    % D: 中下
e = h(mlen-g+1:end, eb+1:end);   % E: 右下

%% 6. 计算校验位
invt = inv(t);                     % T 的逆矩阵
et1 = -(e * invt);                % -E * T^{-1}
phi = et1 * b + d;                % φ = -ET^{-1}B + D
xtra = et1 * a + c;               % -ET^{-1}A + C

% 计算 p1 (间隙部分的校验位)
p1 = mod(phi * xtra * (u'), 2)';

% 计算 p2 (下三角部分的校验位)
p2 = mod(invt * (a * (u') + b * (p1')), 2)';

%% 7. 构造完整码字
c = [u, p1, p2];

%% 8. 验证校验
zero = mod(c * h', 2);
if sum(zero) ~= 0
    disp('error: 编码校验不通过！');
end

end
