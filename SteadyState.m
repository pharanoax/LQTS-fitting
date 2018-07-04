function [ SStime ] = SteadyState( t1 )

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
% SStime        scalar             The time required for the model to reach
%                                   steady state


% Boundaries for where the limit of how long is required to reach steady
% state lies between
t0 = 0;
t2 = 100;

while t0 ~= t1
    % Run the model for the current guess of the length of time
    [VOI, STATES, ~, ~] = Paci_SS(t1);
     % Determine if SS has been achieved
    [ SS ] = IsSteadyState( STATES(:,1),VOI);
    
    % Update boundaries depending on whether steady state has been achieved
    if SS
        t2 = t1;
        t1 = t0 + floor((t2-t0)/2);
    else
        t0 =t1;
        t1 = t1 + floor((t2-t0)/2);   
    end
end

SStime = t2; % Time for steady state (seconds)
end

