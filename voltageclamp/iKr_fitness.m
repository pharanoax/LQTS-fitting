function fitness = iKr_fitness(scaling_factor)

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

data_iKr =[ -0.8369,  ...    % -70mV
            -0.0187,  ...    % -60mV
             0.6155,  ...    % -50mV
             1.1168,  ...    % -40mV
             1.7450   ...    % -30mV             
             2.6301,  ...    % -20mV
             3.7660,  ...    % -10mV
             4.6810,  ...    %   0mV
             6.1103,  ...    % +10mV
             6.8733,  ...    % +20mV
             7.6432,  ...    % +30mV
             8.7075,  ...    % +40mV 
             10.1791, ...    % +50mV
             10.8078, ...    % +60mV
             10.7685];       % +70mV
    



% For data that is 
i = 1;
model_iKr = zeros(1,12);

for Vclamp = -0.07:0.01:0.07
    
    % Run the Paci model under the current voltage clamp
    [VOI, ~, ALGEBRAIC, ~] = Paci_VoltageClamp(Vclamp,[1,scaling_factor]);
    
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

end