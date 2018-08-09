function fitness = iKs_setup(iKs_scaling_factors,iKs_data)

% This function will assess the fitness of how well a scaled iKs current in
% the Paci model fits to the voltage clamped data clamped from -50mV to 
% +60mV in 10mV increments.

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

i = 1;
model_iKs = zeros(1,10);

for Vclamp = -0.05:0.01:0.04
    
    % Run the Paci model under the current voltage clamp
    [VOI, ~, ALGEBRAIC, ~] = Paci_VoltageClamp_iKs(Vclamp,[iKs_scaling_factors(1),iKs_scaling_factors(2)]);
    
    % Identify the index at which the clamp has been running for 4 seconds
    % i.e. t = 6s (since the model runs for 2 seconds before clamping)
    [~,i_6s] = min(abs(6-VOI));
    
    % Identify the iKs amplitude at t = 6s
    model_iKs(i) = ALGEBRAIC(i_6s,55);   
    
    i = i + 1;
end

% Determine fitness
fitness = sum(abs(model_iKs - iKs_data));

fileid = fopen('fitness.txt','a');
fprintf(fileid, '\n Fitness = %f \t iKs scaling factors = %f %f', fitness, iKs_scaling_factors);
fclose(fileid);

end