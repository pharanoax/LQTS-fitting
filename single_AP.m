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

% Assuming that the maximum heart rate that can occur in an iPSC cell is
% 100 bpm, this would mean that at least 600 ms has to pass before another
% baseline is reached.

% Identify first 3 points of maximum upstroke
diff_1 = diff(V);
i = 0;
upstroke_count = 0;
upstroke_idx = zeros(3,1);
while upstroke_count < 3
    i = i + 1;
    if diff_1(i) > 0.4
            upstroke_count = upstroke_count + 1;
            upstroke_idx(upstroke_count) = i;
            
            % Ensure that there is a minimum gap between each max upstroke
            i = i + 100;
    end
end

% Find the occurrence of each baseline between consecutive maximum
% upstrokes to isolate an action potential
[~,AP_start] = min(V(upstroke_idx(1):upstroke_idx(2)));
[~,AP_end] = min(V(upstroke_idx(2):upstroke_idx(3)));

AP_start = AP_start + upstroke_idx(1);
AP_end = AP_end + upstroke_idx(2);



