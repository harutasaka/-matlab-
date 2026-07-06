%Thorp公式
%对100-300khz的声音吸收损耗的经验总结
fsq = (Fc/1e3)^2;
alpha = 0.11*fsq/(1+fsq)+44*fsq/(4100+fsq)+2.75*1e-4*fsq+0.003;
%alpha(dB/km)
TL = 20*log10(R)+alpha*R*1e-3;