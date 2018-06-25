function [b_V,p_V,APD,max_upstroke,upstroke_V,upstroke_i,V90,V_90_t] = initialise(V,t)

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
% APD           scalar             action potential duration at 90%
% max_upstroke  scalar             maximum rate of upstroke
% upstroke_V    scalar             membrane voltage at maximum upstroke
% upstroke_i    scalar             index when maximum upstroke occurs
% V90           scalar             10% of baseline voltage to maximum voltage 
% V90_t         scalar array       times at which V90 occurs


% Finding baseline voltage and peak voltage
[b_V, ~] = min(V);
[p_V, p_i] = max(V);

% Find maximum upstroke
diff_1 = diff(V);
[max_upstroke, upstroke_i] = max(diff_1);
upstroke_V = V(upstroke_i);

max_upstroke = max_upstroke/(t(upstroke_i+1)-t(upstroke_i));

%% Determine action potential duration

% Determine V90 
V90 = p_V-(p_V - b_V)*0.9;

% Determine indices at which V90 occur
V_90_i = [0,0];
[~,V_90_i(1)] = min(abs(V(1:p_i)-V90));     % Index prior to peak voltage
[~,V_90_i(2)] = min(abs(V(p_i:end)-V90));   % Index after peak voltage
V_90_i(2) = V_90_i(2) + p_i;            
V_90_t = t(V_90_i);                         % Convert to time

APD = V_90_t(2) - V_90_t(1);                % Calculate APD

V_90_t = V_90_t(1);                         % Select the first time of occurrence
end