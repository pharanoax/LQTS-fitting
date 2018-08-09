function fitness = iKr_fitness(iKr_scaling_factors)

% This function will assess the fitness of how well a scaled iKr current in
% the Paci model fits to the voltage clamped data clamped from -70mV to 
% +70mV in 10mV increments.

%                    >>> INPUT VARIABLES >>>
%
% NAME              TYPE, DEFAULT      DESCRIPTION
% scaling_factor    scalar             scaling factor for iKs
% 
%                    >>> OUTPUT VARIABLES >>>
%
% NAME              TYPE, DEFAULT      DESCRIPTION
% fitness           scalar             fitness of the Paci model fit
%
% Author: Eric Liu
% Date:   13/07/18

% Here are the experimental results of the voltage clamp iKs current
% density experiments (current densities measured in pA/pF):

data_iKr =[ -0.4913,  ...    % -70mV
            -0.0112,  ...    % -60mV
             0.3762,  ...    % -50mV
             0.7226,  ...    % -40mV
             1.0652   ...    % -30mV             
             1.8283,  ...    % -20mV
             2.8620,  ...    % -10mV
             3.4178,  ...    %   0mV
             3.8957,  ...    % +10mV
             4.2523,  ...    % +20mV
             4.7768,  ...    % +30mV
             5.4879];  ...   % +40mV 

% For data that is 
i = 1;
model_iKr = zeros(1,12);

for Vclamp = -0.07:0.01:0.04
    
    % Run the Paci model under the current voltage clamp
    [VOI, ~, ALGEBRAIC, ~] = Paci_VoltageClamp_iKr(Vclamp,[iKr_scaling_factors(1),iKr_scaling_factors(2),iKr_scaling_factors(3)]);
    
    % Identify the index at which the clamp has been running for 400
    % milliseconds i.e. t = 2.4s (since the model runs for 2 seconds before 
    % clamping)
    [~,i_400ms] = min(abs(2.4-VOI));
    
    % Identify the iKs amplitude at t = 6s
    model_iKr(i) = ALGEBRAIC(i_400ms,54);   
    
    i = i + 1;
end

% Determine fitness
fitness = sum(abs(model_iKr - data_iKr));

% Write to text file

fileid = fopen('fitness.txt','a');
fprintf(fileid, '\n Fitness = %f \t iKr scaling factors = %f %f %f', fitness, iKr_scaling_factors);
fclose(fileid);
end