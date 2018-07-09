% This script will intialise both the iPSC-CM data and the Paci model for
% fitting.

clear;
clc;
close all;

%% Setting up for iPSC-CM data
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
    
%% Setting up for the Paci model

% Set up scaling factors for certain parameters in the Paci model
% (Paci_mod.m). Change any of these to change the linear scaling factor for
% that specific parameter. 

scaling_factors = zeros(1,12);

scaling_factors(1) = 1.0004;         % G_Na
scaling_factors(2) = 0.9995;         % G_Cal
scaling_factors(3) = 1.4689;         % G_Kr
scaling_factors(4) = 0.5038;         % G_Ks
scaling_factors(5) = 1.5000;         % G_K1
scaling_factors(6) = 1.5000;         % G_f
scaling_factors(7) = 1.0000;         % P_NaK
scaling_factors(8) = 1.0000;         % k_NaCa


[VOI, STATES, ~, ~] = Paci_mod(scaling_factors);
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

    % Identify maximum upstroke
    hold on
    plot(iPSC_upstroke_t,iPSC_upstroke_V,'-o');
    
    % Identify where V90 occurs
    plot(iPSC_V90_t,[iPSC_V90,iPSC_V90],'--x');
    
    legend('Membrane potential','Maximum upstroke','APD90')
    
% Plot Paci action potential
subplot(2,1,2)
plot(Paci_t,Paci_AP);
title('Single Paci action potential')
axis([0 2000 -100 50]);
xlabel('Time (ms)');
ylabel('Membrane Potential (mV)')

    % Identify maximum upstroke
    hold on
    plot(Paci_upstroke_t,Paci_upstroke_V,'-o');
    
    % Identify where V90 occurs
    plot(Paci_V90_t,[Paci_V90,Paci_V90],'--x');
    

    

    