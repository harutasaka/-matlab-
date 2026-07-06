%9阶高通巴特沃斯滤波器，300Hz截止频率，2000Hz采样率
[z,p,k] = butter(10,300/1e3,'high');
sos = zp2sos(z,p,k);
fvtool(sos,'Analysis','freq')