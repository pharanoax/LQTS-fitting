function [ p_V, b_V, APD90, upstroke_rate,upstroke_V,upstroke_t ] = Paci_Parameters( t, V )

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
% APD90         scalar             action potential duration at 90%
% upstroke_rate scalar             maximum rate of upstroke
% upstroke_V    scalar             membrane voltage at maximum upstroke
% upstroke_t    scalar             time from first minimum when maximum upstroke occurs


% Find the peaks and the minimums
[mins, locs_mins]=findpeaks(-V);
mins=-mins;
[pks, locs_pks]=findpeaks(V);

% Isolate the final AP
APend = length(mins);
assert(APend>2,'The data does not contain two distinct Action potentials')
FinalAP_V = V(locs_mins(APend-1):locs_mins(APend));
FinalAP_t = t(locs_mins(APend-1):locs_mins(APend));

% Determine the upstroke
[FinalAP_max_upstroke, FinalAP_max_upstroke_i] = max(diff(FinalAP_V));
dVfinaldt = FinalAP_max_upstroke/(t(FinalAP_max_upstroke_i+1)-t(FinalAP_max_upstroke_i));

% Store the parameters
[b_V, ~] = min(FinalAP_V);
[p_V, p_i] = max(FinalAP_V);
upstroke_rate = dVfinaldt;
upstroke_V = FinalAP_V(FinalAP_max_upstroke_i);
upstroke_t = (FinalAP_t(FinalAP_max_upstroke_i) - FinalAP_t(1));
APD90 = APD(FinalAP_V,FinalAP_t,b_V,p_V,p_i); % Call the APD90 function

end

