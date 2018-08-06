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
%   3   APD50            action potential duration at 50% repolarization
%   4   rise time        time of maximum upstroke from start of AP
%   5   RR interval      the time interval between the previous and current
%                        peaks

expt_param = [-68.1237, 39.4592, 206.2, 0.0369, 1.7];

try
% Run the Paci model with a set of the specified conductance scalings
[ Paci_min, Paci_pk, Paci_APD50, Paci_RiseTime, Paci_RR ] = SSPaci_mod(scaling_factors);        

% Find the parameters of interest
model_param = [Paci_min, Paci_pk, Paci_APD50,Paci_RiseTime, Paci_RR ] ;

% Assess fitness

fitness = (sum(((expt_param - model_param)./expt_param).^2)).^0.5;

catch
    fitness = 1000;
end

display(fitness);
display(scaling_factors)

% Write to text file

fileid = fopen('fitness.txt','a');
fprintf(fileid, '\n Fitness = %f \t scaling factors = %f %f %f %f %f %f %f %f', fitness, scaling_factors);
fclose(fileid);








