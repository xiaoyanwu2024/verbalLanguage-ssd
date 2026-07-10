% =========================================================
% medianSplitAnalysis.m
%
% Author:  Xiaoyan Wu
% Contact: xiaoyan.psych@gmail.com
% Date:    July 2026
%
% Description:
%   Tests whether cognitive disorganization (CD) selectively
%   modulates the increase in 2D strategy reports from
%   self-reflection to teaching-others.
%
%   Participants are split into Low CD (≤ median) and High CD
%   (> median) groups. Within each learning condition (Image,
%   Language) and CD group, a Fisher's exact test compares
%   the proportion of 2D strategy reports between
%   self-reflection (Q1) and teaching-others (Q2).
%
%   Reported: odds ratio (OR), 95% CI, and p-value.
%   Note: p-values are Bonferroni-corrected threshold α = .0125
%         (4 comparisons: 2 groups × 2 CD levels).
%
% Data:     transcriptions.xlsx (same directory as this script)
%           Must include columns: group, question, strategy, CD
%
% Dependent variable: 2D = 1, non-2D = 0
% =========================================================

clear; clc;

% ---- Load data -------------------------------------------
dataPath = fullfile(fileparts(mfilename('fullpath')), 'dataset.xlsx');
T = readtable(dataPath);

% ---- CD median split -------------------------------------
% Each subject contributes two rows (Q1 and Q2); CD is the same
% for both rows. Split at the median: Low = ≤ median, High = > median.
medCD = median(T.CD);
T.CD2 = repmat({''},height(T),1);
T.CD2(T.CD <= medCD) = {'Low'};
T.CD2(T.CD >  medCD) = {'High'};

% ---- Binary dependent variable ---------------------------
T.twoD = strcmp(T.strategy, '2D');   % 2D = true, others = false

groups   = {'Image', 'Language'};
cdLevels = {'Low', 'High'};

% =========================================================
% Fisher's exact tests: Q1 vs Q2 within each group × CD cell
% =========================================================

fprintf('\n%s\n', repmat('=', 1, 65))
fprintf('CD Median Split (median = %.1f)\n', medCD)
fprintf('Fisher''s exact test: self-reflection vs. teaching-others\n')
fprintf('Bonferroni-corrected significance threshold: alpha = .0125\n')
fprintf('%s\n\n', repmat('=', 1, 65))

for g = 1:numel(groups)
    grp = groups{g};
    fprintf('--- %s condition ---\n', grp)

    for c = 1:numel(cdLevels)
        cd = cdLevels{c};

        % Subset: self-reflection rows for this group × CD cell
        sr = T(strcmp(T.group, grp) & ...
               strcmp(T.question, 'self-reflection') & ...
               strcmp(T.CD2, cd), :);

        % Subset: teaching-others rows for this group × CD cell
        to = T(strcmp(T.group, grp) & ...
               strcmp(T.question, 'teaching-others') & ...
               strcmp(T.CD2, cd), :);

        a    = sum(sr.twoD);   % self-reflection: number of 2D reports
        b    = sum(to.twoD);   % teaching-others: number of 2D reports
        n_sr = height(sr);
        n_to = height(to);

        % 2x2 contingency table:
        %   rows    = question type (TO, SR)
        %   columns = strategy (2D, non-2D)
        % Arranged so OR = (TO_2D odds) / (SR_2D odds);
        % OR > 1 indicates more 2D in teaching-others than self-reflection
        tbl = [b, a; n_to-b, n_sr-a];
        [~, p, stats] = fishertest(tbl);

        fprintf('\n  %s CD  (n_SR = %d, n_TO = %d)\n', cd, n_sr, n_to)
        fprintf('  Self-reflection : %d/%d (%.1f%%)\n', a, n_sr, 100*a/n_sr)
        fprintf('  Teaching-others : %d/%d (%.1f%%)\n', b, n_to, 100*b/n_to)
        fprintf('  OR = %.2f, 95%% CI [%.2f, %.2f], p = %.3f  %s\n', ...
            stats.OddsRatio, stats.ConfidenceInterval(1), ...
            stats.ConfidenceInterval(2), p, getSig(p))
    end
    fprintf('\n')
end

fprintf('%s\n', repmat('=', 1, 65))
fprintf('Significance: *** p<.001  ** p<.01  * p<.05  . p<.10  n.s. p>=.10\n')
fprintf('%s\n\n', repmat('=', 1, 65))

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
