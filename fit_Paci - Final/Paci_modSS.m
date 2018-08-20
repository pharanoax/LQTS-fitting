
function [VOI, STATES, ALGEBRAIC, CONSTANTS] = Paci_modSS(time, scaling_factors, iKr_parameters, iKs_parameters)
    % This is the Paci function which will allow certain parameters to be
    % linerly scaled:
    %
    %   #  Parameter Description                     Location in model
%   -----------------------------------------------------------------------
%   1   G_Na     Na maximal conductance              CONSTANTS(:,29) 
%   2   G_cal    CaL maximal conductance             CONSTANTS(:,30)
%   3   G_Kr     Kr maximal conductance              CONSTANTS(:,32)
%   4   G_Ks     Ks maximal conductance              CONSTANTS(:,35)
%   5   G_K1     K1 maximal conductance              CONSTANTS(:,36)   
%   6   G_f      If current maximal conductance      CONSTANTS(:,37)
%   7   P_NaK    NaK maximal conductance             CONSTANTS(:,43)                                        
%   8   k_NaCa   NaCa maximal conductance            CONSTANTS(:,44)
%   9   G_to     to maximal conductance              CONSTANTS(:,52)
%   10  G_PCa    PCa maximal conductance             CONSTANTS(:,50)
%   11  G_bNa    bNa maximal conductance             CONSTANTS(:,39)
%   12  G_bCa    bCa maximal conductance             CONSTANTS(:,40)

   [VOI, STATES, ALGEBRAIC, CONSTANTS] = solveModel(time, scaling_factors, iKr_parameters, iKs_parameters);
end

function [algebraicVariableCount] = getAlgebraicVariableCount()
    % Used later when setting a global variable with the number of algebraic variables.
    % Note: This is not the "main method".
    algebraicVariableCount =71;
end
% There are a total of 18 entries in each of the rate and state variable arrays.
% There are a total of 73 entries in the constant variable array.
%

function [VOI, STATES, ALGEBRAIC, CONSTANTS] = solveModel(time, scaling_factors, iKr_parameters, iKs_parameters)
    % Create ALGEBRAIC of correct size
    global algebraicVariableCount;  algebraicVariableCount = getAlgebraicVariableCount();
    % Initialise constants and state variables
    [INIT_STATES, CONSTANTS] = initConsts(scaling_factors, iKr_parameters, iKs_parameters);

    % Set timespan to solve over
    tspan = [0, time];

    % Set numerical accuracy options for ODE solver
    options = odeset('RelTol', 1e-06, 'AbsTol', 1e-06, 'MaxStep', 1);

    % Solve model with ODE solver
    [VOI, STATES] = ode15s(@(VOI, STATES)computeRates(VOI, STATES, CONSTANTS,iKr_parameters, iKs_parameters), tspan, INIT_STATES, options);

    % Compute algebraic variables
    [RATES, ALGEBRAIC] = computeRates(VOI, STATES, CONSTANTS, iKr_parameters, iKs_parameters);
    ALGEBRAIC = computeAlgebraic(ALGEBRAIC, CONSTANTS, STATES, VOI, iKr_parameters, iKs_parameters);
end

function [LEGEND_STATES, LEGEND_ALGEBRAIC, LEGEND_VOI, LEGEND_CONSTANTS] = createLegends()
    LEGEND_STATES = ''; LEGEND_ALGEBRAIC = ''; LEGEND_VOI = ''; LEGEND_CONSTANTS = '';
    LEGEND_VOI = strpad('time in component environment (second)');
    LEGEND_STATES(:,1) = strpad('Vm in component Membrane (volt)');
    LEGEND_ALGEBRAIC(:,53) = strpad('i_CaL in component i_CaL (A_per_F)');
    LEGEND_ALGEBRAIC(:,59) = strpad('i_K1 in component i_K1 (A_per_F)');
    LEGEND_ALGEBRAIC(:,60) = strpad('i_f in component i_f (A_per_F)');
    LEGEND_ALGEBRAIC(:,52) = strpad('i_Na in component i_Na (A_per_F)');
    LEGEND_ALGEBRAIC(:,54) = strpad('i_Kr in component i_Kr (A_per_F)');
    LEGEND_ALGEBRAIC(:,55) = strpad('i_Ks in component i_Ks (A_per_F)');
    LEGEND_ALGEBRAIC(:,66) = strpad('i_to in component i_to (A_per_F)');
    LEGEND_ALGEBRAIC(:,65) = strpad('i_PCa in component i_PCa (A_per_F)');
    LEGEND_ALGEBRAIC(:,63) = strpad('i_NaK in component i_NaK (A_per_F)');
    LEGEND_ALGEBRAIC(:,64) = strpad('i_NaCa in component i_NaCa (A_per_F)');
    LEGEND_ALGEBRAIC(:,62) = strpad('i_b_Ca in component i_b_Ca (A_per_F)');
    LEGEND_ALGEBRAIC(:,61) = strpad('i_b_Na in component i_b_Na (A_per_F)');
    LEGEND_ALGEBRAIC(:,11) = strpad('i_stim in component stim_mode (A_per_F)');
    LEGEND_CONSTANTS(:,1) = strpad('Cm in component model_parameters (farad)');
    LEGEND_CONSTANTS(:,2) = strpad('stim_flag in component stim_mode (dimensionless)');
    LEGEND_CONSTANTS(:,3) = strpad('i_stim_Start in component stim_mode (second)');
    LEGEND_CONSTANTS(:,4) = strpad('i_stim_End in component stim_mode (second)');
    LEGEND_CONSTANTS(:,5) = strpad('i_stim_Amplitude in component stim_mode (ampere)');
    LEGEND_CONSTANTS(:,6) = strpad('i_stim_frequency in component stim_mode (per_second)');
    LEGEND_CONSTANTS(:,66) = strpad('i_stim_Period in component stim_mode (second)');
    LEGEND_CONSTANTS(:,7) = strpad('i_stim_PulseDuration in component stim_mode (second)');
    LEGEND_CONSTANTS(:,8) = strpad('TTX_3uM in component current_blockers (dimensionless)');
    LEGEND_CONSTANTS(:,9) = strpad('TTX_10uM in component current_blockers (dimensionless)');
    LEGEND_CONSTANTS(:,10) = strpad('TTX_30uM in component current_blockers (dimensionless)');
    LEGEND_CONSTANTS(:,11) = strpad('E4031_30nM in component current_blockers (dimensionless)');
    LEGEND_CONSTANTS(:,12) = strpad('E4031_100nM in component current_blockers (dimensionless)');
    LEGEND_CONSTANTS(:,13) = strpad('nifed_3nM in component current_blockers (dimensionless)');
    LEGEND_CONSTANTS(:,14) = strpad('nifed_10nM in component current_blockers (dimensionless)');
    LEGEND_CONSTANTS(:,15) = strpad('nifed_30nM in component current_blockers (dimensionless)');
    LEGEND_CONSTANTS(:,16) = strpad('nifed_100nM in component current_blockers (dimensionless)');
    LEGEND_CONSTANTS(:,17) = strpad('Chromanol_iKs30 in component current_blockers (dimensionless)');
    LEGEND_CONSTANTS(:,18) = strpad('Chromanol_iKs50 in component current_blockers (dimensionless)');
    LEGEND_CONSTANTS(:,19) = strpad('Chromanol_iKs70 in component current_blockers (dimensionless)');
    LEGEND_CONSTANTS(:,20) = strpad('Chromanol_iKs90 in component current_blockers (dimensionless)');
    LEGEND_ALGEBRAIC(:,26) = strpad('E_Na in component electric_potentials (volt)');
    LEGEND_CONSTANTS(:,67) = strpad('E_K in component electric_potentials (volt)');
    LEGEND_ALGEBRAIC(:,40) = strpad('E_Ks in component electric_potentials (volt)');
    LEGEND_ALGEBRAIC(:,49) = strpad('E_Ca in component electric_potentials (volt)');
    LEGEND_CONSTANTS(:,21) = strpad('R in component model_parameters (joule_per_mole_kelvin)');
    LEGEND_CONSTANTS(:,22) = strpad('T in component model_parameters (kelvin)');
    LEGEND_CONSTANTS(:,23) = strpad('F in component model_parameters (coulomb_per_mole)');
    LEGEND_STATES(:,2) = strpad('Nai in component sodium_dynamics (millimolar)');
    LEGEND_CONSTANTS(:,24) = strpad('Nao in component model_parameters (millimolar)');
    LEGEND_STATES(:,3) = strpad('Cai in component calcium_dynamics (millimolar)');
    LEGEND_CONSTANTS(:,25) = strpad('Cao in component model_parameters (millimolar)');
    LEGEND_CONSTANTS(:,26) = strpad('Ki in component model_parameters (millimolar)');
    LEGEND_CONSTANTS(:,27) = strpad('Ko in component model_parameters (millimolar)');
    LEGEND_CONSTANTS(:,28) = strpad('PkNa in component electric_potentials (dimensionless)');
    LEGEND_CONSTANTS(:,29) = strpad('g_Na in component i_Na (S_per_F)');
    LEGEND_STATES(:,4) = strpad('m in component i_Na_m_gate (dimensionless)');
    LEGEND_STATES(:,5) = strpad('h in component i_Na_h_gate (dimensionless)');
    LEGEND_STATES(:,6) = strpad('j in component i_Na_j_gate (dimensionless)');
    LEGEND_CONSTANTS(:,68) = strpad('TTX_coeff in component i_Na (dimensionless)');
    LEGEND_ALGEBRAIC(:,1) = strpad('m_inf in component i_Na_m_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,41) = strpad('tau_m in component i_Na_m_gate (second)');
    LEGEND_ALGEBRAIC(:,16) = strpad('alpha_m in component i_Na_m_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,31) = strpad('beta_m in component i_Na_m_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,2) = strpad('h_inf in component i_Na_h_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,17) = strpad('alpha_h in component i_Na_h_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,32) = strpad('beta_h in component i_Na_h_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,42) = strpad('tau_h in component i_Na_h_gate (second)');
    LEGEND_ALGEBRAIC(:,3) = strpad('j_inf in component i_Na_j_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,18) = strpad('alpha_j in component i_Na_j_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,33) = strpad('beta_j in component i_Na_j_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,43) = strpad('tau_j in component i_Na_j_gate (second)');
    LEGEND_CONSTANTS(:,30) = strpad('g_CaL in component i_CaL (metre_cube_per_F_per_s)');
    LEGEND_STATES(:,7) = strpad('d in component i_CaL_d_gate (dimensionless)');
    LEGEND_STATES(:,8) = strpad('f1 in component i_CaL_f1_gate (dimensionless)');
    LEGEND_STATES(:,9) = strpad('f2 in component i_CaL_f2_gate (dimensionless)');
    LEGEND_STATES(:,10) = strpad('fCa in component i_CaL_fCa_gate (dimensionless)');
    LEGEND_CONSTANTS(:,69) = strpad('nifed_coeff in component i_CaL (dimensionless)');
    LEGEND_ALGEBRAIC(:,4) = strpad('d_infinity in component i_CaL_d_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,50) = strpad('tau_d in component i_CaL_d_gate (second)');
    LEGEND_ALGEBRAIC(:,19) = strpad('alpha_d in component i_CaL_d_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,34) = strpad('beta_d in component i_CaL_d_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,44) = strpad('gamma_d in component i_CaL_d_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,5) = strpad('f1_inf in component i_CaL_f1_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,35) = strpad('tau_f1 in component i_CaL_f1_gate (second)');
    LEGEND_ALGEBRAIC(:,20) = strpad('constf1 in component i_CaL_f1_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,6) = strpad('f2_inf in component i_CaL_f2_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,21) = strpad('tau_f2 in component i_CaL_f2_gate (second)');
    LEGEND_CONSTANTS(:,70) = strpad('constf2 in component i_CaL_f2_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,51) = strpad('constfCa in component i_CaL_fCa_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,7) = strpad('alpha_fCa in component i_CaL_fCa_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,22) = strpad('beta_fCa in component i_CaL_fCa_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,36) = strpad('gamma_fCa in component i_CaL_fCa_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,45) = strpad('fCa_inf in component i_CaL_fCa_gate (dimensionless)');
    LEGEND_CONSTANTS(:,31) = strpad('tau_fCa in component i_CaL_fCa_gate (second)');
    LEGEND_CONSTANTS(:,32) = strpad('g_Kr in component i_Kr (S_per_F)');
    LEGEND_STATES(:,11) = strpad('Xr1 in component i_Kr_Xr1_gate (dimensionless)');
    LEGEND_STATES(:,12) = strpad('Xr2 in component i_Kr_Xr2_gate (dimensionless)');
    LEGEND_CONSTANTS(:,71) = strpad('E4031_coeff in component i_Kr (dimensionless)');
    LEGEND_ALGEBRAIC(:,8) = strpad('Xr1_inf in component i_Kr_Xr1_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,23) = strpad('alpha_Xr1 in component i_Kr_Xr1_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,37) = strpad('beta_Xr1 in component i_Kr_Xr1_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,46) = strpad('tau_Xr1 in component i_Kr_Xr1_gate (second)');
    LEGEND_CONSTANTS(:,33) = strpad('L0 in component i_Kr_Xr1_gate (dimensionless)');
    LEGEND_CONSTANTS(:,72) = strpad('V_half in component i_Kr_Xr1_gate (millivolt)');
    LEGEND_CONSTANTS(:,34) = strpad('Q in component i_Kr_Xr1_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,9) = strpad('Xr2_infinity in component i_Kr_Xr2_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,24) = strpad('alpha_Xr2 in component i_Kr_Xr2_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,38) = strpad('beta_Xr2 in component i_Kr_Xr2_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,47) = strpad('tau_Xr2 in component i_Kr_Xr2_gate (second)');
    LEGEND_CONSTANTS(:,35) = strpad('g_Ks in component i_Ks (S_per_F)');
    LEGEND_STATES(:,13) = strpad('Xs in component i_Ks_Xs_gate (dimensionless)');
    LEGEND_CONSTANTS(:,73) = strpad('Chromanol_coeff in component i_Ks (dimensionless)');
    LEGEND_ALGEBRAIC(:,10) = strpad('Xs_infinity in component i_Ks_Xs_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,25) = strpad('alpha_Xs in component i_Ks_Xs_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,39) = strpad('beta_Xs in component i_Ks_Xs_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,48) = strpad('tau_Xs in component i_Ks_Xs_gate (second)');
    LEGEND_CONSTANTS(:,36) = strpad('g_K1 in component i_K1 (S_per_F)');
    LEGEND_ALGEBRAIC(:,58) = strpad('XK1_inf in component i_K1 (dimensionless)');
    LEGEND_ALGEBRAIC(:,56) = strpad('alpha_K1 in component i_K1 (dimensionless)');
    LEGEND_ALGEBRAIC(:,57) = strpad('beta_K1 in component i_K1 (dimensionless)');
    LEGEND_CONSTANTS(:,37) = strpad('g_f in component i_f (S_per_F)');
    LEGEND_CONSTANTS(:,38) = strpad('E_f in component i_f (volt)');
    LEGEND_STATES(:,14) = strpad('Xf in component i_f_Xf_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,12) = strpad('Xf_infinity in component i_f_Xf_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,27) = strpad('tau_Xf in component i_f_Xf_gate (second)');
    LEGEND_CONSTANTS(:,39) = strpad('g_b_Na in component i_b_Na (S_per_F)');
    LEGEND_CONSTANTS(:,40) = strpad('g_b_Ca in component i_b_Ca (S_per_F)');
    LEGEND_CONSTANTS(:,41) = strpad('Km_K in component i_NaK (millimolar)');
    LEGEND_CONSTANTS(:,42) = strpad('Km_Na in component i_NaK (millimolar)');
    LEGEND_CONSTANTS(:,43) = strpad('PNaK in component i_NaK (A_per_F)');
    LEGEND_CONSTANTS(:,44) = strpad('kNaCa in component i_NaCa (A_per_F)');
    LEGEND_CONSTANTS(:,45) = strpad('alpha in component i_NaCa (dimensionless)');
    LEGEND_CONSTANTS(:,46) = strpad('gamma in component i_NaCa (dimensionless)');
    LEGEND_CONSTANTS(:,47) = strpad('Ksat in component i_NaCa (dimensionless)');
    LEGEND_CONSTANTS(:,48) = strpad('KmCa in component i_NaCa (millimolar)');
    LEGEND_CONSTANTS(:,49) = strpad('KmNai in component i_NaCa (millimolar)');
    LEGEND_CONSTANTS(:,50) = strpad('g_PCa in component i_PCa (A_per_F)');
    LEGEND_CONSTANTS(:,51) = strpad('KPCa in component i_PCa (millimolar)');
    LEGEND_CONSTANTS(:,52) = strpad('g_to in component i_to (S_per_F)');
    LEGEND_STATES(:,15) = strpad('q in component i_to_q_gate (dimensionless)');
    LEGEND_STATES(:,16) = strpad('r in component i_to_r_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,13) = strpad('q_inf in component i_to_q_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,28) = strpad('tau_q in component i_to_q_gate (second)');
    LEGEND_ALGEBRAIC(:,14) = strpad('r_inf in component i_to_r_gate (dimensionless)');
    LEGEND_ALGEBRAIC(:,29) = strpad('tau_r in component i_to_r_gate (second)');
    LEGEND_CONSTANTS(:,53) = strpad('Vc in component model_parameters (micrometre_cube)');
    LEGEND_CONSTANTS(:,54) = strpad('V_SR in component model_parameters (micrometre_cube)');
    LEGEND_STATES(:,17) = strpad('Ca_SR in component calcium_dynamics (millimolar)');
    LEGEND_CONSTANTS(:,55) = strpad('a_rel in component calcium_dynamics (millimolar_per_second)');
    LEGEND_CONSTANTS(:,56) = strpad('b_rel in component calcium_dynamics (millimolar)');
    LEGEND_CONSTANTS(:,57) = strpad('c_rel in component calcium_dynamics (millimolar_per_second)');
    LEGEND_STATES(:,18) = strpad('g in component calcium_dynamics (dimensionless)');
    LEGEND_CONSTANTS(:,58) = strpad('tau_g in component calcium_dynamics (second)');
    LEGEND_ALGEBRAIC(:,15) = strpad('g_inf in component calcium_dynamics (dimensionless)');
    LEGEND_CONSTANTS(:,59) = strpad('Kup in component calcium_dynamics (millimolar)');
    LEGEND_CONSTANTS(:,60) = strpad('Buf_C in component calcium_dynamics (millimolar)');
    LEGEND_CONSTANTS(:,61) = strpad('Buf_SR in component calcium_dynamics (millimolar)');
    LEGEND_CONSTANTS(:,62) = strpad('Kbuf_C in component calcium_dynamics (millimolar)');
    LEGEND_CONSTANTS(:,63) = strpad('Kbuf_SR in component calcium_dynamics (millimolar)');
    LEGEND_ALGEBRAIC(:,70) = strpad('Cai_bufc in component calcium_dynamics (dimensionless)');
    LEGEND_ALGEBRAIC(:,71) = strpad('Ca_SR_bufSR in component calcium_dynamics (dimensionless)');
    LEGEND_CONSTANTS(:,64) = strpad('VmaxUp in component calcium_dynamics (millimolar_per_second)');
    LEGEND_ALGEBRAIC(:,30) = strpad('const2 in component calcium_dynamics (dimensionless)');
    LEGEND_CONSTANTS(:,65) = strpad('V_leak in component calcium_dynamics (per_second)');
    LEGEND_ALGEBRAIC(:,67) = strpad('i_rel in component calcium_dynamics (millimolar_per_second)');
    LEGEND_ALGEBRAIC(:,68) = strpad('i_up in component calcium_dynamics (millimolar_per_second)');
    LEGEND_ALGEBRAIC(:,69) = strpad('i_leak in component calcium_dynamics (millimolar_per_second)');
    LEGEND_RATES(:,1) = strpad('d/dt Vm in component Membrane (volt)');
    LEGEND_RATES(:,4) = strpad('d/dt m in component i_Na_m_gate (dimensionless)');
    LEGEND_RATES(:,5) = strpad('d/dt h in component i_Na_h_gate (dimensionless)');
    LEGEND_RATES(:,6) = strpad('d/dt j in component i_Na_j_gate (dimensionless)');
    LEGEND_RATES(:,7) = strpad('d/dt d in component i_CaL_d_gate (dimensionless)');
    LEGEND_RATES(:,8) = strpad('d/dt f1 in component i_CaL_f1_gate (dimensionless)');
    LEGEND_RATES(:,9) = strpad('d/dt f2 in component i_CaL_f2_gate (dimensionless)');
    LEGEND_RATES(:,10) = strpad('d/dt fCa in component i_CaL_fCa_gate (dimensionless)');
    LEGEND_RATES(:,11) = strpad('d/dt Xr1 in component i_Kr_Xr1_gate (dimensionless)');
    LEGEND_RATES(:,12) = strpad('d/dt Xr2 in component i_Kr_Xr2_gate (dimensionless)');
    LEGEND_RATES(:,13) = strpad('d/dt Xs in component i_Ks_Xs_gate (dimensionless)');
    LEGEND_RATES(:,14) = strpad('d/dt Xf in component i_f_Xf_gate (dimensionless)');
    LEGEND_RATES(:,15) = strpad('d/dt q in component i_to_q_gate (dimensionless)');
    LEGEND_RATES(:,16) = strpad('d/dt r in component i_to_r_gate (dimensionless)');
    LEGEND_RATES(:,2) = strpad('d/dt Nai in component sodium_dynamics (millimolar)');
    LEGEND_RATES(:,18) = strpad('d/dt g in component calcium_dynamics (dimensionless)');
    LEGEND_RATES(:,3) = strpad('d/dt Cai in component calcium_dynamics (millimolar)');
    LEGEND_RATES(:,17) = strpad('d/dt Ca_SR in component calcium_dynamics (millimolar)');
    LEGEND_STATES  = LEGEND_STATES';
    LEGEND_ALGEBRAIC = LEGEND_ALGEBRAIC';
    LEGEND_RATES = LEGEND_RATES';
    LEGEND_CONSTANTS = LEGEND_CONSTANTS';
end

function [STATES, CONSTANTS] = initConsts(scaling_factors, iKr_parameters, iKs_parameters)
    VOI = 0; CONSTANTS = []; STATES = []; ALGEBRAIC = [];
    STATES(:,1) = -0.0743340057623841;
    CONSTANTS(:,1) = 9.87109e-11;
    CONSTANTS(:,2) = 0;
    CONSTANTS(:,3) = 0;
    CONSTANTS(:,4) = 800;
    CONSTANTS(:,5) = 5.5e-10;
    CONSTANTS(:,6) = 60;
    CONSTANTS(:,7) = 0.005;
    CONSTANTS(:,8) = 0;
    CONSTANTS(:,9) = 0;
    CONSTANTS(:,10) = 0;
    CONSTANTS(:,11) = 0;
    CONSTANTS(:,12) = 0;
    CONSTANTS(:,13) = 0;
    CONSTANTS(:,14) = 0;
    CONSTANTS(:,15) = 0;
    CONSTANTS(:,16) = 0;
    CONSTANTS(:,17) = 0;
    CONSTANTS(:,18) = 0;
    CONSTANTS(:,19) = 0;
    CONSTANTS(:,20) = 0;
    CONSTANTS(:,21) = 8.314472;
    CONSTANTS(:,22) = 310;
    CONSTANTS(:,23) = 96485.3415;
    STATES(:,2) = 10.9248496211574;
    CONSTANTS(:,24) = 140;
    STATES(:,3) = 1.80773974140477e-5;
    CONSTANTS(:,25) = 1.8;
    CONSTANTS(:,26) = 120;
    CONSTANTS(:,27) = 5.4;
    CONSTANTS(:,28) = 0.03;
    CONSTANTS(:,29) = scaling_factors(1)*3671.2302;
    STATES(:,4) = 0.102953468725004;
    STATES(:,5) = 0.786926637881461;
    STATES(:,6) = 0.253943221774722;
    CONSTANTS(:,30) = scaling_factors(2)*8.635702e-5;
    STATES(:,7) = 8.96088425225182e-5;
    STATES(:,8) = 0.970411811263976;
    STATES(:,9) = 0.999965815466749;
    STATES(:,10) = 0.998925296531804;
    CONSTANTS(:,31) = 0.002;
    CONSTANTS(:,32) = iKr_parameters(1)*29.8667;
    STATES(:,11) = 0.00778547011240132;
    STATES(:,12) = 0.432162576531617;
    CONSTANTS(:,33) = 0.025;
    CONSTANTS(:,34) = 2.3;
    CONSTANTS(:,35) = iKs_parameters(1)*2.041;
    STATES(:,13) = 0.0322944866983666;
    CONSTANTS(:,36) = scaling_factors(3)*28.1492;
    CONSTANTS(:,37) = scaling_factors(4)*30.10312;
    CONSTANTS(:,38) = -0.017;
    STATES(:,14) = 0.100615100568753;
    CONSTANTS(:,39) = scaling_factors(9)*0.9;
    CONSTANTS(:,40) = scaling_factors(10)*0.69264;
    CONSTANTS(:,41) = 1;
    CONSTANTS(:,42) = 40;
    CONSTANTS(:,43) = scaling_factors(5)*1.841424;
    CONSTANTS(:,44) = scaling_factors(6)*4900;
    CONSTANTS(:,45) = 2.8571432;
    CONSTANTS(:,46) = 0.35;
    CONSTANTS(:,47) = 0.1;
    CONSTANTS(:,48) = 1.38;
    CONSTANTS(:,49) = 87.5;
    CONSTANTS(:,50) = scaling_factors(8)*0.4125;
    CONSTANTS(:,51) = 0.0005;
    CONSTANTS(:,52) = scaling_factors(7)*29.9038;
    STATES(:,15) = 0.839295925773219;
    STATES(:,16) = 0.00573289893326379;
    CONSTANTS(:,53) = 8800;
    CONSTANTS(:,54) = 583.73;
    STATES(:,17) = -0.2734234751931;
    CONSTANTS(:,55) = 16.464;
    CONSTANTS(:,56) = 0.25;
    CONSTANTS(:,57) = 8.232;
    STATES(:,18) = 0.999999981028517;
    CONSTANTS(:,58) = 0.002;
    CONSTANTS(:,59) = 0.00025;
    CONSTANTS(:,60) = 0.25;
    CONSTANTS(:,61) = 10;
    CONSTANTS(:,62) = 0.001;
    CONSTANTS(:,63) = 0.3;
    CONSTANTS(:,64) = 0.56064;
    CONSTANTS(:,65) = 0.00044444;
    CONSTANTS(:,66) = 60.0000./CONSTANTS(:,6);
    CONSTANTS(:,67) =  (( CONSTANTS(:,21).*CONSTANTS(:,22))./CONSTANTS(:,23)).*log(CONSTANTS(:,27)./CONSTANTS(:,26));
    CONSTANTS(:,68) = piecewise({CONSTANTS(:,8)==1.00000, 0.180000 , CONSTANTS(:,9)==1.00000, 0.0600000 , CONSTANTS(:,10)==1.00000, 0.0200000 }, 1.00000);
    CONSTANTS(:,69) = piecewise({CONSTANTS(:,13)==1.00000, 0.930000 , CONSTANTS(:,14)==1.00000, 0.790000 , CONSTANTS(:,15)==1.00000, 0.560000 , CONSTANTS(:,16)==1.00000, 0.280000 }, 1.00000);
    CONSTANTS(:,70) = 1.00000;
    CONSTANTS(:,71) = piecewise({CONSTANTS(:,11)==1.00000, 0.770000 , CONSTANTS(:,12)==1.00000, 0.500000 }, 1.00000);
    CONSTANTS(:,72) =  1000.00.*( ((  - CONSTANTS(:,21).*CONSTANTS(:,22))./( CONSTANTS(:,23).*CONSTANTS(:,34))).*log(power(1.00000+CONSTANTS(:,25)./2.60000, 4.00000)./( CONSTANTS(:,33).*power(1.00000+CONSTANTS(:,25)./0.580000, 4.00000))) - 0.0190000);
    CONSTANTS(:,73) = piecewise({CONSTANTS(:,17)==1.00000, 0.700000 , CONSTANTS(:,18)==1.00000, 0.500000 , CONSTANTS(:,19)==1.00000, 0.300000 , CONSTANTS(:,20)==1.00000, 0.100000 }, 1.00000);
    if (isempty(STATES)), warning('Initial values for states not set');, end
end

function [RATES, ALGEBRAIC] = computeRates(VOI, STATES, CONSTANTS, iKr_parameters, iKs_parameters)
    global algebraicVariableCount;
    statesSize = size(STATES);
    statesColumnCount = statesSize(2);
    if ( statesColumnCount == 1)
        STATES = STATES';
        ALGEBRAIC = zeros(1, algebraicVariableCount);
        utilOnes = 1;
    else
        statesRowCount = statesSize(1);
        ALGEBRAIC = zeros(statesRowCount, algebraicVariableCount);
        RATES = zeros(statesRowCount, statesColumnCount);
        utilOnes = ones(statesRowCount, 1);
    end
    ALGEBRAIC(:,6) = 0.330000+0.670000./(1.00000+exp(( STATES(:,1).*1000.00+35.0000)./4.00000));
    ALGEBRAIC(:,21) = ( ( 600.000.*exp( - power( STATES(:,1).*1000.00+25.0000, 2.00000)./170.000)+(31.0000./(1.00000+exp((25.0000 -  STATES(:,1).*1000.00)./10.0000))+16.0000./(1.00000+exp((30.0000+ STATES(:,1).*1000.00)./10.0000)))).*CONSTANTS(:,70))./1000.00;
    RATES(:,9) = (ALGEBRAIC(:,6) - STATES(:,9))./ALGEBRAIC(:,21);
    ALGEBRAIC(:,12) = 1.00000./(1.00000+exp(( STATES(:,1).*1000.00+77.8500)./5.00000));
    ALGEBRAIC(:,27) = (1900.00./(1.00000+exp(( STATES(:,1).*1000.00+15.0000)./10.0000)))./1000.00;
    RATES(:,14) = (ALGEBRAIC(:,12) - STATES(:,14))./ALGEBRAIC(:,27);
    ALGEBRAIC(:,13) = 1.00000./(1.00000+exp(( STATES(:,1).*1000.00+53.0000)./13.0000));
    ALGEBRAIC(:,28) = (6.06000+39.1020./( 0.570000.*exp(  - 0.0800000.*( STATES(:,1).*1000.00+44.0000))+ 0.0650000.*exp( 0.100000.*( STATES(:,1).*1000.00+45.9300))))./1000.00;
    RATES(:,15) = (ALGEBRAIC(:,13) - STATES(:,15))./ALGEBRAIC(:,28);
    ALGEBRAIC(:,14) = 1.00000./(1.00000+exp( - ( STATES(:,1).*1000.00 - 22.3000)./18.7500));
    ALGEBRAIC(:,29) = (2.75352+14.4052./( 1.03700.*exp( 0.0900000.*( STATES(:,1).*1000.00+30.6100))+ 0.369000.*exp(  - 0.120000.*( STATES(:,1).*1000.00+23.8400))))./1000.00;
    RATES(:,16) = (ALGEBRAIC(:,14) - STATES(:,16))./ALGEBRAIC(:,29);
    ALGEBRAIC(:,15) = piecewise({STATES(:,3)<=0.000350000, 1.00000./(1.00000+power(STATES(:,3)./0.000350000, 6.00000)) }, 1.00000./(1.00000+power(STATES(:,3)./0.000350000, 16.0000)));
    ALGEBRAIC(:,30) = piecewise({ALGEBRAIC(:,15)>STATES(:,18)&STATES(:,1)> - 0.0600000, 0.000000 }, 1.00000);
    RATES(:,18) = ( ALGEBRAIC(:,30).*(ALGEBRAIC(:,15) - STATES(:,18)))./CONSTANTS(:,58);
    ALGEBRAIC(:,5) = 1.00000./(1.00000+exp(( STATES(:,1).*1000.00+26.0000)./3.00000));
    ALGEBRAIC(:,20) = piecewise({ALGEBRAIC(:,5) - STATES(:,8)>0.000000, 1.00000+ 1433.00.*(STATES(:,3) -  50.0000.*1.00000e-06) }, 1.00000);
    ALGEBRAIC(:,35) = ( (20.0000+( 1102.50.*exp( - power(power( STATES(:,1).*1000.00+27.0000, 2.00000)./15.0000, 2.00000))+(200.000./(1.00000+exp((13.0000 -  STATES(:,1).*1000.00)./10.0000))+180.000./(1.00000+exp((30.0000+ STATES(:,1).*1000.00)./10.0000))))).*ALGEBRAIC(:,20))./1000.00;
    RATES(:,8) = (ALGEBRAIC(:,5) - STATES(:,8))./ALGEBRAIC(:,35);
    ALGEBRAIC(:,1) = 1.00000./power(1.00000+exp((  - STATES(:,1).*1000.00 - 34.1000)./5.90000), 1.00000./3.00000);
    ALGEBRAIC(:,16) = 1.00000./(1.00000+exp((  - STATES(:,1).*1000.00 - 60.0000)./5.00000));
    ALGEBRAIC(:,31) = 0.100000./(1.00000+exp(( STATES(:,1).*1000.00+35.0000)./5.00000))+0.100000./(1.00000+exp(( STATES(:,1).*1000.00 - 50.0000)./200.000));
    ALGEBRAIC(:,41) = ( 1.00000.*( ALGEBRAIC(:,16).*ALGEBRAIC(:,31)))./1000.00;
    RATES(:,4) = (ALGEBRAIC(:,1) - STATES(:,4))./ALGEBRAIC(:,41);
    ALGEBRAIC(:,2) = 1.00000./power((1.00000+exp(( STATES(:,1).*1000.00+72.1000)./5.70000)), 1.0 ./ 2);
    ALGEBRAIC(:,17) = piecewise({STATES(:,1)< - 0.0400000,  0.0570000.*exp( - ( STATES(:,1).*1000.00+80.0000)./6.80000) }, 0.000000);
    ALGEBRAIC(:,32) = piecewise({STATES(:,1)< - 0.0400000,  2.70000.*exp( 0.0790000.*( STATES(:,1).*1000.00))+ 3.10000.*( power(10.0000, 5.00000).*exp( 0.348500.*( STATES(:,1).*1000.00))) }, 0.770000./( 0.130000.*(1.00000+exp(( STATES(:,1).*1000.00+10.6600)./ - 11.1000))));
    ALGEBRAIC(:,42) = piecewise({STATES(:,1)< - 0.0400000, 1.50000./( (ALGEBRAIC(:,17)+ALGEBRAIC(:,32)).*1000.00) }, 2.54200./1000.00);
    RATES(:,5) = (ALGEBRAIC(:,2) - STATES(:,5))./ALGEBRAIC(:,42);
    ALGEBRAIC(:,3) = 1.00000./power((1.00000+exp(( STATES(:,1).*1000.00+72.1000)./5.70000)), 1.0 ./ 2);
    ALGEBRAIC(:,18) = piecewise({STATES(:,1)< - 0.0400000, ( (  - 25428.0.*exp( 0.244400.*( STATES(:,1).*1000.00)) -  6.94800.*( power(10.0000,  - 6.00000).*exp(  - 0.0439100.*( STATES(:,1).*1000.00)))).*( STATES(:,1).*1000.00+37.7800))./(1.00000+exp( 0.311000.*( STATES(:,1).*1000.00+79.2300))) }, 0.000000);
    ALGEBRAIC(:,33) = piecewise({STATES(:,1)< - 0.0400000, ( 0.0242400.*exp(  - 0.0105200.*( STATES(:,1).*1000.00)))./(1.00000+exp(  - 0.137800.*( STATES(:,1).*1000.00+40.1400))) }, ( 0.600000.*exp( 0.0570000.*( STATES(:,1).*1000.00)))./(1.00000+exp(  - 0.100000.*( STATES(:,1).*1000.00+32.0000))));
    ALGEBRAIC(:,43) = 7.00000./( (ALGEBRAIC(:,18)+ALGEBRAIC(:,33)).*1000.00);
    RATES(:,6) = (ALGEBRAIC(:,3) - STATES(:,6))./ALGEBRAIC(:,43);
    ALGEBRAIC(:,8) = 1.00000./(1.00000+exp((CONSTANTS(:,72) -  STATES(:,1).*1000.00)./4.90000));
    ALGEBRAIC(:,23) = 450.000./(1.00000+exp(( - 45.0000 -  STATES(:,1).*1000.00)./10.0000));
    ALGEBRAIC(:,37) = 6.00000./(1.00000+exp((30.0000+ STATES(:,1).*1000.00)./11.5000));
    ALGEBRAIC(:,46) = iKr_parameters(2)*( 1.00000.*( ALGEBRAIC(:,23).*ALGEBRAIC(:,37)))./1000.00;
    RATES(:,11) = (ALGEBRAIC(:,8) - STATES(:,11))./ALGEBRAIC(:,46);
    ALGEBRAIC(:,9) = 1.00000./(1.00000+exp(( STATES(:,1).*1000.00+88.0000)./50.0000));
    ALGEBRAIC(:,24) = 3.00000./(1.00000+exp(( - 60.0000 -  STATES(:,1).*1000.00)./20.0000));
    ALGEBRAIC(:,38) = 1.12000./(1.00000+exp(( - 60.0000+ STATES(:,1).*1000.00)./20.0000));
    ALGEBRAIC(:,47) = iKr_parameters(3)*( 1.00000.*( ALGEBRAIC(:,24).*ALGEBRAIC(:,38)))./1000.00;
    RATES(:,12) = (ALGEBRAIC(:,9) - STATES(:,12))./ALGEBRAIC(:,47);
    ALGEBRAIC(:,10) = 1.00000./(1.00000+exp((  - STATES(:,1).*1000.00 - 20.0000)./16.0000));
    ALGEBRAIC(:,25) = 1100.00./power((1.00000+exp(( - 10.0000 -  STATES(:,1).*1000.00)./6.00000)), 1.0 ./ 2);
    ALGEBRAIC(:,39) = 1.00000./(1.00000+exp(( - 60.0000+ STATES(:,1).*1000.00)./20.0000));
    ALGEBRAIC(:,48) = iKs_parameters(2)*( 1.00000.*( ALGEBRAIC(:,25).*ALGEBRAIC(:,39)))./1000.00;
    RATES(:,13) = (ALGEBRAIC(:,10) - STATES(:,13))./ALGEBRAIC(:,48);
    ALGEBRAIC(:,4) = 1.00000./(1.00000+exp( - ( STATES(:,1).*1000.00+9.10000)./7.00000));
    ALGEBRAIC(:,19) = 0.250000+1.40000./(1.00000+exp((  - STATES(:,1).*1000.00 - 35.0000)./13.0000));
    ALGEBRAIC(:,34) = 1.40000./(1.00000+exp(( STATES(:,1).*1000.00+5.00000)./5.00000));
    ALGEBRAIC(:,44) = 1.00000./(1.00000+exp((  - STATES(:,1).*1000.00+50.0000)./20.0000));
    ALGEBRAIC(:,50) = ( ( ALGEBRAIC(:,19).*ALGEBRAIC(:,34)+ALGEBRAIC(:,44)).*1.00000)./1000.00;
    RATES(:,7) = (ALGEBRAIC(:,4) - STATES(:,7))./ALGEBRAIC(:,50);
    ALGEBRAIC(:,7) = 1.00000./(1.00000+power(STATES(:,3)./0.000600000, 8.00000));
    ALGEBRAIC(:,22) = 0.100000./(1.00000+exp((STATES(:,3) - 0.000900000)./0.000100000));
    ALGEBRAIC(:,36) = 0.300000./(1.00000+exp((STATES(:,3) - 0.000750000)./0.000800000));
    ALGEBRAIC(:,45) = (ALGEBRAIC(:,7)+(ALGEBRAIC(:,22)+ALGEBRAIC(:,36)))./1.31560;
    ALGEBRAIC(:,51) = piecewise({STATES(:,1)> - 0.0600000&ALGEBRAIC(:,45)>STATES(:,10), 0.000000 }, 1.00000);
    RATES(:,10) = ( ALGEBRAIC(:,51).*(ALGEBRAIC(:,45) - STATES(:,10)))./CONSTANTS(:,31);
    ALGEBRAIC(:,26) =  (( CONSTANTS(:,21).*CONSTANTS(:,22))./CONSTANTS(:,23)).*log(CONSTANTS(:,24)./STATES(:,2));
    ALGEBRAIC(:,52) =  CONSTANTS(:,68).*( CONSTANTS(:,29).*( power(STATES(:,4), 3.00000).*( STATES(:,5).*( STATES(:,6).*(STATES(:,1) - ALGEBRAIC(:,26))))));
    ALGEBRAIC(:,63) = (( (( CONSTANTS(:,43).*CONSTANTS(:,27))./(CONSTANTS(:,27)+CONSTANTS(:,41))).*STATES(:,2))./(STATES(:,2)+CONSTANTS(:,42)))./(1.00000+( 0.124500.*exp((  - 0.100000.*( STATES(:,1).*CONSTANTS(:,23)))./( CONSTANTS(:,21).*CONSTANTS(:,22)))+ 0.0353000.*exp((  - STATES(:,1).*CONSTANTS(:,23))./( CONSTANTS(:,21).*CONSTANTS(:,22)))));
    ALGEBRAIC(:,64) = ( CONSTANTS(:,44).*( exp(( CONSTANTS(:,46).*( STATES(:,1).*CONSTANTS(:,23)))./( CONSTANTS(:,21).*CONSTANTS(:,22))).*( power(STATES(:,2), 3.00000).*CONSTANTS(:,25)) -  exp(( (CONSTANTS(:,46) - 1.00000).*( STATES(:,1).*CONSTANTS(:,23)))./( CONSTANTS(:,21).*CONSTANTS(:,22))).*( power(CONSTANTS(:,24), 3.00000).*( STATES(:,3).*CONSTANTS(:,45)))))./( (power(CONSTANTS(:,49), 3.00000)+power(CONSTANTS(:,24), 3.00000)).*( (CONSTANTS(:,48)+CONSTANTS(:,25)).*(1.00000+ CONSTANTS(:,47).*exp(( (CONSTANTS(:,46) - 1.00000).*( STATES(:,1).*CONSTANTS(:,23)))./( CONSTANTS(:,21).*CONSTANTS(:,22))))));
    ALGEBRAIC(:,61) =  CONSTANTS(:,39).*(STATES(:,1) - ALGEBRAIC(:,26));
    RATES(:,2) = (  - CONSTANTS(:,1).*(ALGEBRAIC(:,52)+(ALGEBRAIC(:,61)+( 3.00000.*ALGEBRAIC(:,63)+ 3.00000.*ALGEBRAIC(:,64)))))./( CONSTANTS(:,23).*( CONSTANTS(:,53).*1.00000e-18));
    ALGEBRAIC(:,53) =  (( (( CONSTANTS(:,30).*( 4.00000.*( STATES(:,1).*power(CONSTANTS(:,23), 2.00000))))./( CONSTANTS(:,21).*CONSTANTS(:,22))).*( STATES(:,3).*exp(( 2.00000.*( STATES(:,1).*CONSTANTS(:,23)))./( CONSTANTS(:,21).*CONSTANTS(:,22))) -  0.341000.*CONSTANTS(:,25)))./(exp(( 2.00000.*( STATES(:,1).*CONSTANTS(:,23)))./( CONSTANTS(:,21).*CONSTANTS(:,22))) - 1.00000)).*( STATES(:,7).*( STATES(:,8).*( STATES(:,9).*STATES(:,10))));
    ALGEBRAIC(:,56) = 3.91000./(1.00000+exp( 0.594200.*(( STATES(:,1).*1000.00 -  CONSTANTS(:,67).*1000.00) - 200.000)));
    ALGEBRAIC(:,57) = (  - 1.50900.*exp( 0.000200000.*(( STATES(:,1).*1000.00 -  CONSTANTS(:,67).*1000.00)+100.000))+exp( 0.588600.*(( STATES(:,1).*1000.00 -  CONSTANTS(:,67).*1000.00) - 10.0000)))./(1.00000+exp( 0.454700.*( STATES(:,1).*1000.00 -  CONSTANTS(:,67).*1000.00)));
    ALGEBRAIC(:,58) = ALGEBRAIC(:,56)./(ALGEBRAIC(:,56)+ALGEBRAIC(:,57));
    ALGEBRAIC(:,59) =  CONSTANTS(:,36).*( ALGEBRAIC(:,58).*( (STATES(:,1) - CONSTANTS(:,67)).*power((CONSTANTS(:,27)./5.40000), 1.0 ./ 2)));
    ALGEBRAIC(:,60) =  CONSTANTS(:,37).*( STATES(:,14).*(STATES(:,1) - CONSTANTS(:,38)));
    ALGEBRAIC(:,54) =  CONSTANTS(:,71).*( CONSTANTS(:,32).*( (STATES(:,1) - CONSTANTS(:,67)).*( STATES(:,11).*( STATES(:,12).*power((CONSTANTS(:,27)./5.40000), 1.0 ./ 2)))));
    ALGEBRAIC(:,40) =  (( CONSTANTS(:,21).*CONSTANTS(:,22))./CONSTANTS(:,23)).*log((CONSTANTS(:,27)+ CONSTANTS(:,28).*CONSTANTS(:,24))./(CONSTANTS(:,26)+ CONSTANTS(:,28).*STATES(:,2)));
    ALGEBRAIC(:,55) =  CONSTANTS(:,73).*( CONSTANTS(:,35).*( (STATES(:,1) - ALGEBRAIC(:,40)).*( power(STATES(:,13), 2.00000).*(1.00000+0.600000./(1.00000+power(( 3.80000.*1.00000e-05)./STATES(:,3), 1.40000))))));
    ALGEBRAIC(:,66) =  CONSTANTS(:,52).*( (STATES(:,1) - CONSTANTS(:,67)).*( STATES(:,15).*STATES(:,16)));
    ALGEBRAIC(:,65) = ( CONSTANTS(:,50).*STATES(:,3))./(STATES(:,3)+CONSTANTS(:,51));
    ALGEBRAIC(:,49) =  (( 0.500000.*( CONSTANTS(:,21).*CONSTANTS(:,22)))./CONSTANTS(:,23)).*log(CONSTANTS(:,25)./STATES(:,3));
    ALGEBRAIC(:,62) =  CONSTANTS(:,40).*(STATES(:,1) - ALGEBRAIC(:,49));
    ALGEBRAIC(:,11) = piecewise({VOI>=CONSTANTS(:,3)&(VOI<=CONSTANTS(:,4)&(VOI - CONSTANTS(:,3)) -  floor((VOI - CONSTANTS(:,3))./CONSTANTS(:,66)).*CONSTANTS(:,66)<=CONSTANTS(:,7)), ( CONSTANTS(:,2).*CONSTANTS(:,5))./CONSTANTS(:,1) }, 0.000000);
    RATES(:,1) =  - ((ALGEBRAIC(:,59)+(ALGEBRAIC(:,66)+(ALGEBRAIC(:,54)+(ALGEBRAIC(:,55)+(ALGEBRAIC(:,53)+(ALGEBRAIC(:,63)+(ALGEBRAIC(:,52)+(ALGEBRAIC(:,64)+(ALGEBRAIC(:,65)+(ALGEBRAIC(:,60)+(ALGEBRAIC(:,61)+ALGEBRAIC(:,62)))))))))))) - ALGEBRAIC(:,11));
    ALGEBRAIC(:,70) = 1.00000./(1.00000+( CONSTANTS(:,60).*CONSTANTS(:,62))./power(STATES(:,3)+CONSTANTS(:,62), 2.00000));
    ALGEBRAIC(:,67) =  (CONSTANTS(:,57)+( CONSTANTS(:,55).*power(STATES(:,17), 2.00000))./(power(CONSTANTS(:,56), 2.00000)+power(STATES(:,17), 2.00000))).*( STATES(:,7).*( STATES(:,18).*0.0411000));
    ALGEBRAIC(:,68) = CONSTANTS(:,64)./(1.00000+power(CONSTANTS(:,59), 2.00000)./power(STATES(:,3), 2.00000));
    ALGEBRAIC(:,69) =  (STATES(:,17) - STATES(:,3)).*CONSTANTS(:,65);
    RATES(:,3) =  ALGEBRAIC(:,70).*(((ALGEBRAIC(:,69) - ALGEBRAIC(:,68))+ALGEBRAIC(:,67)) - ( ((ALGEBRAIC(:,53)+(ALGEBRAIC(:,62)+ALGEBRAIC(:,65))) -  2.00000.*ALGEBRAIC(:,64)).*CONSTANTS(:,1))./( 2.00000.*( CONSTANTS(:,53).*( CONSTANTS(:,23).*1.00000e-18))));
    ALGEBRAIC(:,71) = 1.00000./(1.00000+( CONSTANTS(:,61).*CONSTANTS(:,63))./power(STATES(:,17)+CONSTANTS(:,63), 2.00000));
    RATES(:,17) =  (( ALGEBRAIC(:,71).*CONSTANTS(:,53))./CONSTANTS(:,54)).*(ALGEBRAIC(:,68) - (ALGEBRAIC(:,67)+ALGEBRAIC(:,69)));
   RATES = RATES';
end

% Calculate algebraic variables
function ALGEBRAIC = computeAlgebraic(ALGEBRAIC, CONSTANTS, STATES, VOI, iKr_parameters, iKs_parameters)
    statesSize = size(STATES);
    statesColumnCount = statesSize(2);
    if ( statesColumnCount == 1)
        STATES = STATES';
        utilOnes = 1;
    else
        statesRowCount = statesSize(1);
        utilOnes = ones(statesRowCount, 1);
    end
    ALGEBRAIC(:,6) = 0.330000+0.670000./(1.00000+exp(( STATES(:,1).*1000.00+35.0000)./4.00000));
    ALGEBRAIC(:,21) = ( ( 600.000.*exp( - power( STATES(:,1).*1000.00+25.0000, 2.00000)./170.000)+(31.0000./(1.00000+exp((25.0000 -  STATES(:,1).*1000.00)./10.0000))+16.0000./(1.00000+exp((30.0000+ STATES(:,1).*1000.00)./10.0000)))).*CONSTANTS(:,70))./1000.00;
    ALGEBRAIC(:,12) = 1.00000./(1.00000+exp(( STATES(:,1).*1000.00+77.8500)./5.00000));
    ALGEBRAIC(:,27) = (1900.00./(1.00000+exp(( STATES(:,1).*1000.00+15.0000)./10.0000)))./1000.00;
    ALGEBRAIC(:,13) = 1.00000./(1.00000+exp(( STATES(:,1).*1000.00+53.0000)./13.0000));
    ALGEBRAIC(:,28) = (6.06000+39.1020./( 0.570000.*exp(  - 0.0800000.*( STATES(:,1).*1000.00+44.0000))+ 0.0650000.*exp( 0.100000.*( STATES(:,1).*1000.00+45.9300))))./1000.00;
    ALGEBRAIC(:,14) = 1.00000./(1.00000+exp( - ( STATES(:,1).*1000.00 - 22.3000)./18.7500));
    ALGEBRAIC(:,29) = (2.75352+14.4052./( 1.03700.*exp( 0.0900000.*( STATES(:,1).*1000.00+30.6100))+ 0.369000.*exp(  - 0.120000.*( STATES(:,1).*1000.00+23.8400))))./1000.00;
    ALGEBRAIC(:,15) = piecewise({STATES(:,3)<=0.000350000, 1.00000./(1.00000+power(STATES(:,3)./0.000350000, 6.00000)) }, 1.00000./(1.00000+power(STATES(:,3)./0.000350000, 16.0000)));
    ALGEBRAIC(:,30) = piecewise({ALGEBRAIC(:,15)>STATES(:,18)&STATES(:,1)> - 0.0600000, 0.000000 }, 1.00000);
    ALGEBRAIC(:,5) = 1.00000./(1.00000+exp(( STATES(:,1).*1000.00+26.0000)./3.00000));
    ALGEBRAIC(:,20) = piecewise({ALGEBRAIC(:,5) - STATES(:,8)>0.000000, 1.00000+ 1433.00.*(STATES(:,3) -  50.0000.*1.00000e-06) }, 1.00000);
    ALGEBRAIC(:,35) = ( (20.0000+( 1102.50.*exp( - power(power( STATES(:,1).*1000.00+27.0000, 2.00000)./15.0000, 2.00000))+(200.000./(1.00000+exp((13.0000 -  STATES(:,1).*1000.00)./10.0000))+180.000./(1.00000+exp((30.0000+ STATES(:,1).*1000.00)./10.0000))))).*ALGEBRAIC(:,20))./1000.00;
    ALGEBRAIC(:,1) = 1.00000./power(1.00000+exp((  - STATES(:,1).*1000.00 - 34.1000)./5.90000), 1.00000./3.00000);
    ALGEBRAIC(:,16) = 1.00000./(1.00000+exp((  - STATES(:,1).*1000.00 - 60.0000)./5.00000));
    ALGEBRAIC(:,31) = 0.100000./(1.00000+exp(( STATES(:,1).*1000.00+35.0000)./5.00000))+0.100000./(1.00000+exp(( STATES(:,1).*1000.00 - 50.0000)./200.000));
    ALGEBRAIC(:,41) = ( 1.00000.*( ALGEBRAIC(:,16).*ALGEBRAIC(:,31)))./1000.00;
    ALGEBRAIC(:,2) = 1.00000./power((1.00000+exp(( STATES(:,1).*1000.00+72.1000)./5.70000)), 1.0 ./ 2);
    ALGEBRAIC(:,17) = piecewise({STATES(:,1)< - 0.0400000,  0.0570000.*exp( - ( STATES(:,1).*1000.00+80.0000)./6.80000) }, 0.000000);
    ALGEBRAIC(:,32) = piecewise({STATES(:,1)< - 0.0400000,  2.70000.*exp( 0.0790000.*( STATES(:,1).*1000.00))+ 3.10000.*( power(10.0000, 5.00000).*exp( 0.348500.*( STATES(:,1).*1000.00))) }, 0.770000./( 0.130000.*(1.00000+exp(( STATES(:,1).*1000.00+10.6600)./ - 11.1000))));
    ALGEBRAIC(:,42) = piecewise({STATES(:,1)< - 0.0400000, 1.50000./( (ALGEBRAIC(:,17)+ALGEBRAIC(:,32)).*1000.00) }, 2.54200./1000.00);
    ALGEBRAIC(:,3) = 1.00000./power((1.00000+exp(( STATES(:,1).*1000.00+72.1000)./5.70000)), 1.0 ./ 2);
    ALGEBRAIC(:,18) = piecewise({STATES(:,1)< - 0.0400000, ( (  - 25428.0.*exp( 0.244400.*( STATES(:,1).*1000.00)) -  6.94800.*( power(10.0000,  - 6.00000).*exp(  - 0.0439100.*( STATES(:,1).*1000.00)))).*( STATES(:,1).*1000.00+37.7800))./(1.00000+exp( 0.311000.*( STATES(:,1).*1000.00+79.2300))) }, 0.000000);
    ALGEBRAIC(:,33) = piecewise({STATES(:,1)< - 0.0400000, ( 0.0242400.*exp(  - 0.0105200.*( STATES(:,1).*1000.00)))./(1.00000+exp(  - 0.137800.*( STATES(:,1).*1000.00+40.1400))) }, ( 0.600000.*exp( 0.0570000.*( STATES(:,1).*1000.00)))./(1.00000+exp(  - 0.100000.*( STATES(:,1).*1000.00+32.0000))));
    ALGEBRAIC(:,43) = 7.00000./( (ALGEBRAIC(:,18)+ALGEBRAIC(:,33)).*1000.00);
    ALGEBRAIC(:,8) = 1.00000./(1.00000+exp((CONSTANTS(:,72) -  STATES(:,1).*1000.00)./4.90000));
    ALGEBRAIC(:,23) = 450.000./(1.00000+exp(( - 45.0000 -  STATES(:,1).*1000.00)./10.0000));
    ALGEBRAIC(:,37) = 6.00000./(1.00000+exp((30.0000+ STATES(:,1).*1000.00)./11.5000));
    ALGEBRAIC(:,46) = iKr_parameters(2)*( 1.00000.*( ALGEBRAIC(:,23).*ALGEBRAIC(:,37)))./1000.00;
    ALGEBRAIC(:,9) = 1.00000./(1.00000+exp(( STATES(:,1).*1000.00+88.0000)./50.0000));
    ALGEBRAIC(:,24) = 3.00000./(1.00000+exp(( - 60.0000 -  STATES(:,1).*1000.00)./20.0000));
    ALGEBRAIC(:,38) = 1.12000./(1.00000+exp(( - 60.0000+ STATES(:,1).*1000.00)./20.0000));
    ALGEBRAIC(:,47) = iKr_parameters(3)*( 1.00000.*( ALGEBRAIC(:,24).*ALGEBRAIC(:,38)))./1000.00;
    ALGEBRAIC(:,10) = 1.00000./(1.00000+exp((  - STATES(:,1).*1000.00 - 20.0000)./16.0000));
    ALGEBRAIC(:,25) = 1100.00./power((1.00000+exp(( - 10.0000 -  STATES(:,1).*1000.00)./6.00000)), 1.0 ./ 2);
    ALGEBRAIC(:,39) = 1.00000./(1.00000+exp(( - 60.0000+ STATES(:,1).*1000.00)./20.0000));
    ALGEBRAIC(:,48) = iKs_parameters(2)*( 1.00000.*( ALGEBRAIC(:,25).*ALGEBRAIC(:,39)))./1000.00;
    ALGEBRAIC(:,4) = 1.00000./(1.00000+exp( - ( STATES(:,1).*1000.00+9.10000)./7.00000));
    ALGEBRAIC(:,19) = 0.250000+1.40000./(1.00000+exp((  - STATES(:,1).*1000.00 - 35.0000)./13.0000));
    ALGEBRAIC(:,34) = 1.40000./(1.00000+exp(( STATES(:,1).*1000.00+5.00000)./5.00000));
    ALGEBRAIC(:,44) = 1.00000./(1.00000+exp((  - STATES(:,1).*1000.00+50.0000)./20.0000));
    ALGEBRAIC(:,50) = ( ( ALGEBRAIC(:,19).*ALGEBRAIC(:,34)+ALGEBRAIC(:,44)).*1.00000)./1000.00;
    ALGEBRAIC(:,7) = 1.00000./(1.00000+power(STATES(:,3)./0.000600000, 8.00000));
    ALGEBRAIC(:,22) = 0.100000./(1.00000+exp((STATES(:,3) - 0.000900000)./0.000100000));
    ALGEBRAIC(:,36) = 0.300000./(1.00000+exp((STATES(:,3) - 0.000750000)./0.000800000));
    ALGEBRAIC(:,45) = (ALGEBRAIC(:,7)+(ALGEBRAIC(:,22)+ALGEBRAIC(:,36)))./1.31560;
    ALGEBRAIC(:,51) = piecewise({STATES(:,1)> - 0.0600000&ALGEBRAIC(:,45)>STATES(:,10), 0.000000 }, 1.00000);
    ALGEBRAIC(:,26) =  (( CONSTANTS(:,21).*CONSTANTS(:,22))./CONSTANTS(:,23)).*log(CONSTANTS(:,24)./STATES(:,2));
    ALGEBRAIC(:,52) =  CONSTANTS(:,68).*( CONSTANTS(:,29).*( power(STATES(:,4), 3.00000).*( STATES(:,5).*( STATES(:,6).*(STATES(:,1) - ALGEBRAIC(:,26))))));
    ALGEBRAIC(:,63) = (( (( CONSTANTS(:,43).*CONSTANTS(:,27))./(CONSTANTS(:,27)+CONSTANTS(:,41))).*STATES(:,2))./(STATES(:,2)+CONSTANTS(:,42)))./(1.00000+( 0.124500.*exp((  - 0.100000.*( STATES(:,1).*CONSTANTS(:,23)))./( CONSTANTS(:,21).*CONSTANTS(:,22)))+ 0.0353000.*exp((  - STATES(:,1).*CONSTANTS(:,23))./( CONSTANTS(:,21).*CONSTANTS(:,22)))));
    ALGEBRAIC(:,64) = ( CONSTANTS(:,44).*( exp(( CONSTANTS(:,46).*( STATES(:,1).*CONSTANTS(:,23)))./( CONSTANTS(:,21).*CONSTANTS(:,22))).*( power(STATES(:,2), 3.00000).*CONSTANTS(:,25)) -  exp(( (CONSTANTS(:,46) - 1.00000).*( STATES(:,1).*CONSTANTS(:,23)))./( CONSTANTS(:,21).*CONSTANTS(:,22))).*( power(CONSTANTS(:,24), 3.00000).*( STATES(:,3).*CONSTANTS(:,45)))))./( (power(CONSTANTS(:,49), 3.00000)+power(CONSTANTS(:,24), 3.00000)).*( (CONSTANTS(:,48)+CONSTANTS(:,25)).*(1.00000+ CONSTANTS(:,47).*exp(( (CONSTANTS(:,46) - 1.00000).*( STATES(:,1).*CONSTANTS(:,23)))./( CONSTANTS(:,21).*CONSTANTS(:,22))))));
    ALGEBRAIC(:,61) =  CONSTANTS(:,39).*(STATES(:,1) - ALGEBRAIC(:,26));
    ALGEBRAIC(:,53) =  (( (( CONSTANTS(:,30).*( 4.00000.*( STATES(:,1).*power(CONSTANTS(:,23), 2.00000))))./( CONSTANTS(:,21).*CONSTANTS(:,22))).*( STATES(:,3).*exp(( 2.00000.*( STATES(:,1).*CONSTANTS(:,23)))./( CONSTANTS(:,21).*CONSTANTS(:,22))) -  0.341000.*CONSTANTS(:,25)))./(exp(( 2.00000.*( STATES(:,1).*CONSTANTS(:,23)))./( CONSTANTS(:,21).*CONSTANTS(:,22))) - 1.00000)).*( STATES(:,7).*( STATES(:,8).*( STATES(:,9).*STATES(:,10))));
    ALGEBRAIC(:,56) = 3.91000./(1.00000+exp( 0.594200.*(( STATES(:,1).*1000.00 -  CONSTANTS(:,67).*1000.00) - 200.000)));
    ALGEBRAIC(:,57) = (  - 1.50900.*exp( 0.000200000.*(( STATES(:,1).*1000.00 -  CONSTANTS(:,67).*1000.00)+100.000))+exp( 0.588600.*(( STATES(:,1).*1000.00 -  CONSTANTS(:,67).*1000.00) - 10.0000)))./(1.00000+exp( 0.454700.*( STATES(:,1).*1000.00 -  CONSTANTS(:,67).*1000.00)));
    ALGEBRAIC(:,58) = ALGEBRAIC(:,56)./(ALGEBRAIC(:,56)+ALGEBRAIC(:,57));
    ALGEBRAIC(:,59) =  CONSTANTS(:,36).*( ALGEBRAIC(:,58).*( (STATES(:,1) - CONSTANTS(:,67)).*power((CONSTANTS(:,27)./5.40000), 1.0 ./ 2)));
    ALGEBRAIC(:,60) =  CONSTANTS(:,37).*( STATES(:,14).*(STATES(:,1) - CONSTANTS(:,38)));
    ALGEBRAIC(:,54) =  CONSTANTS(:,71).*( CONSTANTS(:,32).*( (STATES(:,1) - CONSTANTS(:,67)).*( STATES(:,11).*( STATES(:,12).*power((CONSTANTS(:,27)./5.40000), 1.0 ./ 2)))));
    ALGEBRAIC(:,40) =  (( CONSTANTS(:,21).*CONSTANTS(:,22))./CONSTANTS(:,23)).*log((CONSTANTS(:,27)+ CONSTANTS(:,28).*CONSTANTS(:,24))./(CONSTANTS(:,26)+ CONSTANTS(:,28).*STATES(:,2)));
    ALGEBRAIC(:,55) =  CONSTANTS(:,73).*( CONSTANTS(:,35).*( (STATES(:,1) - ALGEBRAIC(:,40)).*( power(STATES(:,13), 2.00000).*(1.00000+0.600000./(1.00000+power(( 3.80000.*1.00000e-05)./STATES(:,3), 1.40000))))));
    ALGEBRAIC(:,66) =  CONSTANTS(:,52).*( (STATES(:,1) - CONSTANTS(:,67)).*( STATES(:,15).*STATES(:,16)));
    ALGEBRAIC(:,65) = ( CONSTANTS(:,50).*STATES(:,3))./(STATES(:,3)+CONSTANTS(:,51));
    ALGEBRAIC(:,49) =  (( 0.500000.*( CONSTANTS(:,21).*CONSTANTS(:,22)))./CONSTANTS(:,23)).*log(CONSTANTS(:,25)./STATES(:,3));
    ALGEBRAIC(:,62) =  CONSTANTS(:,40).*(STATES(:,1) - ALGEBRAIC(:,49));
    ALGEBRAIC(:,11) = piecewise({VOI>=CONSTANTS(:,3)&(VOI<=CONSTANTS(:,4)&(VOI - CONSTANTS(:,3)) -  floor((VOI - CONSTANTS(:,3))./CONSTANTS(:,66)).*CONSTANTS(:,66)<=CONSTANTS(:,7)), ( CONSTANTS(:,2).*CONSTANTS(:,5))./CONSTANTS(:,1) }, 0.000000);
    ALGEBRAIC(:,70) = 1.00000./(1.00000+( CONSTANTS(:,60).*CONSTANTS(:,62))./power(STATES(:,3)+CONSTANTS(:,62), 2.00000));
    ALGEBRAIC(:,67) =  (CONSTANTS(:,57)+( CONSTANTS(:,55).*power(STATES(:,17), 2.00000))./(power(CONSTANTS(:,56), 2.00000)+power(STATES(:,17), 2.00000))).*( STATES(:,7).*( STATES(:,18).*0.0411000));
    ALGEBRAIC(:,68) = CONSTANTS(:,64)./(1.00000+power(CONSTANTS(:,59), 2.00000)./power(STATES(:,3), 2.00000));
    ALGEBRAIC(:,69) =  (STATES(:,17) - STATES(:,3)).*CONSTANTS(:,65);
    ALGEBRAIC(:,71) = 1.00000./(1.00000+( CONSTANTS(:,61).*CONSTANTS(:,63))./power(STATES(:,17)+CONSTANTS(:,63), 2.00000));
end

% Compute result of a piecewise function
function x = piecewise(cases, default)
    set = [0];
    for i = 1:2:length(cases)
        if (length(cases{i+1}) == 1)
            x(cases{i} & ~set,:) = cases{i+1};
        else
            x(cases{i} & ~set,:) = cases{i+1}(cases{i} & ~set);
        end
        set = set | cases{i};
        if(set), break, end
    end
    if (length(default) == 1)
        x(~set,:) = default;
    else
        x(~set,:) = default(~set);
    end
end

% Pad out or shorten strings to a set length
function strout = strpad(strin)
    req_length = 160;
    insize = size(strin,2);
    if insize > req_length
        strout = strin(1:req_length);
    else
        strout = [strin, blanks(req_length - insize)];
    end
end

