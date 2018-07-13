function [ VOI, STATES, ALGEBRAIC, CONSTANTS ] = VoltageClamp( )
% This  function will call the paci model and held at -80mV then clamped at
% 2 seconds to the Vclamp which will be looped below. The code can output
% the IKR and IKS current density plots for each sweep. The clamp is run
% till 8 seconds

i = 1;

figure
for Vclamp = -0.07:0.01:0.07
    [VOI, STATES, ALGEBRAIC, CONSTANTS] = Paci_VoltageClamp(Vclamp);
      
%     subplot(15,1,i)
%     plot(VOI, ALGEBRAIC(:,54), VOI, ALGEBRAIC(:,55))
%     legend(' IKR',' IKS')
%     xlabel('time(s)')
%     ylabel('Current density (A/F)')
%     i = i+1;

end