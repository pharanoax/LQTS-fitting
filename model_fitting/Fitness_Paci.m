function fitness = Fitness_Paci(scaling_factors)

% This objective function will evaluate the fitness of how well the Paci
% model will fit to specified abf file.
%
%                    >>> INPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% conductances  scalar array       scaling factors for conductances
% expt_param    scalar array       fitness parameters of experimental data
% 
%                    >>> OUTPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% fitness       scalar             fitness of the Paci model fit
%
% The conductance scalar array input should be in the following format:
%
%   #  Parameter Description                         Location in model
%   -----------------------------------------------------------------------
%   1   G_Na     Na maximal conductance              CONSTANTS(:,29) 
%   2   G_cal    CaL maximal conductance             CONSTANTS(:,30)
%   3   G_Kr     Kr maximal conductance              CONSTANTS(:,32)
%   4   G_Ks     Ks maximal conductance              CONSTANTS(:,35)
%   5   G_K1     K1 maximal conductance              CONSTANTS(:,36)   
%   6   G_f      If maximal conductance              CONSTANTS(:,37)
%   7   P_NaK    NaK maximal conductance             CONSTANTS(:,43)                                        
%   8   k_NaCa   NaCa maximal conductance            CONSTANTS(:,44)
%
% The expt_param scalar array input should be in the following format:
%   #  Parameter         Description
%   -----------------------------------------------------------------------
%   1   baseline         baseline voltage 
%   2   peak             peak voltage
%   3   APD90            action potential duration at 90% repolarization
%   4   max_upstroke     maximum upstroke rate
%   5   upstroke_t       time of maximum upstroke from start of AP

expt_param = [-68.1237, 39.4592, 307.2, 12.2197, -13.74609];

% Run the Paci model with a set of the specified conductance scalings
[VOI, STATES, ~, ~] = Paci_mod(scaling_factors);        
Paci_V = STATES(:,1)*1000;  

 % Select one action potential
[Paci_start, Paci_end] = single_AP(STATES(:,1)*1000,0);
Paci_AP = Paci_V(Paci_start:Paci_end);
Paci_t = (VOI(Paci_start:Paci_end)-VOI(Paci_start))*1000; 

% Find the parameters of interest
model_param = zeros(1,5);
[model_param(1),model_param(2),model_param(3),model_param(4),~,~,~,model_param(5)] = initialise(Paci_AP,Paci_t);
model_param(5) = model_param(5)/10;

% Assess fitness

fitness = (sum(expt_param - model_param).^2)^0.5;
display(fitness);
display(scaling_factors)










