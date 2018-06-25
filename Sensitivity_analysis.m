% This script will run a sensitivity analysis on how certain parameters in
% the Paci model affect action potential duration. The analysis will be
% carried out in a similar fashion to the procedure outlined in Romero,
% 2009 (Impact of ionic current variability on human ventricular cellular
% electrophysiology).
%
% Only parameters governing main transmembrane ion channels involved in AP 
% repolarization were considered.The 12 parameters that will be varied are 
% as follows:
%
%   #  Parameter Description
%   -----------------------------------------------------------------------
%   1   G_cal    CaL maximal conductance
%   2   T_d      CaL activation time constant
%   3   T_f1     CaL slow voltage-dependent inactivation gate time constant    
%   4   T_f2     CaL fast voltage-dependent inactivation gate time constant
%   5   G_Kr     Kr maximal conductance
%   6   T_Xr1    Kr activation gate time constant
%   7   T_Xr2    Kr inactivation gate time constant
%   8   G_Ks     Ks maximal conductance
%   9   T_Xs     Ks activation time constant
%   10  G_K1     K1 maximal conductance
%   11  P_NaK    NaK maximal conductance
%   12  k_NaCa   NaCa maximal conductance
%
% Further parameters were explored governing sodium dynamics
%
%   #  Parameter    Name in Paci Model
%   -----------------------------------------------------------------------
%   13   G_Na       Na maximal conductance
%   14   T_h        Time constant in sodium current h gate
%   15   T_j        Time constant in sodium current j gate
%   16   T_m        Time constant in sodium current m gate
%   17   G_f        Funny current maximal conductance
%   18   T_Xf       Time constant in funny current Xf gate
%
% Author: Eric Liu

close all;
clear;

% Scaling factors: Alterations to be made to each parameter set

scalings = [0.7, 0.85, 1, 1.15, 1.3];
default = 1;

% Locations of each parameter in the Paci model
%
%  #  Parameter    Name in Paci Model
%   -----------------------------------------------------------------------
%   1   G_cal       CONSTANTS(:,30)
%   2   T_d         ALGEBRAIC(:,50)
%   3   T_f1        ALGEBRAIC(:,35)         
%   4   T_f2        ALGEBRAIC(:,21)
%   5   G_Kr        CONSTANTS(:,32)
%   6   T_Xr1       ALGEBRAIC(:,46)
%   7   T_Xr2       ALGEBRAIC(:,47)
%   8   G_Ks        CONSTANTS(:,35)
%   9   T_Xs        ALGEBRAIC(:,48)
%   10  G_K1        CONSTANTS(:,36)
%   11  G_NaK       CONSTANTS(:,43)
%   12  k_NaCa      CONSTANTS(:,44)

parameter_labels = ["G_{cal}","T_d","T_{f1}","T_{f2}","G_{Kr}","T_{Xr1}","T_{Xr2}","G_{Ks}","T_{Xs}","G_{K1}","G_{NaK}","k_{NaCa}"];

for i = 1:12
    scaling_factors = ones(1,18);
    APD = zeros(1,5);
    
    for j = 1:5
        % Set the scaling for the current parameter
        scaling_factors(i) = scalings(j);
        
        % Run the Paci model with scaled parameter
        [VOI, STATES, ~, ~] = Paci_Sensitivity_Analysis(scaling_factors);        
        Paci_V = STATES(:,1)*1000;  
        Paci_t = VOI;
        
        % Select one action potential
        [Paci_start, Paci_end] = single_AP(Paci_V);
        Paci_AP = Paci_V(Paci_start:Paci_end);
        Paci_t = (Paci_t(Paci_start:Paci_end)-Paci_t(Paci_start))*1000; 

        % Find the parameters of interest
        [~, ~, APD(j), ~, ~, ~,~,~] = initialise(Paci_AP,Paci_t);       
    end

    figure(1)
    
    subplot(3,4,i)
    plot(scalings*100,APD*100/582);
    title(['\DeltaAPD vs \Delta' + parameter_labels(i)]);
    ylim([80,120]);
    xlabel("Scaling factor (%)");
    ylabel("\DeltaAPD (%)");
  
end

%% Repeating the procedure for iNa and if
% Locations of each parameter in the Paci model
%
%   #    Parameter   Location in Paci Model
%   -----------------------------------------------------------------------
%   13   G_Na        CONSTANTS(:,29)
%   14   T_h         ALGEBRAIC(:,42)
%   15   T_j         ALGEBRAIC(:,43)         
%   16   T_m         ALGEBRAIC(:,41)
%   17   G_f         CONSTANTS(:,37)
%   18   T_Xf        ALGEBRAIC(:,27)

parameter_labels = ["G_{Na}","T_h","T_{j}","T_{m}","G_{f}","T_{Xf}"];

for i = 13:18
    scaling_factors = ones(1,18);
    V90_t = zeros(1,5);
    
    for j = 1:5
        % Set the scaling for the current parameter
        scaling_factors(i) = scalings(j);
        
        % Run the Paci model with scaled parameter
        [VOI, STATES, ~, ~] = Paci_Sensitivity_Analysis(scaling_factors);        
        Paci_V = STATES(:,1)*1000;  
        Paci_t = VOI;
        
        % Select one action potential
        [Paci_start, Paci_end] = single_AP(Paci_V);
        Paci_AP = Paci_V(Paci_start:Paci_end);
        Paci_t = (Paci_t(Paci_start:Paci_end)-Paci_t(Paci_start))*1000; 

        % Find the parameters of interest
        [~, ~, ~, ~, ~, ~,~,V90_t(:,j)] = initialise(Paci_AP,Paci_t);       
    end

    figure(2)
    
    subplot(2,3,i-12)
    plot(scalings*100,V90_t*100/V90_t(3));
    %plot([70 85 100 115 130],[100 100 100 100 100]);
    title(['\DeltaV90_t vs \Delta' + parameter_labels(i-12)]);
    ylim([80,120]);
    xlabel("Scaling factor (%)");
    ylabel("\DeltaV90_t (%)");
    
    hold on


   
end





