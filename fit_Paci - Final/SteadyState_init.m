function [SS_VOI, SS_STATES] = SteadyState_init( t1, ScalingFactors, iKr_parameters, iKs_parameters, initSTATES )

% This function finds the time that the paci model needs to be run for to
% achieve steady state, so the final outputs include steady state.
%
%                    >>> INPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% t1            scalar array       initial guess for the length of time
% 
%                    >>> OUTPUT VARIABLES >>>
%
% NAME          TYPE, DEFAULT      DESCRIPTION
% SS_VOI        scalar array       VOI till steady state is reached (s)
% SS_STATES     scalar array       STATES till steady state is reached (V)


SStime = t1;
SS = 0;
while ~SS % While steady state has not been reached
    
    if SStime > 500
        break
    end
%     assert(SStime < 400,'The data does not reach steady state')
    
    % Run the model for the current guess of the length of time
    [SS_VOI, SS_STATES, ~, ~] = Paci_modSS_Init(SStime, ScalingFactors,iKr_parameters, iKs_parameters,initSTATES);
     % Determine if SS has been achieved
    [ SS ] = IsSteadyState( SS_STATES(:,1),SS_VOI);
    % Increase the time to run for by t1
    SStime = SStime+t1;
    

end
% SStime = SStime - t1 % Display the time it took to reach steady state

end

