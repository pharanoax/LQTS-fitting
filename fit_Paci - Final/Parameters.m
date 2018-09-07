function [ p_V, b_V, APD50, rise_time, RR ] = Parameters( t, V )

% This function finds the parameters for the objective function from the model from the
% final action potential after steady state has been achieved
%
%                    >>> INPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% V             scalar array       membrane voltage (mV)
% t             scalar array       time points for each voltage point (ms)
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

% plot(t,V)

% Find the peaks and the minimums
[mins, locs_mins]=findpeaks(-V);
mins=-mins;
[pks, locs_pks]=findpeaks(V);

% Isolate the final AP
APend = length(mins);
assert(APend>2,'The data does not contain two distinct Action potentials')
FinalAP_V = V(locs_mins(APend-1):locs_mins(APend));
FinalAP_t = t(locs_mins(APend-1):locs_mins(APend));

% Store the parameters
[b_V, ~] = min(FinalAP_V);
[p_V, Final_p_i] = max(FinalAP_V);
APD50 = APD(FinalAP_V,FinalAP_t,b_V,p_V,Final_p_i); % Call the APD50 function

% Rise Time
V10 = b_V + 0.1*(p_V-b_V);
V90 = b_V + 0.9*(p_V-b_V);

[~, V10_i] = min(abs(FinalAP_V(1:Final_p_i)-V10));
[~, V90_i] = min(abs(FinalAP_V(1:Final_p_i)-V90));

rise_time = t(V90_i) - t(V10_i);

% Store the parameters

RR = t(locs_pks(APend)) - t(locs_pks(APend-1));

end