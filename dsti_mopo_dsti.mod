// DSTI-modified DSGE model
//
// Structural changes relative to the baseline:
// 1. Household credit enters the consumption equation directly.
// 2. Household credit responds to the DSTI variable.
// 3. A DSTI policy rule is added.

close all;

//==========================================================================
// Endogenous variables
//==========================================================================

// Household block
var c r rl pi n;                 // consumption, policy rate, lending rate, inflation, labor

// External and exchange-rate block
var r_star d_exc asst;           // foreign rate, nominal depreciation, net foreign assets
var pi_star d_q;                 // foreign inflation, real exchange-rate change
var q psi_f s;                   // real exchange rate, law-of-one-price gap, terms of trade
var exc p_star p_f;              // nominal exchange rate, foreign price, import price

// Capital, investment, and production
var k_s k utlz;                  // capital services, capital stock, utilization
var inv;                         // investment
var fdi cr_frm;                  // foreign direct investment, firm credit
var r_k;                         // capital rental rate
var y;                           // output
var w;                           // real wage
var mc;                          // real marginal cost

// Prices and demand components
var pi_h;                        // domestic inflation
var pi_f;                        // import inflation
var c_h;                         // domestic consumption input
var c_f;                         // imported consumption input
var ds;                          // change in terms of trade
var i_h;                         // investment input
var xpt_nr y_star;               // non-resource exports, foreign output
var xpt_r;                       // resource exports

// Labor market
var mu_w z;                      // wage markup, reference shifter
var un;                          // unemployment
var pi_w mu_w_n;                 // wage inflation, wage-markup shock term
var l;                           // labor force

// Credit and DSTI
var cr cr_hh dsti;               // aggregate credit, household credit, DSTI variable

// Banking and macroprudential variables
var c_rtio rr;                   // capital requirement, reserve requirement
var cst_fnd;                     // funding cost
var npl;                         // aggregate nonperforming loans
var npl_hh npl_frm;              // household and firm nonperforming loans

// Fiscal and commodity variables
var g prc_cmm;                   // government spending, domestic commodity price
var prc_cmm_star;                // foreign commodity price

// Shock process variables
var eps_c eps_uip eps_inv eps_tfp eps_pih eps_pif eps_n eps_xptr eps_piw eps_crhh eps_crfrm eps_rl eps_nplhh eps_nplfrm; // 14 variables

// Exogenous shocks
varexo u_c u_uip u_inv u_fdi u_tfp u_pih u_pif u_xptr u_n u_piw u_crhh u_crfrm u_rl 
       u_nplhh u_nplfrm u_g u_r u_crtio u_rr u_ystar u_pistar u_rstar u_pcmmstar u_dsti;   //24 variables

//==========================================================================
// Parameters
//==========================================================================

parameters h, sigma, alpha_p, bar_wlc, prm_crhh,
           phi_ex, phi_asst, rho_uip,
           alpha_fc,
           delta,
           alpha_fdi, rho_inv,
           rho_fdi,
           alpha_utlz,
           alpha_ks, rho_tfp,
           ups_n, ups_k, 
           gamma_h, beta, kappa_h, rho_pih, 
           gamma_f, kappa_f, ups_f, rho_pif,
           eta,
           rho_xptr,
           rho_n,
           varphi,
           vartheta_z,
           gamma_w, kappa_w, rho_piw,
           zeta,
           lambda1_hh, lambda2_hh, lambda3_hh, lambda4_hh, lambda5_hh, rho_crhh,
           lambda1_frm, lambda2_frm, lambda3_frm, lambda4_frm, rho_crfrm,
           kappa_rl, rho_rl,
           nu1, nu2, nu3,
           gamma1, gamma2,
           xi_hh1, xi_hh2, xi_hh3, rho_nplhh,
           xi_frm1, xi_frm2, xi_frm3, rho_nplfrm,
           iota_g, iota_gfdi, iota_gx, iota_gcop,
           rho_r, chi_pi, chi_y, chi_dexc,
           baromega1, baromega2, baromega3,
           upsilon1, upsilon2, upsilon3, 
           varepsilon1, varepsilon2, varepsilon3,
           rho_ystar,
           rho_pistar,
           rho_rstar,
           rho_pcmmstar,
           c_y, g_y, i_y, xptnr_y, xptr_y, utlz_y,
           m_y, fdi_y,
           alpha_r;

// Deep parameters
parameters theta_h, theta_f, theta_w, kappa;

theta_h = 0.71;
theta_f = 0.83;
theta_w = 0.03;
kappa = 0.21;
theta_rl = 0.7;

//==========================================================================
// Calibration
//==========================================================================

// Household preferences and consumption-credit channel
h = 0.48; // habit formation
sigma = 1.19;  // CRRA coefficient
alpha_p = 0.48;    // patient household share
bar_wlc = 0.42;     // steady-state labor income to household consumption ratio
prm_crhh = 0.1;     // household-credit effect on consumption

// Open-economy and capital parameters
phi_ex = 0.46;   // UIP exchange-rate coefficient
phi_asst = 0.004;    // net foreign asset coefficient
alpha_fc = 0.36;      // foreign consumption share
delta = 0.04;        // quarterly capital depreciation
alpha_fdi = 0.4;    // FDI share in investment
alpha_utlz = (1 - kappa)/kappa;     // capital-utilization response
alpha_ks = 0.51;       // capital share in production
ups_n = 1;        // wage-cost financing coefficient
ups_k = 1;        // capital-cost financing coefficient

// Price and wage Phillips curve parameters
gamma_h = 0.39;      // domestic inflation indexation
beta = 0.9925;         // discount factor
kappa_h = ((1-theta_h)*(1-theta_h*beta))/theta_h;       // domestic NKPC slope
gamma_f = 0.39;           // foreign/import inflation indexation
kappa_f = ((1-theta_f)*(1-theta_f*beta))/theta_f;      // import NKPC slope
eta = 1.53;           // substitution elasticity between domestic and foreign goods
varphi = 2.62;         // labor-supply elasticity parameter
vartheta_z = 0.06;     // reference-shifter persistence parameter
gamma_w = 0.45;       // wage indexation
kappa_w = ((1-theta_w)*(1-theta_w*beta))/theta_w;        // wage NKPC slope

// Credit and banking parameters
zeta = 0.39;           // household-credit share
lambda1_hh = 0.57;     // household-credit response to output
lambda2_hh = 0.52;     // household-credit response to lending rate
lambda3_hh = 0.45;     // household-credit response to capital requirement
lambda4_hh = 0.37;     // household-credit response to reserve requirement
lambda5_hh = 0.37;     // household-credit response to DSTI
lambda1_frm = 0.15;    // firm-credit response to output
lambda2_frm = 0.54;    // firm-credit response to lending rate
lambda3_frm = 0.57;    // firm-credit response to capital requirement
lambda4_frm = 0.38;    // firm-credit response to reserve requirement
kappa_rl = ((1-theta_rl)*(1-theta_rl*beta))/theta_rl;       // lending-rate adjustment slope
nu1 = 0.38;            // funding-cost response to nonperforming loans
nu2 = 0.28;            // funding-cost response to capital requirement
nu3 = 0.18;            // funding-cost response to reserve requirement
gamma1 = 0.5;         // household NPL weight
gamma2 = 0.5;         // firm NPL weight
ups_f = 1;         // import-price financing coefficient
xi_hh1 = 0.65;         // household NPL persistence
xi_hh2 = 0.03;         // household NPL response to output
xi_hh3 = 0.02;          // household NPL response to nominal depreciation
xi_frm1 = 0.64;         // firm NPL persistence
xi_frm2 = 0.08;         // firm NPL response to output
xi_frm3 = 0.1;         // firm NPL response to nominal depreciation

// Fiscal and monetary policy parameters
iota_g = 0.89;           // government-spending persistence
iota_gfdi = 0.09;        // government-spending response to FDI
iota_gx = 0.22;          // government-spending response to resource exports
iota_gcop = 0.26;        // government-spending response to commodity price
chi_pi = 1.41;           // Taylor-rule response to inflation
chi_y = 0.14;            // Taylor-rule response to output
chi_dexc = 0.56;         // Taylor-rule response to nominal depreciation

// Macroprudential policy parameters
//baromega1 = 0.85;        // capital-requirement persistence
//baromega2 = 0.33;        // capital-requirement response to output
//baromega3 = 0.16;        // capital-requirement response to credit
//upsilon1 = 0.81;         // reserve-requirement persistence
//upsilon2 = 0.19;         // reserve-requirement response to output
//upsilon3 = 0.17;         // reserve-requirement response to credit
baromega1 = 0;        // capital-requirement persistence
baromega2 = 0;        // capital-requirement response to output
baromega3 = 0;        // capital-requirement response to credit
upsilon1 = 0;         // reserve-requirement persistence
upsilon2 = 0;         // reserve-requirement response to output
upsilon3 = 0;         // reserve-requirement response to credit

// DSTI policy parameters
varepsilon1 = 0.81;         // DSTI persistence
varepsilon2 = 0.19;         // DSTI response to wage inflation
varepsilon3 = 0.5;         // DSTI response to household credit
//varepsilon1 = 0;         // DSTI persistence
//varepsilon2 = 0;         // DSTI response to wage inflation
//varepsilon3 = 0;         // DSTI response to household credit

// Steady-state ratios and commodity pass-through
c_y = 0.3;       // consumption-output ratio
g_y = 0.12;       // government spending-output ratio
i_y = 0.25;       // investment-output ratio
xptnr_y = 0.275;    // non-resource export-output ratio
xptr_y = 0.025;     // resource export-output ratio
utlz_y = 0.03;     // utilization-output ratio
m_y = 0.69;        // import consumption-output ratio
fdi_y = 0.2;      // FDI-output ratio
alpha_r = 0.39;    // foreign commodity-price pass-through weight

// Shock persistence parameters
rho_uip = 0.85;     // UIP shock persistence
rho_inv = 0.51;       // investment shock persistence
rho_fdi = 0.77;       // FDI shock persistence
rho_tfp = 0.66;       // productivity shock persistence
rho_pih = 0.32;       // domestic inflation shock persistence
rho_pif = 0.3;        // import inflation shock persistence
rho_xptr = 0.76;        // resource export shock persistence
rho_n = 0.75;        // labor-supply shock persistence
rho_piw = 0.55;        // wage inflation shock persistence
rho_crhh = 0.88;       // household credit shock persistence
rho_crfrm = 0.89;      // firm credit shock persistence
rho_rl = 0.57;         // lending-rate shock persistence
rho_nplhh = 0.62;       // household NPL shock persistence
rho_nplfrm = 0.64;       // firm NPL shock persistence
rho_r = 0.91;            // central-bank policy-rate persistence
rho_ystar = 0.85;         // foreign output persistence
rho_pistar = 0.42;        // foreign inflation persistence
rho_rstar = 0.95;         // foreign interest-rate persistence
rho_pcmmstar = 0.9;      // foreign commodity-price persistence

//==========================================================================
// Linearized model
//==========================================================================

model(linear);

//--------------------------------------------------------------------------
// Households
//--------------------------------------------------------------------------

// (1) Forward-looking consumption IS equation
c - h*c(-1) = (c(+1) - h*c) - (sigma^-1)*(1-h)*((alpha_p)*(r - pi(+1)) + (1-alpha_p)*(rl - pi(+1))) + (sigma^-1)*(sigma-1)*(bar_wlc)*(n - n(+1)) + prm_crhh*cr_hh + eps_c;
eps_c = u_g + u_c;

// (2) UIP condition
r - r_star = (1 - phi_ex)*d_exc(+1) - phi_ex*d_exc - phi_asst*asst + eps_uip;
//r - r_star = (1 - phi_ex)*d_exc - phi_asst*asst + eps_uip;
eps_uip = rho_uip*eps_uip(-1) + u_uip;

// (3) Nominal depreciation identity
d_exc = pi - pi_star + d_q;

// (4) Real exchange rate
q = psi_f + (1 - alpha_fc)*s;  

// (5) Law-of-one-price gap
psi_f = exc + p_star + p_f;

// (6) Effective capital supply
k_s = k(-1) + utlz;

// (7) Capital accumulation
k = (1 - delta)*k(-1) + delta*inv;

// (8) Investment
inv = alpha_fdi*(fdi + q) + (1-alpha_fdi)*cr_frm +eps_inv;
eps_inv = rho_inv*eps_inv(-1) + u_inv;

// (9) Foreign direct investment
fdi = rho_fdi*fdi(-1) + u_fdi;

// (10) Capital utilization
utlz = alpha_utlz*r_k;

//--------------------------------------------------------------------------
// Firms and prices
//--------------------------------------------------------------------------

// (11) Domestic production
y = alpha_ks*k_s + (1-alpha_ks)*n + eps_tfp;
eps_tfp = rho_tfp*eps_tfp(-1) + u_tfp;

// (12) Capital rental rate
r_k = -(k_s - n) + w;

// (13) Real marginal cost
mc = (1-alpha_ks)*w + alpha_ks*r_k + ((1-alpha_ks)*ups_n + alpha_ks*ups_k)*r + alpha_fc*s - eps_tfp;

// (14) Domestic inflation Phillips curve
pi_h - gamma_h*pi_h(-1) = beta*(pi_h(+1) - gamma_h*pi_h) + kappa_h*mc + eps_pih;
eps_pih = rho_pih*eps_pih(-1) + u_pih;

// (15) Import inflation Phillips curve
pi_f - gamma_f*pi_f(-1) = beta*(pi_f(+1) - gamma_f*pi_f) + kappa_f*(psi_f + ups_f*r) + eps_pif;
eps_pif = rho_pif*eps_pif(-1) + u_pif;

// (16) Domestic consumption input
c_h = c + eta*alpha_fc*s;

// (17) Imported consumption input
c_f = c + eta*(1-alpha_fc)*s;

// (18) CPI inflation
pi = pi_h + alpha_fc*ds;

// (19) Change in terms of trade from inflation gap
ds = pi_f - pi_h;

// (20) Investment input
i_h = inv;

// (21) Non-resource exports
xpt_nr = eta*(s + psi_f) + y_star;

// (22) Resource exports
xpt_r = y_star + eps_xptr;
eps_xptr = rho_xptr*eps_xptr(-1) + u_xptr;

//--------------------------------------------------------------------------
// Labor market
//--------------------------------------------------------------------------

// (23) Wage markup
mu_w = w -(z + varphi*n + eps_n);
eps_n = rho_n*eps_n(-1) + u_n;

// (24) Unemployment relation
mu_w = varphi*un;

// (25) Endogenous reference shifter
z = (1-vartheta_z)*z(-1) + vartheta_z*(-eps_c + (sigma/(1 - h ))*(c - h*c(-1)));

// (26) Real wage process
w = w(-1) + pi_w -pi;

// (27) Wage Phillips curve
pi_w - gamma_w*pi_w(-1) = beta*(pi_w(+1) - gamma_w*pi_w) + kappa_w*(mu_w - mu_w_n);
eps_piw = rho_piw*eps_piw(-1) + u_piw;

// (28) Labor force identity
l = n + un;

//--------------------------------------------------------------------------
// Financial market
//--------------------------------------------------------------------------

// (29) Aggregate credit
cr = zeta*cr_hh + (1-zeta)*cr_frm;

// (30) Household credit
cr_hh = lambda1_hh*y - lambda2_hh*rl -lambda3_hh*c_rtio - lambda4_hh*rr + lambda5_hh*dsti + eps_crhh;
eps_crhh = rho_crhh*eps_crhh(-1) + u_crhh;

// (31) Firm credit
cr_frm = lambda1_frm*y - lambda2_frm*rl -lambda3_frm*c_rtio - lambda4_frm*rr +eps_crfrm;
eps_crfrm = rho_crfrm*eps_crfrm(-1) + u_crfrm;

// (32) Lending-rate adjustment
rl - rl(-1) = beta*(rl(+1) - rl) - kappa_rl*(rl - cst_fnd) + eps_rl;
eps_rl = rho_rl*eps_rl(-1) + u_rl;

// (33) Funding cost
cst_fnd = r + nu1*npl + nu2*c_rtio + nu3*rr;

// (34) Aggregate nonperforming loans
npl = gamma1*npl_hh + gamma2*npl_frm;

// (35) Household nonperforming loans
npl_hh = xi_hh1*npl_hh(-1) - xi_hh2*y + xi_hh3*d_exc +eps_nplhh;
eps_nplhh = rho_nplhh*eps_nplhh(-1) + u_nplhh;

// (36) Firm nonperforming loans
npl_frm = xi_frm1*npl_frm(-1) - xi_frm2*y + xi_frm3*d_exc +eps_nplfrm;
eps_nplfrm = rho_nplfrm*eps_nplfrm(-1) + u_nplfrm;

//--------------------------------------------------------------------------
// Fiscal, monetary, and macroprudential policy
//--------------------------------------------------------------------------

// (37) Government spending
g = iota_g*g(-1) + iota_gfdi*fdi + iota_gx*xpt_r + iota_gcop*prc_cmm + u_g;

// (38) Monetary policy
r = rho_r*r(-1) + (1 - rho_r)*(chi_pi*pi + chi_y*y +chi_dexc*d_exc) + u_r;

// (39) Capital requirement
c_rtio = baromega1*c_rtio(-1) + (1-baromega1)*(baromega2*y + baromega3*cr) + u_crtio;

// (40) Reserve requirement
rr = upsilon1*rr(-1) + (1-upsilon1)*(upsilon2*y + upsilon3*cr) + u_rr;

// (40-1) DSTI rule
dsti = varepsilon1*dsti(-1) + (1-varepsilon1)*(varepsilon2*pi_w - varepsilon3*cr_hh) + u_dsti;

//--------------------------------------------------------------------------
// Foreign variables
//--------------------------------------------------------------------------

// (41) Foreign output
y_star = rho_ystar*y_star(-1) + u_ystar;

// (42) Foreign inflation
pi_star = rho_pistar*pi_star(-1) + u_pistar;

// (43) Foreign interest rate
r_star = rho_rstar*r_star(-1) + u_rstar;

// (44) Foreign commodity price
prc_cmm_star = rho_pcmmstar*prc_cmm_star(-1) + u_pcmmstar;

//--------------------------------------------------------------------------
// Resource constraint and external accounts
//--------------------------------------------------------------------------

// (45) Goods-market equilibrium
y = c_y*c + g_y*g + i_y*i_h + xptnr_y*xpt_nr + xptr_y*xpt_r + utlz_y*utlz;

// (46) Net foreign assets
asst = (1/beta)*asst(-1) + xptnr_y*(xpt_nr - alpha_fc*s) + xptr_y*(q + prc_cmm +xpt_r) - m_y*(q + c_f) +fdi_y*(q + fdi);

// (47) Domestic commodity price
prc_cmm = alpha_r*prc_cmm_star + (1 - alpha_r)*prc_cmm(-1);

//--------------------------------------------------------------------------
// Linking equations
//--------------------------------------------------------------------------

// (48) Change in terms of trade
ds = s - s(-1);

// (49) Wage-markup shock term
mu_w_n = 100*eps_piw;

// (50) Foreign price-level inflation
pi_star = p_star - p_star(-1);

// (51) Import price-level inflation
pi_f = p_f - p_f(-1);

// (52) Real exchange-rate change
d_q = q - q(-1);

end;

//==========================================================================
// Steady state and model diagnostics
//==========================================================================

steady;

check;

//==========================================================================
// Shock configuration
//==========================================================================

shocks;
//var u_r; stderr 0.1;
//var u_rr; stderr 0.1;
//var u_crtio; stderr 0.1;

//var u_c; stderr 0.1;
//var u_pih; stderr 0.1;
//var u_crhh; stderr 0.1;
var u_fdi; stderr 0.1;
//var u_pcmmstar; stderr 0.1;
//var u_xptr; stderr 0.1;
//var u_g; stderr 0.1;

end;

//==========================================================================
// Baseline stochastic simulation
//==========================================================================

stoch_simul(irf=20) y pi d_exc cr rl;

//==========================================================================
// Optimal simple rule
//==========================================================================

w_y=0.5; w_pi=0.5; w_dexc=0.5; w_cr=0.5; w_rl=0.5;

optim_weights;
y w_y;
pi w_pi;
d_exc w_dexc;
cr w_cr;
rl w_rl;

end;

osr_params chi_pi chi_y chi_dexc varepsilon2 varepsilon3;

% osr(irf=20) y pi d_exc cr rl;
osr(order=1, irf=20);

v_y = oo_.var(1,1)*10000;
v_pi = oo_.var(2,2)*10000;
v_dexc = oo_.var(3,3)*10000;
v_cr = oo_.var(4,4)*10000;
v_rl = oo_.var(5,5)*10000;

loss_opt = 10^5*[w_y*v_y + w_pi*v_pi + w_dexc*v_dexc + w_cr*v_cr + w_rl*v_rl,v_y,v_pi,v_dexc,v_cr,v_rl]';

opt_params=struct2array(oo_.osr.optim_params);
