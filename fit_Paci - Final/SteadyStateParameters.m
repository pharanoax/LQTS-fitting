function [ baseline_voltage,peak_voltage,APD,rise_time, RR_interval ] = SteadyStateParameters( ScalingFactors, iKr_parameters, iKs_parameters,initSTATES )

% This function identifies the parameters required for the objective function
% from a steady state action potential

%                    >>> OUTPUT VARIABLES >>>
%
% NAME                  TYPE, DEFAULT      DESCRIPTION
% baseline_voltage      scalar             baseline potential voltage
% peak_voltage          scalar             peak volage
% APD                   scalar             action potential duration at 50%
% rise_time             scalar             undefined
% RR_interval           scalar             time between the previous and
%                                           current peak


% Run the model till steady state has been reached
[SS_VOI, SS_STATES] = SteadyState_init( 200, ScalingFactors, iKr_parameters, iKs_parameters, initSTATES ); % the initial guess is 200 seconds

SS_STATES(:,1) = SS_STATES(:,1)*1000; % Change volts to milivolts for membrane voltage
% SS_VOI = SS_VOI*1000; % Change s to ms for time

% Obtain parameters from the steady state action potential of the Paci Model
[ peak_voltage,baseline_voltage,APD,rise_time, RR_interval ] = Parameters( SS_VOI, SS_STATES(:,1) );
end

