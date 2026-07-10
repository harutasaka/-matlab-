num = [0.01 1];
den = [1 1.01 1];
[A,B,C,D] = tf2ss(num,den);
dt = 0.01;
N = 3e3;
u = ones(1,N);
x = zeros(2,N+1);
y = zeros(1,N); 
for i=1:N
    x(:,i+1) = x(:,i)+dt.*A*x(:,i)+dt.*B*u(i);
    y(i) = C*x(:,i);
    echo off;
end
echo on;
t = 0:dt:N*dt;
plot(t(1:N),y,'k-','LineWidth',2);
xlabel('时间');
ylabel('相位');