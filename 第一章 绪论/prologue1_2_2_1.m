%展示差分方程求冲激响应IIR
a1 = 0.5;
a2 = 1.5;
b0 = 1;
n = 0:1:20;
y1 = b0*(a1.^n);
y2 = b0*(a2.^n);
figure;
subplot(211),stem(n,y1),grid;
ylabel('h[n]');
xlabel('(a)n');
title('y[n]=ay[n-1]+b[x] for a=0.5 b=1');
box off;
subplot(212),stem(n,y2),grid;
ylabel('h[n]');
xlabel('(b)n');
title('y[n]=ay[n-1]+b[x] for a=1.5 b=1');
box off;