function filtered_V = LowpassFilter(V)

% This function will take in an array of voltages representing a sequence
% of membrane potentials and apply a low pass filter
%
%                    >>> INPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% V             scalar array       membrane voltage
% 
%                    >>> OUTPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% filtered_V    scalar array       membrane voltage of a single AP

d = fdesign.lowpass;
set (d, 'specification', 'N,Fc');
Hd=design(d,'window');
filtered_V = filter (Hd, V);


% h  = fdesign.lowpass('N,Fc', 10);
% Hd = design(h, 'window', 'Window', {@kaiser, 0.55});
% filtered_V = filter (Hd, data);

end