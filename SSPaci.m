function [ Paci_pk, Paci_min, Paci_APD90, Paci_upstroke_rate, Paci_upstroke_V, Paci_upstroke_t ] = SSPaci(  )

% This function identifies the parameters required for the objective function
% from a steady state action potential

%                    >>> OUTPUT VARIABLES >>>
%
% NAME                  TYPE, DEFAULT      DESCRIPTION
% Paci_min              scalar             baseline potential voltage
% Paci_pk               scalar             peak volage
% Paci_APD90            scalar             action potential duration at 90%
% Paci_upstroke_rate    scalar             maximum rate of upstroke
% Paci_upstroke_V       scalar             membrane voltage at maximum upstroke
% Paci_upstroke_t       scalar             time from first minimum when maximum upstroke occurs


% Run the model till steady state has been reached
[SS_VOI, SS_STATES] = SteadyState( 50 ); % the initial guess is 50 seconds

% Run the Paci model till steady state
SS_STATES(:,1) = SS_STATES(:,1)*1000; % Change volts to milivolts for membrane voltage

% Obtain parameters from the steady state action potential of the Paci Model
[ Paci_pk, Paci_min, Paci_APD90, Paci_upstroke_rate, Paci_upstroke_V, ...
    Paci_upstroke_t ] = Paci_Parameters( SS_VOI, SS_STATES(:,1) );
end

