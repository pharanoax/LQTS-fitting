% This script will take voltage clamp data to find the maximal conductances
% for iKs and iKr in the Paci model.

% Author: Eric Liu
% Date :  13/07/18

% Apply particle swarm to find optimal gKs to fit voltage clamp current
% density data.
options = optimoptions(@particleswarm,'PlotFcns',@pswplotbestf);
LB = 10;
UB = 300;
[gKs,gKs_fitness] = particleswarm(@iKs_fitness,1,LB,UB,options);

% Apply particle swarm to find optimal gKs to fit voltage clamp current
% density data.
options = optimoptions(@particleswarm,'PlotFcns',@pswplotbestf);
LB = 0.5;
UB = 5;
[gKr,gKr_fitness] = particleswarm(@iKs_fitness,1,LB,UB,options);