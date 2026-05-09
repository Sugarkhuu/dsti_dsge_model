// make hh credit respond to the wage(or wage inflation?): eq 30 is modified
//
// set dsti policy respons fn eq 40-1 is introduced
//
// does hh consumption respond to hh credit?? eps_crhh was one of the shocks that affect consumption. modify this so that hh credit affect consumption
// so prm_crhh parameter is introduced and eq 1s are modified

close all;

var c r rl pi n;  // eq 1, consumption, interest rate, loan interest rate, inflation, labor supply
var r_star d_exc asst;   //  eq2, foreign interest rate, change of exchange rate, net foreign asset
var pi_star d_q;   // eq3, foreign inflation, change of real exchage rate
var q psi_f s;   // eq4, real exchange rate, price gap between dom and foreign, terms of trade
var exc p_star p_f;     // eq5, nominal exchange rate, foreign price, imported price
var k_s k utlz;    // eq6, capital supply, capital stock, capital utilization
var inv;       // eq7, investment
var fdi cr_frm; // eq8 foreign direct investment, firm credit
var r_k;    //  eq10, capital rental rate
var y; // eq11, productivity shock
var w;   // eq12 real wage
var mc;   // eq13 marginal cost
var pi_h;   //eq14 domestic inflation
var pi_f;   //eq15 import inflation
var c_h;          // eq16 intermediate domestic input
var c_f;          // eq17 intermediate imported foreign input
var ds;           // eq18 change of tot
var i_h;           // eq20 domestic intermediate input for investment
var xpt_nr y_star;        // eq21 non resource commodity export, foreign income
var xpt_r;               // eq22 resource commodity export
var mu_w z;         // eq23 wage mark up,... with endogenous reference shifter?
var un;            // eq24 unemployment
var pi_w mu_w_n;    //eq 27 wage phillips curve, wage shock?? 
var l;             // eq 28 labor force... check the nececity

// modified for dsti
var cr cr_hh dsti;    // eq 29 credit, household credit, dsti
// end of modification

var c_rtio rr;    //eq 30 capital ratio, reserve requirment
var cst_fnd;  // eq 32 cost of funding
var npl;   // eq 33 non performing loan
var npl_hh npl_frm;    // eq 34 non performing loan of HH, non performing loan of firm
var g prc_cmm;         // eq 37 gov spending, price of commodity
var prc_cmm_star;     // eq 44 foreign price of commodity

// shock process variables
var eps_c eps_uip eps_inv eps_tfp eps_pih eps_pif eps_n eps_xptr eps_piw eps_crhh eps_crfrm eps_rl eps_nplhh eps_nplfrm; // 14 variables

varexo u_c u_uip u_inv u_fdi u_tfp u_pih u_pif u_xptr u_n u_piw u_crhh u_crfrm u_rl 
       u_nplhh u_nplfrm u_g u_r u_crtio u_rr u_ystar u_pistar u_rstar u_pcmmstar u_dsti;   //24 variables

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
           // modified for dsti
           varepsilon1, varepsilon2, varepsilon3,
           // end of modification
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

//-------------------------
h = 0.48; // habit formation
sigma = 1.19;  // CRRA coefficient
alpha_p = 0.48;    // patienct HH ratio
bar_wlc = 0.42;     // SS of the labor income to HH consumption

//modified for dsti
prm_crhh = 0.1;
//end of modification

phi_ex = 0.46;   // UIP exchange rate coef, UIP modification
phi_asst = 0.004;    // UIP net foreign asset coeff, interest debt elasticity
alpha_fc = 0.36;      // share of foreign consumption
delta = 0.04;        // captial depreciation, quarterly basis
alpha_fdi = 0.4;    // fdi share among investment
alpha_utlz = (1 - kappa)/kappa;     // coeff of capital utilization to the rent
alpha_ks = 0.51;       // captial share in production function
ups_n = 1;        // percent of wage cost
ups_k = 1;        // percent of rential cost
gamma_h = 0.39;      // domestic inflation indexation parameter
beta = 0.9925;         // discount rate
kappa_h = ((1-theta_h)*(1-theta_h*beta))/theta_h;       // domestic NKPC slope
gamma_f = 0.39;           // foreign inflation indexation parameter
kappa_f = ((1-theta_f)*(1-theta_f*beta))/theta_f;      //foreign NKPC slope
eta = 1.53;           // elasticity of substitution between domestic and foreign good?
varphi = 2.62;         // elasticity of labor supply wrt real wage
vartheta_z = 0.06;     // endo reference shifter parameter??
gamma_w = 0.45;       //wage indexation parameter
kappa_w = ((1-theta_w)*(1-theta_w*beta))/theta_w;        // wage NKPC slope, somewhat different from original
zeta = 0.39;           // HH credit share, not firm credit
lambda1_hh = 0.57;     // HH credit determinent coeff for y
lambda2_hh = 0.52;     // HH credit determinent coeff for lending rate 
lambda3_hh = 0.45;     // HH credit determinent coeff for captial ratio 
lambda4_hh = 0.37;     // HH credit determinent coeff for reserve ratio 

// modified for dsti
lambda5_hh = 0.37;     // HH credit determinent coeff for dsti
// end of modification

lambda1_frm = 0.15;    // firm credit determinent coeff for y 
lambda2_frm = 0.54;    // firm credit determinent coeff for lending rate
lambda3_frm = 0.57;    // firm credit determinent coeff for capital ratio
lambda4_frm = 0.38;    // firm credit determinent coeff for reserve ratio
kappa_rl = ((1-theta_rl)*(1-theta_rl*beta))/theta_rl;       // bank lending rate response to net lending profit? 
nu1 = 0.38;            //funding cost coeff of non performing loan
nu2 = 0.28;            //funding cost coeff of capital ratio 
nu3 = 0.18;            //funding cost coeff of reserve ratio
gamma1 = 0.5;         // share of HH non performing loan, could not find. so arbitrary
gamma2 = 0.5;         // share of fir non performing loan, could not find. so arbitrary
ups_f = 1;         // govern the strength of mopo?
xi_hh1 = 0.65;         // HH npl determinent coeff of past itself
xi_hh2 = 0.03;         // HH npl determinent coeff of y 
xi_hh3 = 0.02;          // HH npl determinent coeff of change of foreign exchange rate
xi_frm1 = 0.64;         // firm npl determinent coeff of past itself
xi_frm2 = 0.08;         // firm npl determinent coeff of y
xi_frm3 = 0.1;         // firm npl determinent coeff of hange of foreign exchange rate
iota_g = 0.89;           // gov spending coeff of past itself
iota_gfdi = 0.09;        // gov spending coeff of fdi
iota_gx = 0.22;          // gov spending coeff of resource export
iota_gcop = 0.26;        // gov spending coeff of commodity price
chi_pi = 1.41;           // Taylor rule coeff of inflation
chi_y = 0.14;            // Taylor rule coeff of output
chi_dexc = 0.56;         // Taylor rule coeff of foreign exchange rateeps_c
//baromega1 = 0.85;        // MAPU capital ratio coeff of persistence
//baromega2 = 0.33;        // MAPU capital ratio coeff of y 
//baromega3 = 0.16;        // MAPU capital ratio coeff of credit
//upsilon1 = 0.81;         // MAPU reserve ratio coeff of persistence
//upsilon2 = 0.19;         // MAPU reserve ratio coeff of y
//upsilon3 = 0.17;         // MAPU reserve ratio coeff of credit
baromega1 = 0;        // MAPU capital ratio coeff of persistence
baromega2 = 0;        // MAPU capital ratio coeff of y 
baromega3 = 0;        // MAPU capital ratio coeff of credit
upsilon1 = 0;         // MAPU reserve ratio coeff of persistence
upsilon2 = 0;         // MAPU reserve ratio coeff of y
upsilon3 = 0;         // MAPU reserve ratio coeff of credit

//modified for dsti
varepsilon1 = 0.81;         // MAPU dsti coeff of persistence
varepsilon2 = 0.19;         // MAPU dsti coeff of wage
varepsilon3 = 0.5;         // MAPU dsti coeff of household credit
//varepsilon1 = 0;         // MAPU dsti coeff of persistence
//varepsilon2 = 0;         // MAPU dsti coeff of wage
//varepsilon3 = 0;         // MAPU dsti coeff of household credit



// end of modification
c_y = 0.3;       // cosumption output ratio
g_y = 0.12;       // gov spending output ratio
i_y = 0.25;       // investment output ratio
xptnr_y = 0.275;    // non resource export - output ratio
xptr_y = 0.025;     // resource export - output ratio
utlz_y = 0.03;     // capital utilization(?) output ratio, capital cost output ratio
m_y = 0.69;        // import consumtion output ratio
fdi_y = 0.2;      // fdi output ratio
alpha_r = 0.39;    // weight of foreign commodity price

rho_uip = 0.85;     // UIP shock persistence, risk premium
rho_inv = 0.51;       //investment shock persistence
rho_fdi = 0.77;       //fdi shock persistence
rho_tfp = 0.66;       // productivity shock
rho_pih = 0.32;       // domestic inflation shock persistence, cost push
rho_pif = 0.3;        // domestic inflation shock persistence, cost push
rho_xptr = 0.76;        // export shock persistence
rho_n = 0.75;        // labor supply shock persistence
rho_piw = 0.55;        //wage inflation persistence
rho_crhh = 0.88;       // HH credit shock persistence
rho_crfrm = 0.89;      // firm credit shock persistence
rho_rl = 0.57;         // lending rate shock persistence
rho_nplhh = 0.62;       // HH npl shock persistence
rho_nplfrm = 0.64;       // HH npl shock persistence
rho_r = 0.91;            // CB policy rate persistence
rho_ystar = 0.85;         // AR(1) foreign output persistence
rho_pistar = 0.42;        // AR(1) foreign inflation persistence
rho_rstar = 0.95;         // AR(1) foreign policy interest rate persistence
rho_pcmmstar = 0.9;      // AR(1) foreign price of commodity persistence


//=========================================================================================
model(linear);

// ------------------------------------------------------------------------HH
// (1) forward looking IS
// original
// c - h*c(-1) = (c(+1) - h*c) - (sigma^-1)*(1-h)*((alpha_p)*(r - pi(+1)) + (1-alpha_p)*(rl - pi(+1))) + (sigma^-1)*(sigma-1)*(bar_wlc)*(n - n(+1)) + eps_c;
// eps_c = eps_crhh + u_g + u_c;

// modified for dsti
c - h*c(-1) = (c(+1) - h*c) - (sigma^-1)*(1-h)*((alpha_p)*(r - pi(+1)) + (1-alpha_p)*(rl - pi(+1))) + (sigma^-1)*(sigma-1)*(bar_wlc)*(n - n(+1)) + prm_crhh*cr_hh + eps_c;
eps_c = u_g + u_c;

// (2) UIP
r - r_star = (1 - phi_ex)*d_exc(+1) - phi_ex*d_exc - phi_asst*asst + eps_uip;
//r - r_star = (1 - phi_ex)*d_exc - phi_asst*asst + eps_uip;
eps_uip = rho_uip*eps_uip(-1) + u_uip;

// (3) definition of the chagne of nominal exchange rate
d_exc = pi - pi_star + d_q;

// (4) real exchange rate
q = psi_f + (1 - alpha_fc)*s;  

// (5) law of one price gap, ?? exchange level? price levels?? How introduce
// leves???
psi_f = exc + p_star + p_f;

// (6) capital supply, the addtion of capital stock and capital utilization
k_s = k(-1) + utlz;

// (7) capital stock law of motion
k = (1 - delta)*k(-1) + delta*inv;

// (8) investment as an addition of fdi and firm credit
inv = alpha_fdi*(fdi + q) + (1-alpha_fdi)*cr_frm +eps_inv;
eps_inv = rho_inv*eps_inv(-1) + u_inv;

// (9) foreign investment modeled as AR(1)
fdi = rho_fdi*fdi(-1) + u_fdi;

// (10) capital utilization as a functionof capital rental rate
utlz = alpha_utlz*r_k;

// ---------------------------------------------------------------- Firm
// (11) domestic good production
y = alpha_ks*k_s + (1-alpha_ks)*n + eps_tfp;
eps_tfp = rho_tfp*eps_tfp(-1) + u_tfp;

// (12) capital rental rate
r_k = -(k_s - n) + w;

// (13) real marginal cost
mc = (1-alpha_ks)*w + alpha_ks*r_k + ((1-alpha_ks)*ups_n + alpha_ks*ups_k)*r + alpha_fc*s - eps_tfp;

// (14) domestic inflation phillips curve
pi_h - gamma_h*pi_h(-1) = beta*(pi_h(+1) - gamma_h*pi_h) + kappa_h*mc + eps_pih;
eps_pih = rho_pih*eps_pih(-1) + u_pih;

// (15) import inflation phillips curve
pi_f - gamma_f*pi_f(-1) = beta*(pi_f(+1) - gamma_f*pi_f) + kappa_f*(psi_f + ups_f*r) + eps_pif;
eps_pif = rho_pif*eps_pif(-1) + u_pif;

// (16) intermediate domestic input?
c_h = c + eta*alpha_fc*s;

// (17) intermediate imported foreign input?
c_f = c + eta*(1-alpha_fc)*s;

// (18) consumer good inflation
pi = pi_h + alpha_fc*ds;

// (19) change of terms of trade
ds = pi_f - pi_h;

// (20) domestic intermediate input for investment
i_h = inv;

// (21) non resource commodity export
xpt_nr = eta*(s + psi_f) + y_star;

// (22) resource commodity export
xpt_r = y_star + eps_xptr;
eps_xptr = rho_xptr*eps_xptr(-1) + u_xptr;

// ---------------------------------------------------------------- labor marketcr 
// (23) wage mark up with endogenous reference shifter??
mu_w = w -(z + varphi*n + eps_n);
eps_n = rho_n*eps_n(-1) + u_n;

// (24) unemployment
mu_w = varphi*un;

// (25) endogenous reference shifter
z = (1-vartheta_z)*z(-1) + vartheta_z*(-eps_c + (sigma/(1 - h ))*(c - h*c(-1)));

// (26) real wage process (How about eq 12?)
w = w(-1) + pi_w -pi;

// (27) wage phillips curve, mu_w_n = 100* eps_w ???
pi_w - gamma_w*pi_w(-1) = beta*(pi_w(+1) - gamma_w*pi_w) + kappa_w*(mu_w - mu_w_n);
eps_piw = rho_piw*eps_piw(-1) + u_piw;

// (28) labor force... Do we need this? and... is this log linearized?
l = n + un;

// ---------------------------------------------------------------- financial market
// (29) credit aggregation
cr = zeta*cr_hh + (1-zeta)*cr_frm;

// (30) HH credit determination
// cr_hh = lambda1_hh*y - lambda2_hh*rl -lambda3_hh*c_rtio - lambda4_hh*rr + eps_crhh;
// modified for dsti
cr_hh = lambda1_hh*y - lambda2_hh*rl -lambda3_hh*c_rtio - lambda4_hh*rr + lambda5_hh*dsti + eps_crhh;

eps_crhh = rho_crhh*eps_crhh(-1) + u_crhh;

// (31) firm credit determination
cr_frm = lambda1_frm*y - lambda2_frm*rl -lambda3_frm*c_rtio - lambda4_frm*rr +eps_crfrm;
eps_crfrm = rho_crfrm*eps_crfrm(-1) + u_crfrm;

// (32) bank lending rate IS curve??
rl - rl(-1) = beta*(rl(+1) - rl) - kappa_rl*(rl - cst_fnd) + eps_rl;
eps_rl = rho_rl*eps_rl(-1) + u_rl;

// (33) cost of funding
cst_fnd = r + nu1*npl + nu2*c_rtio + nu3*rr;

// (34) non performing loan, gamma2=1-gamma1?
npl = gamma1*npl_hh + gamma2*npl_frm;

// (35) HH non performing loan
npl_hh = xi_hh1*npl_hh(-1) - xi_hh2*y + xi_hh3*d_exc +eps_nplhh;
eps_nplhh = rho_nplhh*eps_nplhh(-1) + u_nplhh;

// (36) firm non performing loan
npl_frm = xi_frm1*npl_frm(-1) - xi_frm2*y + xi_frm3*d_exc +eps_nplfrm;
eps_nplfrm = rho_nplfrm*eps_nplfrm(-1) + u_nplfrm;

// ---------------------------------------------------------------- fiscal, monetary and macroprudential policy
// (37) gov spending process, price of commodity is a level?
g = iota_g*g(-1) + iota_gfdi*fdi + iota_gx*xpt_r + iota_gcop*prc_cmm + u_g;

// (38) monetary policy
r = rho_r*r(-1) + (1 - rho_r)*(chi_pi*pi + chi_y*y +chi_dexc*d_exc) + u_r;

// (39) capital requirement
c_rtio = baromega1*c_rtio(-1) + (1-baromega1)*(baromega2*y + baromega3*cr) + u_crtio;

// (40) reserve ratio
rr = upsilon1*rr(-1) + (1-upsilon1)*(upsilon2*y + upsilon3*cr) + u_rr;

// (40-1) dsti
// modified for dsti
dsti = varepsilon1*dsti(-1) + (1-varepsilon1)*(varepsilon2*pi_w - varepsilon3*cr_hh) + u_dsti;

// ---------------------------------------------------------------- foreign variables
// (41) foreign output
y_star = rho_ystar*y_star(-1) + u_ystar;

// (42) foreign inflation
pi_star = rho_pistar*pi_star(-1) + u_pistar;

// (43) foreign interest rate
r_star = rho_rstar*r_star(-1) + u_rstar;

// (44) foreign commodity price
prc_cmm_star = rho_pcmmstar*prc_cmm_star(-1) + u_pcmmstar;

// ---------------------------------------------------------------- resource constraint
// (45) goods market equilibrium, delete i_h by using inv and deleting // 20??
y = c_y*c + g_y*g + i_y*i_h + xptnr_y*xpt_nr + xptr_y*xpt_r + utlz_y*utlz;

// (46) foreign asset
asst = (1/beta)*asst(-1) + xptnr_y*(xpt_nr - alpha_fc*s) + xptr_y*(q + prc_cmm +xpt_r) - m_y*(q + c_f) +fdi_y*(q + fdi);

// (47) domestic commodity price
prc_cmm = alpha_r*prc_cmm_star + (1 - alpha_r)*prc_cmm(-1);

// ---------------------------------------------------------------- extra equations
// (48 - extra1 in eq 18) change of ToT
ds = s - s(-1);

// (49 - extra2 in eq 27) just wage shock?
mu_w_n = 100*eps_piw;

// (50 - extra3 in eq 5) 
pi_star = p_star - p_star(-1);

// (51 - extra4 in eq 5)
pi_f = p_f - p_f(-1);

// (52 extra4 in eq 2)
//d_exc = exc - exc(-1);
d_q = q - q(-1);

end;

//=================================================================================
steady;

check;

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

stoch_simul(irf=20) y pi d_exc cr rl;

//==============================================optimal policy
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

