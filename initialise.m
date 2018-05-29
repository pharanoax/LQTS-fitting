function [V,b_V,p_V,APD,max_upstroke,upstroke_V,upstroke_i,V_90,V_90_t] = initialise(V,t)

% This function will take in an array of voltages representing membrane
% potential and then output some constants to set as parameter defaults in
% the model to be fitted
%
%                    >>> INPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% V             scalar array       membrane voltage
% t             scalar array       time points for each voltage point
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
% upstroke_i    scalar             index when maximum upstroke occurs
% V90_i         scalar             indices at which 10% of max voltage
%                                  occurs


% Finding baseline voltage and peak voltage
[b_V, ~] = min(V);
[p_V, p_i] = max(V);

% Determine APD

% First determine the first derivative
diff_1 = diff(V);
[max_upstroke, upstroke_i] = max(diff_1);
upstroke_V = V(upstroke_i);

% % Find the next time point where membrane potential returns to upstroke_V
% upstroke_count = 0;
% i = upstroke_i;
% 
% while upstroke_count <1
%     if i > p_i
%         if (V(i) < (upstroke_V + 1)) && (V(i) > (upstroke_V - 1))
%             upstroke_count = 1;
%         end
%     end
%     i = i+1;
% end
% 
% %

V_90 = p_V-(p_V - b_V)*0.9;
V_90_i = [0,0];
[~,V_90_i(1)] = min(abs(V(1:p_i)-V_90));
[~,V_90_i(2)] = min(abs(V(p_i:end)-V_90));
V_90_i(2) = V_90_i(2) + p_i;
V_90_t = t(V_90_i);

APD = V_90_t(2) - V_90_t(1);

end