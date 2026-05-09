function p = dsti_model_iris_params()
%DSTI_MODEL_IRIS_PARAMS Calibration for dsti_model_iris.model.
%
% Example:
%   p = dsti_model_iris_params();
%   m = Model.fromFile("dsti_model_iris.model", Linear=true, Assign=p);
%   m = solve(steady(m));
%
% The derived parameters alpha_utlz, kappa_h, kappa_f, kappa_w, and
% kappa_rl are defined in the model file as IRIS dynamic links.

p = struct();

% Deep parameters
p.theta_h = 0.71;
p.theta_f = 0.83;
p.theta_w = 0.03;
p.kappa = 0.21;
p.theta_rl = 0.7;

% Household preferences and consumption-credit channel
p.h = 0.48;
p.sigma = 1.19;
p.alpha_p = 0.48;
p.bar_wlc = 0.42;
p.prm_crhh = 0.1;

% Open-economy and capital parameters
p.phi_ex = 0.46;
p.phi_asst = 0.004;
p.alpha_fc = 0.36;
p.delta = 0.04;
p.alpha_fdi = 0.4;
p.alpha_ks = 0.51;
p.ups_n = 1;
p.ups_k = 1;

% Price and wage Phillips curve parameters
p.gamma_h = 0.39;
p.beta = 0.9925;
p.gamma_f = 0.39;
p.eta = 1.53;
p.varphi = 2.62;
p.vartheta_z = 0.06;
p.gamma_w = 0.45;

% Credit and banking parameters
p.zeta = 0.39;
p.lambda1_hh = 0.57;
p.lambda2_hh = 0.52;
p.lambda3_hh = 0.45;
p.lambda4_hh = 0.37;
p.lambda5_hh = 0.37;
p.lambda1_frm = 0.15;
p.lambda2_frm = 0.54;
p.lambda3_frm = 0.57;
p.lambda4_frm = 0.38;
p.nu1 = 0.38;
p.nu2 = 0.28;
p.nu3 = 0.18;
p.gamma1 = 0.5;
p.gamma2 = 0.5;
p.ups_f = 1;
p.xi_hh1 = 0.65;
p.xi_hh2 = 0.03;
p.xi_hh3 = 0.02;
p.xi_frm1 = 0.64;
p.xi_frm2 = 0.08;
p.xi_frm3 = 0.1;

% Fiscal, monetary, and macroprudential policy parameters
p.iota_g = 0.89;
p.iota_gfdi = 0.09;
p.iota_gx = 0.22;
p.iota_gcop = 0.26;
p.chi_pi = 1.41;
p.chi_y = 0.14;
p.chi_dexc = 0.56;
p.baromega1 = 0;
p.baromega2 = 0;
p.baromega3 = 0;
p.upsilon1 = 0;
p.upsilon2 = 0;
p.upsilon3 = 0;
p.varepsilon1 = 0.81;
p.varepsilon2 = 0.19;
p.varepsilon3 = 0.5;

% Steady-state ratios and commodity pass-through
p.c_y = 0.3;
p.g_y = 0.12;
p.i_y = 0.25;
p.xptnr_y = 0.275;
p.xptr_y = 0.025;
p.utlz_y = 0.03;
p.m_y = 0.69;
p.fdi_y = 0.2;
p.alpha_r = 0.39;

% Shock persistence parameters
p.rho_uip = 0.85;
p.rho_inv = 0.51;
p.rho_fdi = 0.77;
p.rho_tfp = 0.66;
p.rho_pih = 0.32;
p.rho_pif = 0.3;
p.rho_xptr = 0.76;
p.rho_n = 0.75;
p.rho_piw = 0.55;
p.rho_crhh = 0.88;
p.rho_crfrm = 0.89;
p.rho_rl = 0.57;
p.rho_nplhh = 0.62;
p.rho_nplfrm = 0.64;
p.rho_r = 0.91;
p.rho_ystar = 0.85;
p.rho_pistar = 0.42;
p.rho_rstar = 0.95;
p.rho_pcmmstar = 0.9;

end
