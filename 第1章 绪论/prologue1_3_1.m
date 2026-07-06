%滤波器设计
syms w;
n1 = (-10:1:10);
N1 = length(n1);
n2 = (-50:1:50);
N2 = length(n2);
a1 = (sin(pi*(n1+eps)/4)./(pi*(n1+eps)));
a2 = (sin(pi*(n2+eps)/4)./(pi*(n2+eps)));
hw1 = sum(a1.*exp(-1i*w*n1));
hw2 = sum(a2.*exp(-1i*w*n2));

w1 = (-pi:pi/100:pi);
ohw1 = eval(subs(hw1,w,w1));
ohw2 = eval(subs(hw2,w,w1));

figure;
subplot(311);

% 画 a1（短滤波器）
stem(n1, a1, 'b', 'LineWidth', 1.2, 'MarkerSize', 4); 
hold on;
% 画 a2（长滤波器）
stem(n2, a2, 'r--', 'LineWidth', 1.2, 'MarkerSize', 3);
grid on;
axis('tight');
title('Impulse Response h[n]');
xlabel('n');
ylabel('h[n]');
legend('N=21', 'N=101', 'Location', 'best');



subplot(312),plot(w1,abs(ohw1)),grid,ax1=gca;
axis('tight');
title(['N=',num2str(N1)]);
xlabel('(a)Radian frequency(\omega)');
ylabel('H(e^{j\omega})');

ax1.XTick = [-pi -3*pi/4 -pi/2 -pi/4 0 pi/4 pi/2 3*pi/4 pi];
ax1.XTickLabel = {'-\pi','-3\pi/4','-\pi/2','-\pi/4','0', ...
    '\pi/4','\pi/2','3\pi/4','\pi'};

subplot(313),plot(w1,abs(ohw2)),grid,ax2=gca;
axis('tight');
title(['N=',num2str(N2)]);
xlabel('(b)Radian frequency(\omega)');
ylabel('H(e^{j\omega})');

ax2.XTick = [-pi -3*pi/4 -pi/2 -pi/4 0 pi/4 pi/2 3*pi/4 pi];
ax2.XTickLabel = {'-\pi','-3\pi/4','-\pi/2','-\pi/4','0', ...
    '\pi/4','\pi/2','3\pi/4','\pi'};




