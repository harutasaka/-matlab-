% Munk profile test cases
% mbp
global units
units = 'km';

%%
figure
plotssp( 'MunkB_ray' ) % 绘制声速剖面

bellhop( 'MunkB_ray' ) % 计算声场并检查输入文件
figure
plotray( 'MunkB_ray' ) % 绘制声线轨迹

bellhop( 'MunkB_eigenray' ) % 计算声场并检查输入文件
figure
plotray( 'MunkB_eigenray' ) % 绘制本征声线