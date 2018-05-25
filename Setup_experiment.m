% This script will intialise experimental data

clear;
clc;
close;

% Load in experimental data (You can change the filename here)
[d,si] = abfload('C_0009.abf');
d = d(1:48:end);
% Select one action potential
[AP_start, AP_end] = single_AP(d,si);
AP = d(AP_start:AP_end);

    % Plot action potential
    figure
    plot(((0:length(AP)-1)*si*10^(-3)),AP);
    title('Single action potential')
    xlabel('Time (ms)');
    ylabel('Membrane Potential (mV)')
    
% Initialise
[V,b_V,p_V,APD,max_upstroke,upstroke_V,upstroke_t] = initialise(AP,si);

    % Identify maximum upstroke
    hold on
    plot(upstroke_t,upstroke_V,'-o');
    
    % Identify recurring voltage
    plot((upstroke_t+APD),V((upstroke_t+APD)/(si*10^(-3))),'-o');
    