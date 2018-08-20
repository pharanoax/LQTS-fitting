function [AP_start, AP_end] = first_AP(V,threshold)

% This function will take in an array of voltages representing a sequence
% of membrane potentials and isolate a single action potential
%
%                    >>> INPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% V             scalar array       membrane voltage
% threshold     scalar             minimum height a peak must have.
%                                  Specifiy to be 0 if you do not want to 
%                                  use a threshold.
% 
%                    >>> OUTPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% AP            scalar array       membrane voltage of a single AP

% Identify the maximum voltage achieved in the patch clamp recording
max_voltage = max(V);

% Find all the local maxima that pass the threshold and occurs outside the
% minimum separation from the previous peak voltage.

if threshold == 0
    [~, upstroke_idx] = findpeaks(V);
else
    [~, upstroke_idx] = findpeaks(V,'MinPeakHeight',threshold*max_voltage);
end

% Find the occurrence of each baseline between consecutive maximum
% upstrokes to isolate an action potential
try
[~,AP_start] = min(V(upstroke_idx(1):upstroke_idx(2)));
[~,AP_end] = min(V(upstroke_idx(2):upstroke_idx(3)));
catch
    disp('Error: Consecutive upstroke indices were not found');
end

AP_start = AP_start + upstroke_idx(1);
AP_end = AP_end + upstroke_idx(2);

end

% Out