function [SS_VOI, SS_STATES] = SteadyState( t1 )

% This function finds the time that the paci model needs to be run for to
% achieve steady state
%
%                    >>> INPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% t1            scalar array       initial guess for the length of time
% 
%                    >>> OUTPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% SS_VOI        scalar array       VOI till steady state is reached
% SS_STATES     scalar array       STATES till steady state is reached


SStime = t1;
SS = 0;
while ~SS % While steady state has not been reached
    % Run the model for the current guess of the length of time
    [SS_VOI, SS_STATES, ~, ~] = Paci_SS(SStime);
     % Determine if SS has been achieved
    [ SS ] = IsSteadyState( SS_STATES(:,1),SS_VOI);
    % Increase the time to run for by t1
    SStime = SStime+t1;

end


end

