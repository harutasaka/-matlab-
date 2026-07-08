%% LDPC 线性编码示例（基于近似下三角矩阵）
% 构造近似下三角校验矩阵 Hlt
% 这是一个 5x10 的校验矩阵，码率 R = 0.5
Hlt = [1 1 0 1 1 0 0 1 0 0; ...
       0 0 0 1 0 1 0 1 1 0; ...
       0 1 1 0 1 0 1 0 0 1; ...
       1 1 0 0 0 0 1 0 1 1; ...
       0 0 1 0 0 1 0 1 0 1];

% 生成随机信息比特
% size(Hlt,1) = 5，即信息比特长度 k = 5
msg = round(rand(1, size(Hlt, 1)));

% 调用 LDPC 线性编码函数，计算校验位 p
p = ldpcLinearencode(Hlt, msg);

% 构造完整码字 c = [msg, p]
% 码字长度 n = 10，信息位 k = 5，校验位 m = 5
c = [msg, p];

% 校验：c * Hlt' mod 2 应该为全0向量
% 即验证 H * c^T = 0 (mod 2)
cs = mod(c * Hlt', 2);

% 检查校验结果
if sum(cs) ~= 0
    disp('error: 校验不通过！');
else
    disp('校验通过！');
end
