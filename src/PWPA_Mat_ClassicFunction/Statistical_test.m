%% 📊 STATISTICAL TESTS FOR OPTIMIZATION ALGORITHMS
% Wilcoxon Signed-Rank (Pairwise) | Friedman (Global) | Nemenyi & Holm (Post-hoc)
% Designed for academic publication — clean, well-documented, reproducible.

%% ───────────────────────────────────────────────────────────────
%% 1. LOAD DATA & CONFIG
%% ───────────────────────────────────────────────────────────────

load('results_full.mat');  % Assumes structure: allResults.FunctionName.Algorithm.curves

funcs = fieldnames(allResults);
algos = {'GA','PSO','GWO','COA','HHO','PWPA'};  % PWPA as control/reference
nAlgos = length(algos);
nFuncs = length(funcs);

alpha = 0.05;
fprintf('📊 STATISTICAL TESTS (α = %.2f)\n', alpha);
fprintf('Wilcoxon Rank-Sum | Friedman | Nemenyi | Holm-Bonferroni\n');
fprintf('==================================================\n');

% Initialize storage
wilcoxonResults = struct();
rankMatrix = zeros(nFuncs, nAlgos);
bestValues = zeros(nFuncs, nAlgos);

% Prepare figure for boxplots
figure('Position', [100, 100, 1400, 900]);
cols = min(3, nFuncs);
rows = ceil(nFuncs / cols);

%% ───────────────────────────────────────────────────────────────
%% 2. WILCOXON PAIRWISE COMPARISONS (PWPA vs Others)
%% ───────────────────────────────────────────────────────────────

for f = 1:nFuncs
    fname = funcs{f};
    
    % Extract best fitness per run for each algorithm
    GA_vals   = min(allResults.(fname).GA.curves,[],2);
    PSO_vals  = min(allResults.(fname).PSO.curves,[],2);
    GWO_vals  = min(allResults.(fname).GWO.curves,[],2);
    COA_vals  = min(allResults.(fname).COA.curves,[],2);
    HHO_vals  = min(allResults.(fname).HHO.curves,[],2);
    PWPA_vals = min(allResults.(fname).PWPA.curves,[],2);
    
    % Compute medians
    median_GA   = median(GA_vals);
    median_PSO  = median(PSO_vals);
    median_GWO  = median(GWO_vals);
    median_COA  = median(COA_vals);
    median_HHO  = median(HHO_vals);
    median_PWPA = median(PWPA_vals);
    
    medians = [median_GA, median_PSO, median_GWO, median_COA, median_HHO, median_PWPA];
    bestValues(f, :) = medians;
    
    % Assign ranks (lower fitness = better rank)
    [~, sortedIdx] = sort(medians);
    ranks = zeros(1, nAlgos);
    ranks(sortedIdx) = 1:nAlgos;
    rankMatrix(f, :) = ranks;
    
    % Wilcoxon tests: PWPA vs each algorithm
    [p1, ~, stats1] = ranksum(PWPA_vals, GA_vals, 'method', 'approximate');
    [p2, ~, stats2] = ranksum(PWPA_vals, PSO_vals, 'method', 'approximate');
    [p3, ~, stats3] = ranksum(PWPA_vals, GWO_vals, 'method', 'approximate');
    [p4, ~, stats4] = ranksum(PWPA_vals, COA_vals, 'method', 'approximate');
    [p5, ~, stats5] = ranksum(PWPA_vals, HHO_vals, 'method', 'approximate');
    
    % Effect sizes (r = |Z|/sqrt(N))
    r1 = abs(stats1.zval) / sqrt(length(PWPA_vals) + length(GA_vals));
    r2 = abs(stats2.zval) / sqrt(length(PWPA_vals) + length(PSO_vals));
    r3 = abs(stats3.zval) / sqrt(length(PWPA_vals) + length(GWO_vals));
    r4 = abs(stats4.zval) / sqrt(length(PWPA_vals) + length(COA_vals));
    r5 = abs(stats5.zval) / sqrt(length(PWPA_vals) + length(HHO_vals));
    
    % Store results
    wilcoxonResults.(fname).PWPA_vs_GA   = p1;
    wilcoxonResults.(fname).PWPA_vs_PSO  = p2;
    wilcoxonResults.(fname).PWPA_vs_GWO  = p3;
    wilcoxonResults.(fname).PWPA_vs_COA  = p4;
    wilcoxonResults.(fname).PWPA_vs_HHO  = p5;
    wilcoxonResults.(fname).Median_GA    = median_GA;
    wilcoxonResults.(fname).Median_PSO   = median_PSO;
    wilcoxonResults.(fname).Median_GWO   = median_GWO;
    wilcoxonResults.(fname).Median_COA   = median_COA;
    wilcoxonResults.(fname).Median_HHO   = median_HHO;
    wilcoxonResults.(fname).Median_PWPA  = median_PWPA;
    wilcoxonResults.(fname).EffectSize_PWPA_vs_GA   = r1;
    wilcoxonResults.(fname).EffectSize_PWPA_vs_PSO  = r2;
    wilcoxonResults.(fname).EffectSize_PWPA_vs_GWO  = r3;
    wilcoxonResults.(fname).EffectSize_PWPA_vs_COA  = r4;
    wilcoxonResults.(fname).EffectSize_PWPA_vs_HHO  = r5;
    
    % Print results
    fprintf('%s:\n', fname);
    fprintf('   Medians → GA: %.6f, PSO: %.6f, GWO: %.6f, COA: %.6f, HHO: %.6f, PWPA: %.6f\n', ...
            median_GA, median_PSO, median_GWO, median_COA, median_HHO, median_PWPA);
    fprintf('   PWPA vs GA   → p = %.4f %s | r = %.3f (%s)\n', p1, getSigText(p1,alpha), r1, interpretEffectSize(r1));
    fprintf('   PWPA vs PSO  → p = %.4f %s | r = %.3f (%s)\n', p2, getSigText(p2,alpha), r2, interpretEffectSize(r2));
    fprintf('   PWPA vs GWO  → p = %.4f %s | r = %.3f (%s)\n', p3, getSigText(p3,alpha), r3, interpretEffectSize(r3));
    fprintf('   PWPA vs COA  → p = %.4f %s | r = %.3f (%s)\n', p4, getSigText(p4,alpha), r4, interpretEffectSize(r4));
    fprintf('   PWPA vs HHO  → p = %.4f %s | r = %.3f (%s)\n', p5, getSigText(p5,alpha), r5, interpretEffectSize(r5));
    fprintf('\n');
    
    % Plot boxplot
    subplot(rows, cols, f);
    data = [GA_vals, PSO_vals, GWO_vals, COA_vals, HHO_vals, PWPA_vals];
    labels = {'GA', 'PSO', 'GWO', 'COA', 'HHO', 'PWPA'};
    boxplot(data, 'Labels', labels, 'Notch', 'on', 'OutlierSize', 4);
    title(sprintf('%s\n(p_GA=%.3f, p_PSO=%.3f, p_GWO=%.3f, p_COA=%.3f, p_HHO=%.3f)', ...
                  fname, p1, p2, p3, p4, p5), 'FontSize', 9);
    ylabel('Best Fitness Value');
    grid on;
    ylim auto;
    xtickangle(45);
end

%% ───────────────────────────────────────────────────────────────
%% 3. FRIEDMAN TEST + NEMENYI POST-HOC
%% ───────────────────────────────────────────────────────────────

fprintf('\n\n=============================================\n');
fprintf('📈 FRIEDMAN TEST + POST-HOC ANALYSIS\n');
fprintf('=============================================\n');

% Friedman test
[p_friedman, ~, ~] = friedman(bestValues, 1);
fprintf('Friedman Test p-value: %.6f\n', p_friedman);
if p_friedman < alpha
    fprintf('✅ Significant differences exist among algorithms (p < %.2f)\n', alpha);
else
    fprintf('❌ No significant differences detected.\n');
end

% Average ranks
avgRanks = mean(rankMatrix, 1);
[~, sortIdx] = sort(avgRanks);

fprintf('\nAverage Ranks (lower is better):\n');
for i = 1:nAlgos
    fprintf('   %s: %.3f\n', algos{i}, avgRanks(i));
end

% Nemenyi Critical Difference
criticalDiff = nemenyiCriticalDifference(nAlgos, nFuncs, alpha);
fprintf('\nNemenyi Critical Difference (CD): %.4f\n', criticalDiff);

% Find significant pairs
fprintf('\nSignificant pairs (|rank_i - rank_j| > CD):\n');
signifPairs = {};
pairCount = 0;
for i = 1:nAlgos
    for j = i+1:nAlgos
        diff = abs(avgRanks(i) - avgRanks(j));
        if diff > criticalDiff
            pairCount = pairCount + 1;
            signifPairs{pairCount} = sprintf('%s vs %s (|%.3f - %.3f| = %.3f > %.3f)', ...
                algos{i}, algos{j}, avgRanks(i), avgRanks(j), diff, criticalDiff);
        end
    end
end

if isempty(signifPairs)
    fprintf('   None.\n');
else
    for i = 1:length(signifPairs)
        fprintf('   ✅ %s\n', signifPairs{i});
    end
end

%% ───────────────────────────────────────────────────────────────
%% 4. HOLM-BONFERRONI CORRECTION (NEWLY ADDED)
%% ───────────────────────────────────────────────────────────────

fprintf('\n\n🔧 HOLM-BONFERRONI CORRECTION FOR MULTIPLE COMPARISONS\n');
fprintf('==================================================\n');

% Collect all p-values from Wilcoxon tests (across all functions)
allPValues = [];
algoPairs = {};

for f = 1:nFuncs
    fname = funcs{f};
    p_GA  = wilcoxonResults.(fname).PWPA_vs_GA;
    p_PSO = wilcoxonResults.(fname).PWPA_vs_PSO;
    p_GWO = wilcoxonResults.(fname).PWPA_vs_GWO;
    p_COA = wilcoxonResults.(fname).PWPA_vs_COA;
    p_HHO = wilcoxonResults.(fname).PWPA_vs_HHO;
    
    % Store p-values and labels
    pVec = [p_GA, p_PSO, p_GWO, p_COA, p_HHO];
    pairLabels = {['PWPA vs GA (' fname ')'], ...
                  ['PWPA vs PSO (' fname ')'], ...
                  ['PWPA vs GWO (' fname ')'], ...
                  ['PWPA vs COA (' fname ')'], ...
                  ['PWPA vs HHO (' fname ')']};
    
    allPValues = [allPValues, pVec];
    algoPairs = [algoPairs, pairLabels];
end

% Holm-Bonferroni procedure
[sortedP, sortIdx] = sort(allPValues);
m = length(sortedP);  % number of hypotheses
holmReject = false(1, m);
holmPAdjusted = zeros(1, m);

for i = 1:m
    adjustedAlpha = alpha / (m - i + 1);
    holmPAdjusted(i) = min(sortedP(i) * (m - i + 1), 1.0);  % cap at 1.0
    if sortedP(i) < adjustedAlpha
        holmReject(i) = true;
    else
        break;  % Holm is step-down — stop at first non-significant
    end
end

% Map back to original order
holmRejectOriginal = false(1, m);
holmPAdjustedOriginal = zeros(1, m);
holmRejectOriginal(sortIdx) = holmReject;
holmPAdjustedOriginal(sortIdx) = holmPAdjusted;

% Display Holm results
fprintf('Total pairwise comparisons: %d\n', m);
fprintf('Significant after Holm correction (α = %.2f):\n', alpha);
anySignificant = false;
for i = 1:m
    if holmRejectOriginal(i)
        anySignificant = true;
        fprintf('   ✅ %s → p = %.4f, adjusted p = %.4f\n', algoPairs{i}, allPValues(i), holmPAdjustedOriginal(i));
    end
end
if ~anySignificant
    fprintf('   ❌ None significant after Holm correction.\n');
end

%% ───────────────────────────────────────────────────────────────
%% 5. VISUALIZATION & OUTPUT
%% ───────────────────────────────────────────────────────────────

% Plot average ranks
figure('Position', [100, 100, 800, 500]);
bar(avgRanks, 'FaceColor', [0.2 0.6 0.8]);
title('Average Friedman Ranks (Lower is Better)', 'FontSize', 14);
ylabel('Average Rank');
set(gca, 'XTick', 1:nAlgos, 'XTickLabel', algos);
grid on;
ylim([1 nAlgos]);
for i = 1:nAlgos
    text(i, avgRanks(i) + 0.05, sprintf('%.2f', avgRanks(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
end

%% ───────────────────────────────────────────────────────────────
%% 6. RANKING PLOT (CD DIAGRAM) — NEWLY ADDED
%% ───────────────────────────────────────────────────────────────

% Sort algorithms by average rank
[sortedAvgRanks, sortIdx] = sort(avgRanks);
sortedAlgos = algos(sortIdx);

% Create CD diagram
figure('Position', [100, 100, 900, 400]);
hold on;

% Plot points for each algorithm
plot(1:nAlgos, sortedAvgRanks, 'o', 'MarkerSize', 12, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);

% Add algorithm names below points
for i = 1:nAlgos
    text(i, sortedAvgRanks(i) - 0.15, sortedAlgos{i}, ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
         'FontSize', 11, 'FontWeight', 'bold', 'Rotation', 45);
end

% Draw CD line (horizontal reference line)
yCD = min(sortedAvgRanks);  % Start from best rank
lineX = 1:nAlgos;
lineY = yCD * ones(1, nAlgos);
plot(lineX, lineY, '--', 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5);

% Draw CD bars between algorithms that are NOT significantly different
for i = 1:nAlgos
    for j = i+1:nAlgos
        if abs(sortedAvgRanks(i) - sortedAvgRanks(j)) <= criticalDiff
            % Connect with horizontal line if not significantly different
            yLine = yCD - 0.3 - 0.1*(j-i);  % Offset lines vertically to avoid overlap
            plot([i, j], [yLine, yLine], 'Color', 'r', 'LineWidth', 2);
        end
    end
end

% Finalize plot
xlim([0.5, nAlgos + 0.5]);
ylim([min(sortedAvgRanks) - 0.8, max(sortedAvgRanks) + 0.3]);
title('Critical Difference (CD) Diagram — Nemenyi Test', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Algorithms (Sorted by Average Rank)', 'FontSize', 12);
ylabel('Average Rank (Lower is Better)', 'FontSize', 12);
grid on;
box on;
set(gca, 'XTick', [], 'YTick', 1:nAlgos);
hold off;

% Optional: Save figure
print('ranking_cd_diagram.png', '-dpng', '-r300');

disp('📊 CD Ranking Plot displayed and saved as "ranking_cd_diagram.png".');

%% ───────────────────────────────────────────────────────────────
%% 7. HELPER FUNCTIONS
%% ───────────────────────────────────────────────────────────────

function effect = interpretEffectSize(r)
    if r < 0.1
        effect = 'negligible';
    elseif r < 0.3
        effect = 'small';
    elseif r < 0.5
        effect = 'medium';
    else
        effect = 'large';
    end
end

function s = getSigText(p, alpha)
    if p < alpha
        s = '(significant)';
    else
        s = '';
    end
end

function CD = nemenyiCriticalDifference(k, N, alpha)
    switch alpha
        case 0.01
            q_alpha = 3.633;
        case 0.05
            q_alpha = 2.728;
        case 0.10
            q_alpha = 2.394;
        otherwise
            error('Unsupported alpha. Use 0.01, 0.05, or 0.10.');
    end
    CD = q_alpha * sqrt(k * (k + 1) / (6 * N));
end