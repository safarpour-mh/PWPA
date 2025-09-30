load('PWPA_Final_Results.mat');

figure('Position', [100, 100, 600, 400]);
boxplot(all_best_fitness, 'Labels', {'PWPA'}, 'Notch', 'on');
hold on;
yline(loss_baseline, '--r', 'Baseline SVM', 'LineWidth', 2);
title('Comparison of CV Loss: PWPA vs Baseline SVM', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Cross-Validation Loss', 'FontSize', 11);
legend('PWPA (10 Runs)', 'Baseline SVM', 'Location', 'best');
grid on; box on;
set(gca, 'FontSize', 10);

% ذخیره با کیفیت بالا برای مقاله
print('PWPA_Results_Boxplot.png', '-dpng', '-r300');