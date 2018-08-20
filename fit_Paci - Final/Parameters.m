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

% Identify the final peak position with respect to all the data - for rise
% time code
pk_i = locs_pks(length(pks));
if pk_i>locs_mins(APend)
    pk_i = locs_pks(length(pks)-1);
end

% Determine the rise index
    % Determine time index for time of peak voltage minus APD50
%     rise_band_start_t = t(length(locs_pks)) - APD50;
%     [~, rise_band_start_i] = min(abs(t(1:locs_pks)-rise_band_start_t));
    %rise_band_start_t =t(locs_mins(APend-1);
    rise_band_start_i = locs_mins(APend-1);
    
    % Select data points that lie within the defined rise band
    rise_band = rise_band_start_i:pk_i;
    rise_AP = V(rise_band);

    % Connect a straight line between the starting voltage and end voltage 
    % of the rise band
    m = ( V(pk_i) - V(rise_band_start_i) ) / (t(pk_i) - t(rise_band_start_i)) ; 
    line = V(rise_band_start_i) + m*(t(rise_band)-t(rise_band_start_i)) ; 

    % Determine the time point at which the perpendicular distance between
    % the linear line and the action potential is at its greatest.
    
    max_distance = 0;

    for i = rise_band_start_i:pk_i
        
        % Calculate the perpendicular at the current time point
        orthonormal = line(i+1-rise_band_start_i) - (t(rise_band)-t(rise_band_start_i))/m;
        
        % Determine point of intersection with the action potential
        [~, idx_AP_int] = min(abs(orthonormal-rise_AP));
        idx_AP_int = idx_AP_int - 1 + rise_band_start_i;
        V_AP_int = V(idx_AP_int);
        int_AP = [t(idx_AP_int), V_AP_int];
        
        % Determine the point of intersection with the straight line        
        [~, idx_line_int] = min(abs(orthonormal-line));
        idx_line_int = idx_line_int - 1 + rise_band_start_i;
        V_line_int = line(idx_line_int+1-rise_band_start_i);
        int_line = [t(idx_line_int), V_line_int];
        
        % Determine the distance between the two intersections
        distance = norm(int_AP-int_line);
        
        % Iteratively determine the time point at which maximum distance
        % between the two intersections is achieved
        if distance > max_distance
            max_distance = distance;
            rise_idx = i;
        end        
    end

% Store the parameters
rise_time = FinalAP_t(Final_p_i) - t(rise_idx);
RR = t(locs_pks(APend)) - t(locs_pks(APend-1));

end