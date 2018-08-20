function [ SS ] = IsSteadyState( V,t )

% This function determines if a given run from the Paci model is at
% steady state
%
%                    >>> INPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% V             scalar array       Membrane Voltage
% t             scalar array       time points for each voltage point
% 
%                    >>> OUTPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% SS            scalar             Either 1 = true (steady state achieved)
%                                         0 = false


V=V*1000; % Convert to mV from V
t=t*1000; % Convert to ms from s


% Find the peaks and minimums
[mins, locs_mins]=findpeaks(-V);
mins=-mins;

[pks, locs_pks]=findpeaks(V);
pks_pos = find(pks>0);
if length(pks_pos)<length(pks)
    
    pks = pks(pks_pos(1:length(pks_pos)-1));
    locs_pks = locs_pks(pks_pos(1:length(pks_pos)-1));
    pks_time = t(locs_pks);
    
    mins = mins(pks_pos(1:length(pks_pos)-1));
    locs_mins = locs_mins(pks_pos(1:length(pks_pos)-1));
    mins_time = t(locs_mins);
else
    pks_time = t(locs_pks);
    mins_time = t(locs_mins);
end


% % Plot the mins and peaks on the plot of the action potential
% figure
% plot(t,V);
% hold on
% plot(mins_time,mins,'o');
% plot(pks_time,pks,'o');

% Isolate the final two action potentials of the data two compare
APend = length(mins);
assert(APend>2,'The data does not contain two distinct Action potentials')
FinalAP_V = V(locs_mins(APend-1):locs_mins(APend));
FinalAP_t = t(locs_mins(APend-1):locs_mins(APend));
SemiFinalAP_V = V(locs_mins(APend-2):locs_mins(APend-1));
SemiFinalAP_t = t(locs_mins(APend-2):locs_mins(APend-1));
% Indicate the final two action potentials on the plot
% plot(FinalAP_t,FinalAP_V,SemiFinalAP_t,SemiFinalAP_V)

% % Determine the Rise Time
% FinalAP_dVdt = diff(FinalAP_V);
% [~, FinalAP_rise_i] = min(abs(FinalAP_dVdt-2));
% FinalAP_rise_time = t(locs_pks(length(pks))) - FinalAP_t(FinalAP_rise_i);
% 
% SemiFinalAP_dVdt = diff(SemiFinalAP_V);
% [~, SemiFinalAP_rise_i] = min(abs(SemiFinalAP_dVdt-2));
% SemiFinalAP_rise_time = t(locs_pks(length(pks)-1)) - SemiFinalAP_t(SemiFinalAP_rise_i);

% Define a tolerance to determine steady state
tol = 1e-1;

% Identify the difference for each parameter between the two action
% potentials
Diff(1) = (mins(length(mins))-mins(length(mins)-1)); % minimun
Diff(2) = (pks(length(pks))-pks(length(pks)-1)); % peak
Diff(3) = (FinalAP_t(length(FinalAP_t)) - (FinalAP_t(1))) - ...
    (SemiFinalAP_t(length(SemiFinalAP_t)) - (SemiFinalAP_t(1))); % APD
% Diff(4) = FinalAP_rise_time - SemiFinalAP_rise_time; % Rise time

% If each parameter difference is within the tolerance, steady state has
% been achieved

if abs(Diff)<tol
    SS = 1; % Steady State has been reached
else
    SS=0; % Steady hasn't been reached
end

end
