function [V,b_V,p_V,APD,max_upstroke,upstroke_V,upstroke_t] = initialise(V,si)

% This function will take in an array of voltages representing membrane
% potential and then output some constants to set as parameter defaults in
% the model to be fitted
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
% V             scalar array       action potential voltages
% b_V           scalar             baseline potential voltage
% p_V           scalar             peak volage
% APD           scalar             action potential duration at 90%
% max_upstroke  scalar             maximum rate of upstroke
% upstroke_V    scalar             membrane voltage at maximum upstroke
% upstroke_t    scalar             time when maximum upstroke occurs

    
% Convert si from us to ms
si = si*10^(-3);

% Finding baseline voltage and peak voltage
[b_V, ~] = min(V);
[p_V, p_i] = max(V);

% Determine APD

% First determine the first derivative
diff_1 = diff(V);
[max_upstroke, upstroke_i] = max(diff_1);
upstroke_V = V(upstroke_i);

% Find the next time point where membrane potential returns to upstroke_V
upstroke_count = 0;
i = upstroke_i;

while upstroke_count <1
    if i > p_i
        if (V(i) < (upstroke_V + 0.0005)) && (V(i) > (upstroke_V - 0.0005))
            upstroke_count = 1;
        end
    end
    i = i+1;
end

% Calculate time of maximum upstroke and the APD
upstroke_t = upstroke_i*si;
APD = (i - upstroke_i)*si;

end