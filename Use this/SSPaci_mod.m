function [ Paci_pk, Paci_min, Paci_APD50, Paci_RiseTime, Paci_RR ] = SSPaci_mod( ScalingFactors )

% This function identifies the parameters required for the objective function
% from a steady state action potential

%                    >>> OUTPUT VARIABLES >>>
%
% NAME                  TYPE, DEFAULT      DESCRIPTION
% Paci_min              scalar             baseline potential voltage
% Paci_pk               scalar             peak volage
% Paci_APD90            scalar             action potential duration at 90%
% Paci_RiseTime         scalar             undefined
% Paci_RR               scalar             time between the previous and
%                                           current peak


% Run the model till steady state has been reached
[SS_VOI, SS_STATES] = SteadyState_mod( 200, ScalingFactors ); % the initial guess is 200 seconds

% Run the Paci model till steady state
SS_STATES(:,1) = SS_STATES(:,1)*1000; % Change volts to milivolts for membrane voltage

% Obtain parameters from the steady state action potential of the Paci Model
[ Paci_pk, Paci_min, Paci_APD50, Paci_RiseTime, ...
    Paci_RR ] = Paci_Parameters( SS_VOI, SS_STATES(:,1) );
end

