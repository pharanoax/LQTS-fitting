function [ Paci_pk, Paci_min, Paci_APD90, Paci_upstroke_rate, Paci_upstroke_V, Paci_upstroke_t ] = SSPaci(  )

% This function identifies the parameters required for the objective function
% from a steady state action potential, after the time for steady state has
% been determined

%                    >>> OUTPUT VARIABLES >>>
%
% NAME                  TYPE, DEFAULT      DESCRIPTION
% Paci_min              scalar             baseline potential voltage
% Paci_pk               scalar             peak volage
% Paci_APD90            scalar             action potential duration at 90%
% Paci_upstroke_rate    scalar             maximum rate of upstroke
% Paci_upstroke_V       scalar             membrane voltage at maximum upstroke
% Paci_upstroke_t       scalar             time from first minimum when maximum upstroke occurs


% Determine how many seconds the model needs to run for to achieve steady
% state
SStime = SteadyState( 50 ); % the initial guess is 50seconds

% Run the Paci model till steady state
[VOI, STATES, ALGEBRAIC, CONSTANTS] = Paci_SS(SStime); % VOI is in seconds
STATES(:,1) = STATES(:,1)*1000; % Change volts to milivolts

% Obtain parameters from the steady state action potential of the Paci Model
[ Paci_pk, Paci_min, Paci_APD90, Paci_upstroke_rate, Paci_upstroke_V, ...
    Paci_upstroke_t ] = Paci_Parameters( VOI, STATES(:,1) );
end

