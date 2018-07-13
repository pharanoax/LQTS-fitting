function fitness = iKs_fitness(scaling_factor)

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

% Here are the experimental results of the voltage clamp iKs current
% density experiments (current densities measured in pA/pF):

data_iKs =[ 0.4190, ...     % -50mV
            0.4354, ...     % -40mV
            1.2245, ...     % -30mV
            2.5729, ...     % -20mV
            4.0918, ...     % -10mV
            4.5215, ...     %   0mV
            5.1320, ...     % +10mV
            5.0798, ...     % +20mV
            5.4478, ...     % +30mV 
            6.2990, ...     % +40mV
            7.0898, ...     % +50mV
            6.5984];        % +60mV
    



% For data that is 
i = 1;
model_iKs = zeros(1,12);

for Vclamp = -0.05:0.01:0.06
    
    % Run the Paci model under the current voltage clamp
    [VOI, ~, ALGEBRAIC, ~] = Paci_VoltageClamp(Vclamp,[scaling_factor,1]);
    
    % Identify the index at which the clamp has been running for 4 seconds
    % i.e. t = 6s (since the model runs for 2 seconds before clamping)
    [~,i_6s] = min(abs(6-VOI));
    
    % Identify the iKs amplitude at t = 6s
    model_iKs(i) = ALGEBRAIC(i_6s,55);   
    
    i = i + 1;
end

% Determine fitness
fitness = sum(abs(model_iKs - data_iKs));

end