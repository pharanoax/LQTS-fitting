% This script will intialise experimental data
clear;
clc;
close;

% Load in experimental data (You can change the filename here)
[V,si] = abfload('C_0003.abf');
si = si*10^(-6);
V=V';
t=0:si:si*(length(V)-1);

% Filter the data first
V_filtered = LowpassFilter(V);

% Isolate 1 AP
[start, finish] = single_AP(V_filtered);
AP = V_filtered(start:finish);
AP_t = t(start:finish);

% Find peak and RMP of AP
[b_V, ~] = min(AP);
[p_V, p_i] = max(AP);

% Find max upstroke
[max_upstroke, upstroke_i] = max(diff(AP));

% Plotting the single AP
figure
    plot(AP_t,AP);
    title('Single action potential')
    xlabel('Time (s)');
    ylabel('Membrane Potential (mV)')
    
% Find APD90
APD = APD90(AP,AP_t);
