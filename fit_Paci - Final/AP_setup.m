function fitness = AP_setup(current_scaling_factors, experimental_parameters, iKr_parameters, iKs_parameters)

% This objective function will evaluate the fitness of how well the Paci
% model fits to experimental action potential recordings of iPSC-CMs.
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
%   4   rise time        duration of rapid depolarisation
%   5   RR interval      time duration between consecutive peaks

       

% Reset the fitness value
fitness = -1; % This is arbitrary, but I know that I can't get negative values hence I'll be able to tell if this is getting through

% Test the first action potential, assuming it occurs in the first 10
% seconds
try 
    % Run the Paci model with a set of the specified conductance scalings
    [VOI, STATES, ~, ~] = Paci_modSS(10, current_scaling_factors, iKr_parameters, iKs_parameters);
    % [Paci_start, Paci_end] = first_AP(STATES(:,1)*1000,0);
    Paci_V = STATES(:,1)*1000; % Convert to mV
    Paci_t = VOI;
    
    % Find the parameters of interest
    [ peak_voltage,baseline_voltage,APD,rise_time, RR_interval ] = Parameters( Paci_t, Paci_V );
    model_parameters = [ baseline_voltage,peak_voltage,APD,rise_time, RR_interval ] ;
    
    % Assess fitness
    fitness = (sum(((experimental_parameters - model_parameters)./experimental_parameters).^2))^0.5;


catch
    % Set fitness score to 1000 when the algorithm generates a
    % physiologically implausible action potential. Usually this happens
    % when single_AP.m runs into trouble.
    
    fitness = 1000;
end 

% Write to text file

fileid = fopen('fitness.txt','a');
fprintf(fileid, '\n Fitness = %f \t scaling factors = %f %f %f %f %f %f %f %f %f %f', fitness, current_scaling_factors);
fclose(fileid);











