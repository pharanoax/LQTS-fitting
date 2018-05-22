% This script will intialise experimental data

clear;
clc;
close;

% Load in experimental data
[d,si] = abfload('C_0003.abf');

% Select one action potential
t = (0:0.05:1500);
AP = d(1:length(t));

    % Plot action potential
    plot(t,AP);

% Initialise
[V,b_V,p_V,APD,upstroke_V,upstroke_t] = initialise(d(1:30001),si);

    % Identify maximum upstroke
    hold on
    plot(upstroke_t,upstroke_V,'-o');
    
    % Identify recurring voltage
    plot((upstroke_t+APD),V((upstroke_t+APD)/(si*10^(-3))),'-o');
    