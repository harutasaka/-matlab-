%利用脉冲不变性将三阶模拟椭圆滤波器转换为数字滤波器
fs = 100;
[b,a] = ellip(3,1,60,2*pi*2.5,'s');
[bz,az] = impinvar(b,a,fs);
impz(bz,az,[],fs);