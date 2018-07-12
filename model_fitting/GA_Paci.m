% This program will run a genetic algorithm on the Paci model to match
% characteristics of experimental data collected on action potentials.
%
% Author: Eric Liu
% Date: 25/06/18

clear;
clc;
close all;

%% Setting up iPSC-CM data
% Load in experimental data (You can change the filename here)
[V_iPSC,si] = abfload('C_0005.abf');
V_iPSC = V_iPSC(1:48:end);
si = si*48;
iPSC_t = (0:si*10^(-3):(length(V_iPSC)-1)*si*10^(-3));

% Select one action potential
[iPSC_start, iPSC_end] = single_AP(V_iPSC,0.8);
iPSC_AP = V_iPSC(iPSC_start:iPSC_end);
iPSC_t = iPSC_t(iPSC_start:iPSC_end)-iPSC_t(iPSC_start);

% Initialise parameters for iPSC-CM
[iPSC_baseline,iPSC_peak,iPSC_APD,iPSC_max_upstroke,iPSC_upstroke_V,iPSC_upstroke_i,iPSC_V90,iPSC_V90_t] = initialise(iPSC_AP,iPSC_t);
iPSC_upstroke_t = iPSC_upstroke_i*si*10^(-3);

experiment_parameters = [iPSC_baseline,iPSC_peak,iPSC_APD,iPSC_max_upstroke,iPSC_V90_t];

%% Assessing fitness

% Resetting output text file
fileid = fopen('fitness.txt','w');

fprintf(fileid, '');
fclose(fileid);

%     Na  CaL Kr  Ks  K1  f   NaK NaCa
LB = [0.8,0.5,0.5,25, 0.2,1.0,0.2,0.1];
UB = [1.3,2.4,2.6,130,2.1,3.0,1.8,1.5];

% options = optimoptions('patternsearch','Display','iter','PlotFcn',@psplotbestf);
% [x,feval] = patternsearch(@Fitness_Paci,[1,1,2,50,1,1,1,1],[],[],[],[],LB,UB,[],options);

% options = gaoptimset('PlotFcns',@gaplotbestf);
% [x,feval] = ga(@Fitness_Paci,8,[],[],[],[],LB,UB,[],options);

options = optimoptions(@particleswarm,'PlotFcns',@pswplotbestf);
[x,feval] = particleswarm(@Fitness_Paci,8,LB,UB,options);
%% Making comparisons
[VOI, STATES, ~, ~] = Paci_mod(x);
Paci_V = STATES(:,1)*1000;  % Scale from V to mV
Paci_t = VOI;

% Load up the Paci model
% Select one action potential
[Paci_start, Paci_end] = single_AP(Paci_V,0);
Paci_AP = Paci_V(Paci_start:Paci_end);
Paci_t = (Paci_t(Paci_start:Paci_end)-Paci_t(Paci_start))*1000;  % Scale from s to ms and recalibrate back to Paci_t(0)=0

% Initialise parameters for Paci model
[Paci_baseline, Paci_peak, Paci_APD, Paci_max_upstroke, Paci_upstroke_V, Paci_upstroke_i,Paci_V90,Paci_V90_t] = initialise(Paci_AP,Paci_t);
Paci_upstroke_t = Paci_t(Paci_upstroke_i);

%% Plot the intial action potentials
figure

% Plot iPSC action potential
subplot(2,1,1)
plot(((0:length(iPSC_AP)-1)*si*10^(-3)),iPSC_AP);
title('Single iPSC-CM action potential')
axis([0 2000 -100 50]);
xlabel('Time (ms)');
ylabel('Membrane Potential (mV)')
    
% Plot Paci action potential
subplot(2,1,2)
plot(Paci_t,Paci_AP);
title('Single Paci action potential')
axis([0 2000 -100 50]);
xlabel('Time (ms)');
ylabel('Membrane Potential (mV)')

