% =========================================================
% strategy_main_analysis.m
%
% Author:  Xiaoyan Wu
% Contact: xiaoyan.psych@gmail.com
% Date:    July 2026
%
% Description:
%   Tests whether teaching others promotes 2D spatial strategy
%   reports compared to self-reflection, and whether this effect
%   depends on learning modality (Image vs. Language group).
%
% Analyses:
%   Part 1 — Overall logistic regression: P(2D) ~ question
%   Part 2 — Fisher's exact test within each group (Image, Language):
%             2D vs. non-2D proportion, self-reflection vs. teaching-others
%
% Data:     transcriptions.xlsx (same directory as this script)
% Columns:  group    — 'Image' | 'Language'
%           question — 'self-reflection' | 'teaching-others'
%           strategy — '2D' | '1D' | 'none'
%
% Dependent variable: 2D = 1, non-2D = 0
% Reference level:    self-reflection condition
% =========================================================

clear; clc;

% ---- Load data -------------------------------------------
dataPath = fullfile(fileparts(mfilename('fullpath')), 'dataset.xlsx');
T = readtable(dataPath);

% ---- Encode predictors -----------------------------------
% question_code: teaching-others = 1, self-reflection = 0
T.question_code = double(strcmp(T.question, 'teaching-others'));
% group_code: Image = 1, Language = 0
T.group_code    = double(strcmp(T.group, 'Image'));
% Binary DV: 2D strategy = 1, all others = 0
T.y             = double(strcmp(T.strategy, '2D'));

% Inverse-logit helper
logit2prob = @(x) 1 ./ (1 + exp(-x));

% =========================================================
% PART 1: Overall logistic regression
%   Model: P(2D) ~ question_code
%   Tests the overall effect of question type on 2D strategy use
% =========================================================

fprintf('\n%s\n', repmat('=', 1, 60))
fprintf('PART 1: Overall logistic regression\n')
fprintf('  P(2D) ~ question  [teaching-others vs. self-reflection]\n')
fprintf('%s\n', repmat('=', 1, 60))

glm = fitglm(T, 'y ~ question_code', ...
    'Distribution', 'binomial', ...
    'Link',         'logit');

coef = glm.Coefficients;

fprintf('\n%-30s %8s %8s %8s %8s   %s\n', ...
    'Effect', 'beta', 'SE', 'z', 'p', '95% CI')
fprintf('%s\n', repmat('-', 1, 72))

for i = 1:height(coef)
    p_val = coef.pValue(i);
    ci_lo = coef.Estimate(i) - 1.96 * coef.SE(i);
    ci_hi = coef.Estimate(i) + 1.96 * coef.SE(i);
    fprintf('%-30s %8.3f %8.3f %8.3f %8.3f   [%5.2f, %5.2f]  %s\n', ...
        coef.Properties.RowNames{i}, ...
        coef.Estimate(i), coef.SE(i), coef.tStat(i), p_val, ...
        ci_lo, ci_hi, getSig(p_val))
end

% Predicted probabilities at reference (self-reflection) and teaching-others
b0 = coef.Estimate(1);
b1 = coef.Estimate(2);
fprintf('\nPredicted P(2D):\n')
fprintf('  Self-reflection : %.3f\n', logit2prob(b0))
fprintf('  Teaching-others : %.3f\n', logit2prob(b0 + b1))

% =========================================================
% PART 2: Fisher's exact test within each group
%   2 x 2 table: question (SR vs. TO) x strategy (2D vs. non-2D)
%   Fisher's exact is preferred when expected cell counts < 5
% =========================================================

fprintf('\n%s\n', repmat('=', 1, 60))
fprintf('PART 2: Fisher''s exact tests within each group\n')
fprintf('  2D vs. non-2D, self-reflection vs. teaching-others\n')
fprintf('%s\n', repmat('=', 1, 60))

groups = {'Image', 'Language'};

for g = 1:numel(groups)
    grp = groups{g};
    sr  = T(strcmp(T.group, grp) & strcmp(T.question, 'self-reflection'), :);
    to  = T(strcmp(T.group, grp) & strcmp(T.question, 'teaching-others'),  :);

    n_sr = height(sr);
    n_to = height(to);

    a = sum(sr.y);   % SR,  2D
    b = sum(to.y);   % TO,  2D

    % 2x2 contingency table: rows = question (TO, SR), cols = outcome (2D, non-2D)
    % Arranged so OR = (TO_2D / TO_non2D) / (SR_2D / SR_non2D) > 1 when TO > SR
    tbl = [b, a; n_to-b, n_sr-a];
    [~, p_fisher, stats_f] = fishertest(tbl);

    fprintf('\nGroup: %s  (n = %d per question)\n', grp, n_sr)
    fprintf('  Self-reflection : 2D = %d/%d (%.1f%%)\n', a, n_sr, 100*a/n_sr)
    fprintf('  Teaching-others : 2D = %d/%d (%.1f%%)\n', b, n_to, 100*b/n_to)
    fprintf('  OR = %.2f, 95%% CI [%.2f, %.2f]\n', ...
        stats_f.OddsRatio, stats_f.ConfidenceInterval(1), stats_f.ConfidenceInterval(2))
    fprintf('  Fisher''s exact p = %.4f  %s\n', p_fisher, getSig(p_fisher))
end

fprintf('\n%s\n', repmat('=', 1, 60))
fprintf('Significance: *** p<.001  ** p<.01  * p<.05  . p<.10  n.s. p>=.10\n')
fprintf('%s\n\n', repmat('=', 1, 60))

% =========================================================
% Helper function: return significance stars
% =========================================================
function sig = getSig(p)
    if     p < 0.001, sig = '***';
    elseif p < 0.01,  sig = '**';
    elseif p < 0.05,  sig = '*';
    elseif p < 0.10,  sig = '.';
    else,             sig = 'n.s.';
    end
end
