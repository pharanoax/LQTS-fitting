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
[iPSC_start, iPSC_end] = single_AP(V_iPSC);
iPSC_AP = V_iPSC(iPSC_start:iPSC_end);
iPSC_t = iPSC_t(iPSC_start:iPSC_end)-iPSC_t(iPSC_start);
    
% Initialise parameters for iPSC-CM
[iPSC_baseline,iPSC_peak,iPSC_APD,iPSC_max_upstroke,iPSC_upstroke_V,iPSC_upstroke_i,iPSC_V90,iPSC_V90_t] = initialise(iPSC_AP,iPSC_t);
iPSC_upstroke_t = iPSC_upstroke_i*si*10^(-3);
    
%% Setting up for the Paci model

% Load up the Paci model
[VOI, STATES, ~, ~] = Paci();
Paci_V = STATES(:,1)*1000;  % Scale from V to mV
Paci_t = VOI;


% Select one action potential
[Paci_start, Paci_end] = single_AP(Paci_V);
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
    

    