% =========================================================
% olife_2D_logistic.m
%
% Author:  Xiaoyan Wu
% Contact: xiaoyan.psych@gmail.com
% Date:    July 2026
%
% Description:
%   Logistic regression models predicting the probability of
%   reporting a 2D spatial strategy, with O-LIFE schizotypy
%   subscales as predictors.
%
%   Models:
%     Model 1 — Base:      twoD ~ group + question
%     Model 2 — Each O-LIFE subscale added separately (4 models)
%     Model 3 — All O-LIFE subscales together
%     Model 4 — Full model: all subscales + age + gender
%
%   O-LIFE subscales (Mason et al., 1995):
%     UE — Unusual Experiences
%     CD — Cognitive Disorganization
%     IA — Introvertive Anhedonia
%     IN — Impulsive Nonconformity
%
%   All continuous predictors are z-scored.
%
% Data:     transcriptions.xlsx (same directory as this script)
%           Must include columns: group, question, strategy,
%           UE, CD, IA, IN, ALL, age, gender
%
% Dependent variable: 2D = 1, non-2D = 0
% Reference levels:   Language group, self-reflection, Female
% =========================================================

clear; clc;

% ---- Load data -------------------------------------------
dataPath = fullfile(fileparts(mfilename('fullpath')), 'dataset.xlsx');
T = readtable(dataPath);

% ---- Encode categorical variables ------------------------
T.group    = categorical(T.group);
T.question = categorical(T.question);
T.gender   = removecats(categorical(T.gender));
T.strategy = categorical(T.strategy);

% ---- Binary dependent variable ---------------------------
% 2D strategy = 1, all others (1D, none) = 0
T.twoD = double(T.strategy == '2D');

% ---- Z-score continuous predictors -----------------------
vars = {'UE', 'CD', 'IA', 'IN', 'age'};
for i = 1:numel(vars)
    v = vars{i};
    T.([v '_z']) = zscore(T.(v));
end

% =========================================================
% Model 1: Base model
%   Establishes the effect of group and question type
% =========================================================
mdl1 = fitglm(T, 'twoD ~ group + question', 'Distribution', 'binomial');
print_model(mdl1, 'MODEL 1: BASE');

% =========================================================
% Model 2: Each O-LIFE subscale added separately
%   Tests the unique contribution of each schizotypy dimension
% =========================================================
traits = {'UE_z', 'CD_z', 'IA_z', 'IN_z'};
for i = 1:numel(traits)
    tr  = traits{i};
    mdl = fitglm(T, sprintf('twoD ~ group + question + %s', tr), ...
        'Distribution', 'binomial');
    print_model(mdl, ['MODEL 2: ' tr]);
end

% =========================================================
% Model 3: All four O-LIFE subscales together
%   Tests whether subscale effects survive mutual adjustment
% =========================================================
mdl3 = fitglm(T, ...
    'twoD ~ group + question + UE_z + CD_z + IA_z + IN_z', ...
    'Distribution', 'binomial');
print_model(mdl3, 'MODEL 3: ALL O-LIFE SUBSCALES');

% =========================================================
% Model 4: Full model — O-LIFE subscales + age + gender
%   Primary reported model; controls for demographic covariates
% =========================================================
mdl4 = fitglm(T, ...
    'twoD ~ group + question + UE_z + CD_z + IA_z + IN_z + age_z + gender', ...
    'Distribution', 'binomial');
print_model(mdl4, 'MODEL 4: FULL (+ age + gender)');

% =========================================================
% Helper function: print GLM coefficient table
% =========================================================
function print_model(mdl, titleText)
    fprintf('\n%s\n', repmat('=', 1, 60))
    disp(titleText)
    fprintf('%s\n', repmat('=', 1, 60))
    coef = mdl.Coefficients;
    for i = 1:height(coef)
        name = coef.Properties.RowNames{i};
        beta = coef.Estimate(i);
        se   = coef.SE(i);
        p    = coef.pValue(i);
        OR   = exp(beta);
        if     p < 0.001, sig = '***';
        elseif p < 0.01,  sig = '**';
        elseif p < 0.05,  sig = '*';
        elseif p < 0.10,  sig = '.';
        else,             sig = 'n.s.';
        end
        fprintf('%-35s beta=%7.3f  OR=%7.3f  SE=%6.3f  p=%7.4f  %s\n', ...
            name, beta, OR, se, p, sig)
    end
end
