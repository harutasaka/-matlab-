function [Eji, cHat] = logsumproduct(Rx, H, iter)
% [Eji, cHat] = logsumproduct(Rx, H, iter)
% 对数域和积算法（Log-Sum-Product Algorithm）
% 输入：
%   Rx   - 信道接收软信息（LLR，长度为 N2）
%   H    - LDPC 校验矩阵（稀疏矩阵，N1 x N2）
%   iter - 最大迭代次数
% 输出：
%   Eji  - 校验节点到变量节点的消息矩阵
%   cHat - 硬判决译码结果

%% 1. 初始化
[N1, N2] = size(H);           % N1: 校验节点数, N2: 变量节点数
Eji = zeros(N1, N2);          % 校验节点→变量节点消息
Pibetaji = Eji;               % 对数域幅度消息

%% 2. 初始化变量节点→校验节点的消息 Mji
% Mji = H .* repmat(Rx, N1, 1)
% 含义：将接收LLR Rx复制N1行，与H逐元素相乘
% 只有H(i,j)=1的位置才有消息传递，其余为0
Mji = H .* repmat(Rx, N1, 1);

%% 3. 获取校验矩阵的非零元素位置
[row, col] = find(H);         % row: 非零行索引, col: 非零列索引

%% 4. 迭代译码
for n = 1:iter

    %% ===== 步骤一：变量节点→校验节点消息的预处理 =====
    % alphaji: 符号（sign），取Mji的符号
    % 在GF(2)中，+1对应0，-1对应1
    alphaji = sign(Mji);        % 符号：+1 或 -1
    betaji = abs(Mji);          % 幅度：|Mji|

    %% 计算对数域幅度消息 Pibetaji
    % 公式：Φ(x) = log((exp(x)+1)/(exp(x)-1))
    % 这是双曲正切函数的对数域变换
    for j = 1:length(row)
        % 只对H中非零位置计算
        Pibetaji(row(j), col(j)) = log((exp(betaji(row(j), col(j))) + 1) / ...
                                       (exp(betaji(row(j), col(j))) - 1));
    end

    %% ===== 步骤二：校验节点处理（CN更新）=====
    % 对每个校验节点 i（行）
    for i = 1:N1
        cl = find(H(i, :));    % 找到第i行（校验节点i）连接的所有变量节点列索引

        % 对每个连接的变量节点 k
        for k = 1:length(cl)
            % Pibetaji_sum: 除当前变量节点外，所有其他变量节点的Pibetaji之和
            % 即：Σ_{j'∈C_i\j} Φ(|M_{j'i}|)
            Pibetaji_sum = sum(Pibetaji(i, cl)) - Pibetaji(i, cl(k));

            % 数值稳定性处理：防止和太小导致下溢
            if Pibetaji_sum < 1e-20
                Pibetaji_sum = 1e-10;
            end

            % 计算 Φ(Pibetaji_sum) = log((exp(sum)+1)/(exp(sum)-1))
            Pi_Pibetaji_sum = log((exp(Pibetaji_sum) + 1) / (exp(Pibetaji_sum) - 1));

            % alphaji_prod: 除当前变量节点外，所有其他变量节点符号的乘积
            % 即：Π_{j'∈C_i\j} sign(M_{j'i})
            alphaji_prod = prod(alphaji(i, cl)) * alphaji(i, cl(k));
            % 注意：这里乘了两次 sign(M_{ji})，实际应为 prod(alphaji(i, cl)) / alphaji(i, cl(k))
            % 但代码中用了 *，这可能是一个小bug，正确应该是：
            % alphaji_prod = prod(alphaji(i, cl)) / alphaji(i, cl(k));

            % 更新校验节点→变量节点消息 Eji
            % E_{ji} = [Π sign(M_{j'i})] * Φ(Σ Φ(|M_{j'i}|))
            Eji(i, cl(k)) = alphaji_prod * Pi_Pibetaji_sum;
        end
    end

    %% ===== 步骤三：变量节点处理（VN更新）=====
    % 对每个变量节点 j（列）
    for j = 1:N2
        rl = find(H(:, j));     % 找到第j列（变量节点j）连接的所有校验节点行索引

        % Ltotal: 变量节点j的总LLR = 接收LLR + 所有校验节点消息之和
        % L(q_j) = L(p_j) + Σ_{i'∈V_j} E_{i'j}
        Ltotal = Rx(j) + sum(Eji(rl, j));

        % 硬判决：L(q_j) >= 0 判为 +1（即0），否则判为 -1（即1）
        % 注意：代码中 cHat(j)=1 对应 Ltotal<0（即判为1）
        %       cHat(j)=0 对应 Ltotal>=0（即判为0）
        if Ltotal < 0
            cHat(j) = 1;        % 判为1（对应-1）
        else
            cHat(j) = 0;        % 判为0（对应+1）
        end

        % 更新变量节点→校验节点消息 Mji
        % M_{ji} = L(p_j) + Σ_{i'∈V_j\i} E_{i'j}
        % 即：总LLR减去当前校验节点i的消息
        for k = 1:length(rl)
            Mji(rl(k), j) = Rx(j) + sum(Eji(rl, j)) - Eji(rl(k), j);
        end
    end

    %% ===== 步骤四：校验译码结果 =====
    % 计算 cHat * H' mod 2，检查是否满足所有校验方程
    cs = mod(cHat * H', 2);

    % 如果所有校验方程都满足（cs全为0），提前终止迭代
    if sum(cs) == 0
        break;
    end
end

end
