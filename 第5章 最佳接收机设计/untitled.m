%% ============================================
%  无 ISI 条件演示：RC vs SRRC
%% ============================================

clear; close all; clc;

%% 参数设置
rolloff = 0.25;     % 滚降系数
span = 6;           % 滤波器跨度（符号数）
sps = 8;            % 每符号采样数（用8个看得更清楚）

%% 1. 设计两种滤波器
h_rc  = rcosdesign(rolloff, span, sps, 'normal');   % 升余弦 RC
h_srrc = rcosdesign(rolloff, span, sps, 'sqrt');    % 平方根升余弦 SRRC

% 归一化（峰值=1）
h_rc = h_rc / max(h_rc);
h_srrc = h_srrc / max(h_srrc);

%% 2. 时域波形对比
figure('Name', '时域波形对比', 'Position', [100 100 1200 400]);

subplot(1, 2, 1);
stem(h_rc, 'filled', 'MarkerSize', 4);
hold on;
plot(h_rc, 'r--', 'LineWidth', 1);
% 标记符号间隔点
sym_idx = (span/2)*sps + 1 : sps : length(h_rc);
plot(sym_idx, h_rc(sym_idx), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
title('RC (升余弦) - 单独使用无 ISI');
xlabel('样本'); ylabel('归一化幅度');
legend('stem', '连线', '符号间隔采样点');
grid on;

subplot(1, 2, 2);
stem(h_srrc, 'filled', 'MarkerSize', 4);
hold on;
plot(h_srrc, 'r--', 'LineWidth', 1);
% 标记符号间隔点
sym_idx = (span/2)*sps + 1 : sps : length(h_srrc);
plot(sym_idx, h_srrc(sym_idx), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
title('SRRC (平方根升余弦) - 单独使用有 ISI');
xlabel('样本'); ylabel('归一化幅度');
legend('stem', '连线', '符号间隔采样点');
grid on;

%% 3. 关键：检查符号间隔处的值（ISI 测试）
fprintf('========== ISI 测试 ==========\n');
fprintf('符号间隔采样点索引: ');
disp(sym_idx);

fprintf('\n--- RC 滤波器在符号间隔处的值 ---\n');
for i = 1:length(sym_idx)
    idx = sym_idx(i);
    fprintf('  h_rc(%3d) = %.4f', idx, h_rc(idx));
    if i == (length(sym_idx)+1)/2
        fprintf('  <-- 中心峰值');
    else
        fprintf('  <-- 应 ≈ 0');
    end
    fprintf('\n');
end

fprintf('\n--- SRRC 滤波器在符号间隔处的值 ---\n');
for i = 1:length(sym_idx)
    idx = sym_idx(i);
    fprintf('  h_srrc(%3d) = %.4f', idx, h_srrc(idx));
    if i == (length(sym_idx)+1)/2
        fprintf('  <-- 中心峰值');
    else
        fprintf('  <-- 不为 0！有 ISI');
    end
    fprintf('\n');
end

%% 4. 两个 SRRC 卷积 = RC 验证
h_conv = conv(h_srrc, h_srrc);
h_conv = h_conv / max(h_conv);

% 找到中心位置
center = ceil(length(h_conv)/2);
% 截取与 RC 相同长度的中心部分
half_len = floor(length(h_rc)/2);
h_conv_trim = h_conv(center-half_len : center+half_len);

figure('Name', 'SRRC自卷积 = RC 验证', 'Position', [100 550 1200 400]);

subplot(1, 2, 1);
stem(h_rc, 'b', 'filled', 'MarkerSize', 4); hold on;
stem(h_conv_trim, 'r', 'MarkerSize', 4);
title('RC (蓝色) vs SRRC*SRRC (红色)');
xlabel('样本'); ylabel('幅度');
legend('RC', 'SRRC * SRRC');
grid on;

subplot(1, 2, 2);
plot(h_rc - h_conv_trim, 'k-', 'LineWidth', 2);
title('差异: RC - (SRRC*SRRC)');
xlabel('样本'); ylabel('误差');
grid on;

fprintf('\n--- SRRC * SRRC 在符号间隔处的值 ---\n');
sym_idx_conv = (length(h_conv_trim)+1)/2 : sps : length(h_conv_trim);
for i = 1:length(sym_idx_conv)
    idx = round(sym_idx_conv(i));
    fprintf('  h_conv(%3d) = %.4f', idx, h_conv_trim(idx));
    if i == (length(sym_idx_conv)+1)/2
        fprintf('  <-- 中心峰值');
    else
        fprintf('  <-- 应 ≈ 0');
    end
    fprintf('\n');
end

%% 5. 多符号传输演示：直观展示 ISI
fprintf('\n========== 多符号传输演示 ==========\n');

% 发送3个符号: [1, -1, 1]
symbols = [1, -1, 1];
N = length(symbols);

% 上采样
d_up = zeros(N*sps, 1);
d_up(1:sps:end) = symbols;

% 分别用 RC 和 SRRC 滤波
x_rc = upfirdn(d_up, h_rc, 1, 1);
x_srrc = upfirdn(d_up, h_srrc, 1, 1);

figure('Name', '多符号传输：ISI 可视化', 'Position', [100 1000 1200 500]);

% RC 传输
subplot(2, 1, 1);
t = (0:length(x_rc)-1)/sps;
plot(t, x_rc, 'b-', 'LineWidth', 1.5); hold on;
% 标记符号间隔采样点
sample_idx = span*sps + 1 : sps : span*sps + N*sps;
sample_times = (sample_idx-1)/sps;
sample_vals = x_rc(sample_idx);
plot(sample_times, sample_vals, 'ro', 'MarkerSize', 12, 'LineWidth', 2);
for i = 1:N
    fprintf('RC:   符号 %d 采样值 = %.4f (期望 %.0f)\n', i, sample_vals(i), symbols(i));
end
title('用 RC 滤波器：符号间隔采样 = 原始符号（无 ISI）');
xlabel('时间 (符号周期)'); ylabel('幅度');
legend('波形', '采样点');
grid on; ylim([-1.5 1.5]);

% SRRC 传输（单独使用）
subplot(2, 1, 2);
t = (0:length(x_srrc)-1)/sps;
plot(t, x_srrc, 'b-', 'LineWidth', 1.5); hold on;
sample_idx = span*sps + 1 : sps : span*sps + N*sps;
sample_times = (sample_idx-1)/sps;
sample_vals = x_srrc(sample_idx);
plot(sample_times, sample_vals, 'ro', 'MarkerSize', 12, 'LineWidth', 2);
for i = 1:N
    fprintf('SRRC: 符号 %d 采样值 = %.4f (期望 %.0f) <-- 有偏差！\n', i, sample_vals(i), symbols(i));
end
title('用 SRRC 滤波器（单独）：符号间隔采样 ≠ 原始符号（有 ISI）');
xlabel('时间 (符号周期)'); ylabel('幅度');
legend('波形', '采样点');
grid on; ylim([-1.5 1.5]);

%% 6. 完整系统：发送 SRRC + 接收 SRRC
fprintf('\n========== 完整系统：发送 SRRC + 接收 SRRC ==========\n');

% 发送
x_tx = upfirdn(d_up, h_srrc, 1, 1);

% 接收：匹配滤波 + 采样
y_rx = upfirdn(x_tx, h_srrc, 1, sps);

% 去掉边缘
y_rx = y_rx(span+1 : end-span);

% 取有效符号
y_symbols = y_rx(1:N);

figure('Name', '完整系统演示', 'Position', [100 1550 800 300]);
stem(symbols, 'b', 'filled', 'MarkerSize', 10); hold on;
stem(y_symbols, 'r', 'MarkerSize', 10);
title('原始符号 (蓝) vs 恢复符号 (红)');
xlabel('符号序号'); ylabel('幅度');
legend('发送符号', '接收符号');
grid on; ylim([-1.5 1.5]);

for i = 1:N
    fprintf('完整系统: 符号 %d 恢复值 = %.4f (期望 %.0f)\n', i, y_symbols(i), symbols(i));
end

fprintf('\n========== 结论 ==========\n');
fprintf('RC 单独使用: 无 ISI\n');
fprintf('SRRC 单独使用: 有 ISI\n');
fprintf('发送 SRRC + 接收 SRRC: 无 ISI (等效 RC)\n');