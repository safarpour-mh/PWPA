%% Run_Comparison.m — Optimized for Q1 Journal Publication (MATLAB Version Compatible)
clear; clc; close all;

%% 1. Load MNIST Data
fprintf('🔄 Loading MNIST dataset...\n');
run('Load_MNIST_Demo.m');

% Ensure data is in correct format
if ~exist('XTrain', 'var') || ~exist('YTrain', 'var')
    error('❌ XTrain or YTrain not found. Check Load_MNIST_Demo.m');
end

%% 2. Apply PCA (95% variance retained) — Compatible with All MATLAB Versions
fprintf('📊 Applying PCA to reduce dimensionality (95%% variance)...\n');

[coeff, score, ~, ~, explained] = pca(XTrain);
cumulative_variance = cumsum(explained);
numComponents = find(cumulative_variance >= 95, 1, 'first');

if isempty(numComponents)
    numComponents = length(explained); % fallback: use all components
end

% Create PCA model structure
pcaModel = struct();
pcaModel.Coefficient = coeff(:, 1:numComponents);
pcaModel.NumComponents = numComponents;

% Transform data
XTrain_pca = XTrain * pcaModel.Coefficient;
XTest_pca = XTest * pcaModel.Coefficient;

fprintf('✅ Dimensionality reduced from %d to %d features (95%% variance preserved).\n', ...
    size(XTrain,2), size(XTrain_pca,2));

%% 3. Algorithm Settings (Optimized for Q1)
nPop = 15;           % Population size
nIter = 50;          % Number of iterations
nRuns = 10;          % Number of independent runs (for statistical reporting)
dim = 2;             % Assuming optimizing 2 hyperparameters: [C, gamma]
lb = [0.1, 0.001];   % Lower bounds for [C, gamma]
ub = [100, 10];      % Upper bounds for [C, gamma]

%% 4. Baseline: Default SVM (for comparison in paper)
fprintf('\n🧪 Training Baseline SVM (Default Parameters)...\n');
template_baseline = templateSVM('Standardize', true);
ecoc_baseline = fitcecoc(XTrain_pca, YTrain, 'Learners', template_baseline);
cv_baseline = crossval(ecoc_baseline, 'KFold', 5);
loss_baseline = kfoldLoss(cv_baseline);
fprintf('✅ Baseline SVM 5-Fold CV Loss: %.4f\n\n', loss_baseline);

%% 5. Run PWPA Optimization
fprintf('🚀 Starting PWPA Optimization (%d runs)...\n', nRuns);

all_best_fitness = zeros(nRuns, 1);
all_best_hyperparams = zeros(nRuns, dim);

for run = 1:nRuns
    fprintf('\n========================================\n');
    fprintf('▶️  RUN %d / %d\n', run, nRuns);
    fprintf('========================================\n');
    
    saveFileName = sprintf('PWPA_Run_%d.mat', run);
    
    % Skip if already completed
    if exist(saveFileName, 'file')
        fprintf('✅ Run %d already completed. Loading results...\n', run);
        load(saveFileName);
        all_best_fitness(run) = best_fitness;
        all_best_hyperparams(run, :) = best_hyperparams;
        continue;
    end
    
    % Run PWPA
    tic;
    [best_hyperparams, best_fitness, ~] = PWPA(@SVM_Fitness_Function, dim, nPop, nIter, lb, ub, XTrain_pca, YTrain);
    time_taken = toc;
    
    % Save results
    all_best_fitness(run) = best_fitness;
    all_best_hyperparams(run, :) = best_hyperparams;
    save(saveFileName, 'best_hyperparams', 'best_fitness', 'time_taken', 'run');
    
    fprintf('✅ Run %d completed in %.2f seconds. Best Fitness: %.4f\n', run, time_taken, best_fitness);
end

%% 6. Final Results Summary
fprintf('\n\n========================================\n');
fprintf('📊 FINAL RESULTS SUMMARY\n');
fprintf('========================================\n');
fprintf('Baseline SVM Loss: %.4f\n', loss_baseline);
fprintf('PWPA Mean CV Loss: %.4f ± %.4f\n', mean(all_best_fitness), std(all_best_fitness));
fprintf('Best Hyperparameters (mean across runs):\n');
fprintf('  C     = %.4f\n', mean(all_best_hyperparams(:,1)));
fprintf('  Gamma = %.4f\n', mean(all_best_hyperparams(:,2)));

%% 7. Save Final Summary
save('PWPA_Final_Results.mat', 'all_best_fitness', 'all_best_hyperparams', 'loss_baseline');
fprintf('\n✅ All results saved. Ready for paper reporting!\n');