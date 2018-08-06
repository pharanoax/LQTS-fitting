function [ p_V, b_V, APD50, rise_time, RR ] = Paci_Parameters( t, V )

% This function finds the parameters for the objective function from the model from the
% final action potential after steady state has been achieved
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
% APD50         scalar             action potential duration at 50%
% upstroke_rate scalar             maximum rate of upstroke
% upstroke_V    scalar             membrane voltage at maximum upstroke
% upstroke_t    scalar             time from first minimum when maximum upstroke occurs


% Find the peaks and the minimums
[mins, locs_mins]=findpeaks(-V);
mins=-mins;
[~, locs_pks]=findpeaks(V);

% Isolate the final AP
APend = length(mins);
assert(APend>2,'The data does not contain two distinct Action potentials')
FinalAP_V = V(locs_mins(APend-1):locs_mins(APend));
FinalAP_t = t(locs_mins(APend-1):locs_mins(APend));

% Determine the rise index
dVdt = diff(FinalAP_V);
[~, rise_index] = min(abs(dVdt-2));

% Store the parameters
[b_V, ~] = min(FinalAP_V);
[p_V, p_i] = max(FinalAP_V);
APD50 = APD(FinalAP_V,FinalAP_t,b_V,p_V,p_i); % Call the APD90 function
rise_time = FinalAP_t(p_i) - FinalAP_t(rise_index);
RR = t(locs_pks(APend)) - t(locs_pks(APend-1));

end

