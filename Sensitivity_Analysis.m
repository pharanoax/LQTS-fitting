% This script will run a sensitivity analysis on how the maximal 
% conductances of each of the current channels in the Paci model affect 
% action potential duration. The analysis will be carried out in a similar 
% fashion to the procedure outlined in Romero, 2009 (Impact of ionic 
% current variability on human ventricular cellular electrophysiology). 
%
% Only the maximal conductance for each channel will be varied. Time 
% constants will not be taken into consideration for this study:
%
%   #   Parameter   Description                         Location in model
%   -----------------------------------------------------------------------
%   1   G_Na        Na maximal conductance              CONSTANTS(:,29) 
%   2   G_cal       CaL maximal conductance             CONSTANTS(:,30)
%   3   G_Kr        Kr maximal conductance              CONSTANTS(:,32)
%   4   G_Ks        Ks maximal conductance              CONSTANTS(:,35)
%   5   G_K1        K1 maximal conductance              CONSTANTS(:,36)   
%   6   G_f         If current maximal conductance      CONSTANTS(:,37)
%   7   P_NaK       NaK maximal conductance             CONSTANTS(:,43)                                        
%   8   k_NaCa      NaCa maximal conductance            CONSTANTS(:,44)
%   9   g_to        to maximal conductance              CONSTANTS(:,52)
%   10  g_b_Ca      bCa maximal conductance             CONSTANTS(:,40)
%   11  g_b_Na      bNa maximal conductance             CONSTANTS(:,39)
%   12  g_PCa       PCa maximal conductance             CONSTANTS(:,50)
%
% Author: Eric Liu

close all;
clear;

% Scaling factors: Alterations to be made to each parameter set

scalings = [0.7, 0.85, 1, 1.15, 1.3];
default = 1;

parameter_labels = ["G_{Na}","G_{CaL}","G_{Kr}","G_{Ks}","G_{K1}",...
                        "G_{f}", "P_{NaK}","k_{NaCa}","G_{to}",...
                            "G_{bCa}","G_{bNa}","G_{PCa}"];

APD = zeros(12,5);
baseline = zeros(12,5);
peak = zeros(12,5);

for i = 1:12
    scaling_factors = ones(1,18);
    
    for j = 1:5
        % Set the scaling for the current parameter
        scaling_factors(i) = scalings(j);
        
        % Run the Paci model with scaled parameter
        [VOI, STATES, ~, ~] = Paci_mod(scaling_factors);        
        Paci_V = STATES(:,1)*1000;  
        Paci_t = VOI;
        
        % Select one action potential
        [Paci_start, Paci_end] = single_AP(Paci_V,0);
        Paci_AP = Paci_V(Paci_start:Paci_end);
        Paci_t = (Paci_t(Paci_start:Paci_end)-Paci_t(Paci_start))*1000; 

        % Find the parameters of interest
        [baseline(i,j),peak(i,j),APD(i,j)] = AP_fitness_parameters(Paci_AP,Paci_t);       
    end  
end

% Calculate indexes percentage changes
D_APD = 100*(APD-APD(:,3))./APD(:,3);
D_baseline = 100*(baseline-baseline(:,3))./baseline(:,3);
D_peak = 100*(peak-peak(:,3))./peak(:,3);

% Calculate sensitivities
S_APD = (APD(:,5) - APD(:,1)) / 0.6;
S_baseline = (baseline(:,5) - baseline(:,1)) / 0.6;
S_peak = (peak(:,5) - peak(:,1)) / 0.6;

% Normalise
S_APD = (APD(:,5) - APD(:,1)) / (0.6*max(abs(S_APD)));
S_baseline = (baseline(:,5) - baseline(:,1)) / (0.6*max(abs(S_baseline)));
S_peak = (peak(:,5) - peak(:,1)) / (0.6*max(abs(S_peak)));

plot((1:12),S_APD)
hold on
plot((1:12),S_baseline)
plot((1:12),S_peak)





