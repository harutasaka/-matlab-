%椭圆滤波器转高通滤波器
f = 100;
[ze,pe,ke] = ellipap(5,3,30);
[be,ae] = zp2tf(ze,pe,ke);
[bh,ah] = lp2hp(be,ae,2*pi*f);
[hh,wh] = freqs(bh,ah,4096);
semilogx(wh/2/pi,mag2db(abs(hh)));
axis([10 400 -40 5]);
grid;