function [baseline_voltage,peak_voltage,APD,rise_time] = find_AP_characteristics(V,t)

% This function will take in an array of voltages representing a single 
% membrane potential and then output certain charactersitics of the membrane
%
%                    >>> INPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% V             scalar array       membrane voltage
% t             scalar array       time points for each voltage point
% 
%                    >>> OUTPUT VARIABLES >>>
%
% NAME              TYPE, DEFAULT      DESCRIPTION
% baseline_voltage  scalar             baseline potential voltage
% peak_voltage      scalar             peak volage
% APD               scalar             action potential duration at 50%
% rise_time         scalar             time required for action potential 
%                                       to reach peak voltage from baseline 
%                                       voltage

% 1. Determine baseline voltage and peak voltage
    [peak_voltage, p_i] = max(V);
    [baseline_voltage, ~] = min(V(1:p_i));


% 2. Determine action potential duration

    % Determine voltage at 50% of the membrane potential range 
    V50 = peak_voltage-(peak_voltage - baseline_voltage)*0.5;

    % Determine indices at which V50 occur
    V_50_i = [0,0];
    [~,V_50_i(1)] = min(abs(V(1:p_i)-V50));     % Index prior to peak voltage
    [~,V_50_i(2)] = min(abs(V(p_i:end)-V50));   % Index after peak voltage
    V_50_i(2) = V_50_i(2) + p_i; 

    % Calculate APD50
    V_50_t = t(V_50_i);                         % Convert to time
    APD = V_50_t(2) - V_50_t(1);                % Calculate APD in terms of time

% 3. Determine rise time

    % Determine time index for time of peak voltage minus APD50
    rise_band_start_t = t(p_i) - APD;
    [~, rise_band_start_i] = min(abs(t(1:p_i)-rise_band_start_t));
    
    % Select data points that lie within the defined rise band
    rise_band = rise_band_start_i:p_i;
    rise_AP = V(rise_band);

    % Connect a straight line between the starting voltage and end voltage 
    % of the rise band
    m = ( V(p_i) - V(rise_band_start_i) ) / (t(p_i) - t(rise_band_start_i)) ; 
    line = V(rise_band_start_i) + m*(t(rise_band)-t(rise_band_start_i)) ; 

    % Determine the time point at which the perpendicular distance between
    % the linear line and the action potential is at its greatest.
    
    max_distance = 0;

    for i = rise_band_start_i:p_i
        
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
    
    % Convert the starting rise time into the rise time duration
    rise_time = t(p_i) - t(rise_idx);
    
end