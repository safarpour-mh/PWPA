%% Plot_Real_Convergence.m — Professional Convergence Plot for Q1 Paper (Real Data)

%% 1. Load All Run Files
nRuns = 10; % باید با تنظیمات Run_Comparison.m یکی باشه
nIter = 50; % باید با تنظیمات PWPA یکی باشه

all_histories = zeros(nIter, nRuns); % ذخیره تاریخچه همه Runها

for run = 1:nRuns
    filename = sprintf('PWPA_Run_%d.mat', run);
    if exist(filename, 'file')
        data = load(filename);
        if isfield(data, 'convergence_history') && length(data.convergence_history) >= nIter
            all_histories(:, run) = data.convergence_history(1:nIter);
        else
            error('❌ Run %d: convergence_history not found or incomplete.', run);
        end
    else
        error('❌ Run %d result file not found.', run);
    end
end

%% 2. Compute Mean and Std
mean_history = mean(all_histories, 2);
std_history = std(all_histories, 0, 2);

%% 3. Plot Professional Convergence Curve
figure('Position', [150, 150, 800, 500], 'Color', 'w');

% Plot mean with shaded std area
fill([1:nIter, nIter:-1:1], ...
     [mean_history + std_history; flipud(mean_history - std_history)], ...
     [0.85 0.92 1], 'EdgeColor', 'none', 'FaceAlpha', 0.6);

hold on;
plot(1:nIter, mean_history, 'b-', 'LineWidth', 2.5, 'Marker', 'o', 'MarkerFaceColor', 'b', 'MarkerSize', 4);

% Customize
title('PWPA Convergence Curve (Mean ± Std over 10 Runs)', 'FontSize', 15, 'FontWeight', 'bold');
xlabel('Iteration', 'FontSize', 13);
ylabel('Best Cross-Validation Loss', 'FontSize', 13);
grid on; box off;
set(gca, 'FontSize', 12, 'GridLineStyle', '--', 'GridColor', [0.7 0.7 0.7]);

% Legend and annotations
legend('Mean ± Std', 'Mean Trend', 'Location', 'northeast', 'FontSize', 12, 'Box', 'off');

% Add final value annotation
text(nIter, mean_history(end), sprintf(' %.4f', mean_history(end)), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', ...
    'FontSize', 11, 'FontWeight', 'bold', 'Color', 'b');

%% 4. Save High-Quality Figures
print('PWPA_Convergence_Real.png', '-dpng', '-r600');
print('PWPA_Convergence_Real.eps', '-depsc2', '-r600');

fprintf('✅ Real Convergence Plot saved (PNG + EPS) for Q1 submission.\n');

%% 5. Optional: Save data for LaTeX or Excel
save('Convergence_Data.mat', 'mean_history', 'std_history', 'all_histories');
writematrix([mean_history, std_history], 'Convergence_Mean_Std.csv');
fprintf('✅ Convergence data exported to CSV for external use.\n');