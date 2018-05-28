function [AP_start, AP_end] = single_AP(V)

% This function will take in an array of voltages representing a sequence
% of membrane potentials and isolate a single action potential
%
%                    >>> INPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% V             scalar array       membrane voltage
% si            scalar             sampling rate (us)
% 
%                    >>> OUTPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% AP            scalar array       membrane voltage of a single AP

% Identify the maximum voltage achieved in the patch clamp recording
max_voltage = max(V);

% Determine a threshold based off the max voltage
threshold = 0.9*max_voltage;

% Find all the local maxima that pass the threshold and occurs outside the
% minimum separation from the previous peak voltage.

[~, upstroke_idx] = findpeaks(V,'MinPeakHeight',threshold);


% Find the occurrence of each baseline between consecutive maximum
% upstrokes to isolate an action potential
[~,AP_start] = min(V(upstroke_idx(1):upstroke_idx(2)));
[~,AP_end] = min(V(upstroke_idx(2):upstroke_idx(3)));

AP_start = AP_start + upstroke_idx(1);
AP_end = AP_end + upstroke_idx(2);




