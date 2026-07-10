% =========================================================
% strategy_lmm_analysis.m
%
% Author:  Xiaoyan Wu
% Contact: xiaoyan.psych@gmail.com
% Date:    July 2026
%
% Description:
%   Logistic regression predicting 2D strategy use from group
%   (Image vs. Language) and question type (self-reflection vs.
%   teaching-others), with a group × question interaction term.
%   Run separately for each of three strategy columns:
%     rater1   — human rater 1 classifications
%     rater2   — human rater 2 classifications
%     strategy — final consensus classifications
%
%   Note: A mixed-effects logistic model with a random intercept
%   per subject (fitglme) was initially considered but produced
%   divergent estimates (random intercept variance > 250) because
%   each subject contributed only two binary observations.
%   Plain logistic regression (fitglm) is used instead.
%
% Data:     transcriptions.xlsx (same directory as this script)
% Columns:  subject_id, group, question, rater1, rater2, strategy
%
% Reference level: Language group x self-reflection
% =========================================================

clear; clc;

% ---- Load data -------------------------------------------
dataPath = fullfile(fileparts(mfilename('fullpath')), 'dataset.xlsx');
T = readtable(dataPath);

% ---- Encode predictors -----------------------------------
% group_code:    Image = 1, Language = 0
T.group_code    = double(strcmp(T.group, 'Image'));
% question_code: teaching-others = 1, self-reflection = 0
T.question_code = double(strcmp(T.question, 'teaching-others'));
T.subject_id    = categorical(T.subject_id);

% Inverse-logit helper for converting log-odds to probability
logit2prob = @(x) 1 ./ (1 + exp(-x));

% ---- Strategy columns to analyse -------------------------
raterLabels = {'rater1', 'rater2', 'strategy'};
raterCols   = {'rater1', 'rater2', 'strategy'};

% =========================================================
% Loop over each rater / consensus column
% =========================================================
for r = 1:3
    col = raterCols{r};

    % Binary DV: 2D = 1, all others = 0
    T.y = double(strcmp(T.(col), '2D'));

    % Logistic regression with group × question interaction
    glm = fitglm(T, 'y ~ group_code * question_code', ...
        'Distribution', 'binomial', ...
        'Link',         'logit');

    stats = glm.Coefficients;
    names = stats.Properties.RowNames;

    % ---- Print results -----------------------------------
    disp('=========================================================')
    disp(['RATER: ' raterLabels{r}])
    disp('=========================================================')
    fprintf('%-40s %8s %8s %8s %8s\n', 'Effect', 'Beta(log-odds)', 'SE', 'z', 'p')
    disp(repmat('-', 1, 78))

    for i = 1:height(stats)
        pval = stats.pValue(i);
        if     pval < 0.001, sig = '***';
        elseif pval < 0.01,  sig = '**';
        elseif pval < 0.05,  sig = '*';
        elseif pval < 0.10,  sig = '.';
        else,                sig = 'n.s.';
        end
        fprintf('%-40s %8.4f %8.4f %8.3f %8.4f  %s\n', ...
            names{i}, stats.Estimate(i), stats.SE(i), stats.tStat(i), pval, sig)
    end

    % ---- Predicted probabilities per cell ----------------
    b0    = stats.Estimate(1);   % intercept (Language x SR)
    b_grp = stats.Estimate(2);   % main effect of group
    b_q   = stats.Estimate(3);   % main effect of question
    b_int = stats.Estimate(4);   % group x question interaction

    fprintf('\nPredicted 2D probability by cell:\n')
    fprintf('  Language x self-reflection : %.3f\n', logit2prob(b0))
    fprintf('  Language x teaching-others : %.3f\n', logit2prob(b0 + b_q))
    fprintf('  Image    x self-reflection : %.3f\n', logit2prob(b0 + b_grp))
    fprintf('  Image    x teaching-others : %.3f\n', logit2prob(b0 + b_grp + b_q + b_int))
    fprintf('\n')
end

disp('=========================================================')
disp('Reference level : Language group x self-reflection')
disp('Coefficients    : log-odds scale (logit link)')
disp('Significance    : *** p<.001  ** p<.01  * p<.05  . p<.10  n.s. p>=.10')
disp('=========================================================')
