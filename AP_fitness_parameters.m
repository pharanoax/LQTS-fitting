function [b_V,p_V,APD] = AP_fitness_parameters(V,t)

% This function will take in an array of voltages representing membrane
% potential and then output some constants to set as parameter defaults in
% the model to be fitted
%
%                    >>> INPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% V             scalar array       membrane voltage
% t             scalar array       time points for each voltage point
% 
%                    >>> OUTPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% b_V           scalar             baseline potential voltage
% p_V           scalar             peak volage
% APD           scalar             action potential duration at 50%

%% Finding baseline voltage and peak voltage
    [b_V, ~] = min(V);
    [p_V, p_i] = max(V);
    
%% Determine action potential duration
    % Determine V90 
    V50 = p_V-(p_V - b_V)*0.5;

    % Determine indices at which V90 occur
    V_50_i = [0,0];
    [~,V_50_i(1)] = min(abs(V(1:p_i)-V50));     % Index prior to peak voltage
    [~,V_50_i(2)] = min(abs(V(p_i:end)-V50));   % Index after peak voltage
    V_50_i(2) = V_50_i(2) + p_i;            
    V_50_t = t(V_50_i);                         % Convert to time

    APD = V_50_t(2) - V_50_t(1);                % Calculate APD
end