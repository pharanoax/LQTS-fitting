function APD90 = APD(V,t,b_V,p_V,p_i)

% This function will take in an array of voltages representing a sequence
% of membrane potentials and apply a low pass filter
%
%                    >>> INPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% V             scalar array       membrane voltage for single AP
% t             scalar array       time
% 
%                    >>> OUTPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% APD           scalar             APD90

% Calculating the voltage that achieves APD90
Amplitude = p_V-b_V;
limit = b_V+0.1*Amplitude;

% Interpolating to find the start and end of the APD90
y1 = (V(1:p_i));
x1 = t(1:p_i);
[y1, index1] = unique(y1);
AP_start = interp1(y1,x1(index1),limit,'spline');

y2 = V(p_i:length(V));
x2 = t(p_i:length(V));
[y2, index2] = unique(y2); 
AP_end = interp1(y2,x2(index2),limit,'spline');

% Calculating the APD90
APD90 = AP_end - AP_start;

% Plotting the start and end of the APD90
%     hold on
%     plot(AP_start,limit,'-o');
%     plot(AP_end,limit,'-o');
    



end