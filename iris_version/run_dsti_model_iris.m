% RUN_DSTI_MODEL_IRIS
% IRIS Toolbox runner corresponding to the Dynare commands:
%
%   steady;
%   check;
%   shocks;
%       var u_fdi; stderr 0.1;
%   end;
%   stoch_simul(irf=20) y pi d_exc cr rl;
%
%   optim_weights;
%       y 0.5;
%       pi 0.5;
%       d_exc 0.5;
%       cr 0.5;
%       rl 0.5;
%   end;
%   osr_params chi_pi chi_y chi_dexc varepsilon2 varepsilon3;
%   osr(order=1, irf=20);

clear;
close all;

modelFile = 'dsti_model_iris.model';
p = dsti_model_iris_params();

irfHorizon = 20;
irfVariables = {'y', 'pi', 'd_exc', 'cr', 'rl'};
shockName = 'u_fdi';
shockStd = 0.1;

osrParams = {'chi_pi', 'chi_y', 'chi_dexc', 'varepsilon2', 'varepsilon3'};
w_y = 0.5;
w_pi = 0.5;
w_dexc = 0.5;
w_cr = 0.5;
w_rl = 0.5;
osrWeights = [w_y, w_pi, w_dexc, w_cr, w_rl];

%% Load, solve, and check baseline model
m = createModel(modelFile, p);
m = setDynareShockStd(m, shockName, shockStd);
m = solveModel(m);

% IRIS equivalent of steady/check for this linear model. For a linearized
% zero-steady-state model, steady() assigns/checks the steady state.
try
    [m, steadySuccess] = sstate(m);
    if any(~steadySuccess)
        warning("IRIS:steady", "steady() reported at least one unsuccessful parameterization.");
    end
catch exception
    warning("IRIS:steady", "steady() failed or is unavailable in this IRIS version: %s", exception.message);
end

try
    chksstate(m);
catch exception
    try
        checkSteady(m);
    catch
        warning("IRIS:checkSteady", "Steady-state check failed or is unavailable in this IRIS version: %s", exception.message);
    end
end

%% Dynare stoch_simul(irf=20) y pi d_exc cr rl;
[irfDb, irfTable] = runIrisIrf(m, shockName, shockStd, irfHorizon, irfVariables);

disp("IRFs to u_fdi shock, matching stoch_simul(irf=20) y pi d_exc cr rl:");
disp(irfTable);
writetable(irfTable, 'dsti_model_iris_stoch_simul_irf.csv');

%% Dynare-style OSR over chi_pi chi_y chi_dexc varepsilon2 varepsilon3
x0 = getParamVector(p, osrParams);
objective = @(x) osrObjective(x, osrParams, p, modelFile, shockName, shockStd, irfVariables, osrWeights);

options = optimset( ...
    'Display', 'final', ...
    'MaxFunEvals', 350, ...
    'MaxIter', 200, ...
    'TolX', 1e-5, ...
    'TolFun', 1e-6 ...
);

[xOpt, lossValue, exitFlag, optimOutput] = fminsearch(objective, x0, options);

pOpt = assignParamVector(p, osrParams, xOpt);
mOpt = createModel(modelFile, pOpt);
mOpt = setDynareShockStd(mOpt, shockName, shockStd);
mOpt = solveModel(mOpt);

[v, loss_opt] = getDynareStyleLoss(mOpt, irfVariables, osrWeights);
[osrIrfDb, osrIrfTable] = runIrisIrf(mOpt, shockName, shockStd, irfHorizon, irfVariables);

opt_params = struct();
for i = 1:numel(osrParams)
    opt_params.(osrParams{i}) = xOpt(i);
end

disp("OSR optimized parameters:");
disp(struct2table(opt_params));

disp("OSR loss and variance components:");
lossSummary = array2table(loss_opt(:).', "VariableNames", ["loss", "v_y", "v_pi", "v_dexc", "v_cr", "v_rl"]);
disp(lossSummary);
writetable(lossSummary, 'dsti_model_iris_osr_loss.csv');

disp("OSR IRFs to u_fdi shock:");
disp(osrIrfTable);
writetable(struct2table(opt_params), 'dsti_model_iris_osr_params.csv');
writetable(osrIrfTable, 'dsti_model_iris_osr_irf.csv');

results = struct();
results.model = m;
results.model_opt = mOpt;
results.params = p;
results.params_opt = pOpt;
results.irf = irfDb;
results.irf_table = irfTable;
results.osr_irf = osrIrfDb;
results.osr_irf_table = osrIrfTable;
results.opt_params = opt_params;
results.loss_opt = loss_opt;
results.variances = v;
results.exitFlag = exitFlag;
results.optimOutput = optimOutput;

save('dsti_model_iris_results.mat', 'results');

%% Local functions

function m = createModel(modelFile, p)
    try
        m = Model.fromFile(modelFile, Linear=true, Assign=p, Std=0);
    catch
        try
            m = Model.fromFile(modelFile, 'Linear', true, 'Assign', p, 'Std', 0);
        catch
            m = model(modelFile, 'linear', true, 'assign', p, 'std', 0);
        end
    end
end

function m = setDynareShockStd(m, shockName, shockStd)
    stdName = ['std_', char(shockName)];
    try
        m = assign(m, stdName, shockStd);
    catch
        try
            m.(stdName) = shockStd;
        catch exception
            error("Could not assign shock standard deviation %s=%g. Original error: %s", stdName, shockStd, exception.message);
        end
    end
end

function m = solveModel(m)
    try
        m = solve(m);
        if ~all(issolved(m))
            error('SolvedFlag:false', 'Model solution is not available or is not unique/stable.');
        end
    catch exception
        error("IRIS solve() failed: %s", exception.message);
    end
end

function x = getParamVector(p, names)
    x = zeros(1, numel(names));
    for i = 1:numel(names)
        x(i) = p.(names{i});
    end
end

function p = assignParamVector(p, names, x)
    for i = 1:numel(names)
        p.(names{i}) = x(i);
    end
end

function loss = osrObjective(x, names, p, modelFile, shockName, shockStd, variables, weights)
    pTry = assignParamVector(p, names, x);
    try
        mTry = createModel(modelFile, pTry);
        mTry = setDynareShockStd(mTry, shockName, shockStd);
        mTry = solveModel(mTry);
        [~, lossVector] = getDynareStyleLoss(mTry, variables, weights);
        loss = lossVector(1);
        if ~isfinite(loss)
            loss = 1e30;
        end
    catch
        loss = 1e30;
    end
end

function [v, lossVector] = getDynareStyleLoss(m, variables, weights)
    try
        [C, ~, list] = acf(m, Order=0, Select=string(variables), MatrixFormat="plain");
    catch
        [C, ~, list] = acf(m, 'Order=', 0, 'Select=', variables, 'MatrixFormat=', 'plain');
    end

    C0 = C(:, :, 1);
    variableIndex = zeros(1, numel(variables));
    list = string(list);
    for i = 1:numel(variables)
        variableIndex(i) = find(list == string(variables{i}), 1);
    end

    v = diag(C0(variableIndex, variableIndex)).' * 10000;
    weightedLoss = 1e5 * sum(weights .* v);
    lossVector = [weightedLoss, v];
end

function [outDb, irfTable] = runIrisIrf(m, shockName, shockStd, horizon, variables)
    range = 1:horizon;
    extendedRange = 0:horizon;

    inDb = struct();
    modelNames = [get(m, 'XList'), get(m, 'EList')];
    for iName = 1:numel(modelNames)
        inDb.(modelNames{iName}) = tseries(extendedRange, zeros(numel(extendedRange), 1));
    end
    isDeviation = true;

    % Shock size is 0.1, matching Dynare's "stderr 0.1" for u_fdi.
    if ~isfield(inDb, shockName) || isempty(inDb.(shockName))
        inDb.(shockName) = tseries(extendedRange, zeros(numel(extendedRange), 1));
    end
    inDb.(shockName)(1) = shockStd;

    try
        outDb = simulate(m, inDb, range, Method="firstOrder");
    catch
        outDb = simulate(m, inDb, range, 'Deviation=', isDeviation, 'Method=', 'FirstOrder');
    end

    irfArray = nan(horizon, numel(variables));
    for i = 1:numel(variables)
        irfArray(:, i) = getSeriesData(outDb.(variables{i}), range);
    end

    irfTable = array2table(irfArray, 'VariableNames', variables);
    irfTable.Period = (1:horizon).';
    irfTable = movevars(irfTable, 'Period', 'Before', 1);
end

function data = getSeriesData(series, range)
    try
        data = getData(series, range);
    catch
        data = double(series(range));
    end
    data = data(:);
end
