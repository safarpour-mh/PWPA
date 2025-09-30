%% Sensitivity Analysis for PWPA Algorithm
% Analyzes the sensitivity of PWPA to parameters F (Mutation Factor) and CR (Crossover Rate)
% Benchmark Functions: Sphere, Rastrigin, Rosenbrock
% Dimension: D = 100
% Runs: 30 independent runs per setting

clear; clc; close all;

%% Define Parameters
D = 100;                    % Problem Dimension
nPop = 50;                  % Population Size
nIter = 100;                % Max Iterations
lb = -100; ub = 100;        % Bounds

% Parameter Ranges for Sensitivity Analysis
F_values = [0.1, 0.3, 0.5, 0.7, 0.9, 1.0];   % Mutation Factor (Eq. 5)
CR_values = [0.1, 0.3, 0.5, 0.7, 0.9, 1.0]; % Crossover Rate (Eq. 6)

nRuns = 30;                 % Number of independent runs

% Define Test Functions
testFunctions = {@sphere, @rastrigin, @rosenbrock};
functionNames = {'Sphere', 'Rastrigin', 'Rosenbrock'};

%% Preallocate Results
nF = length(F_values);
nCR = length(CR_values);
nFunc = length(testFunctions);

% For F sensitivity (CR fixed at 0.9)
meanResults_F = zeros(nF, nFunc);
stdResults_F = zeros(nF, nFunc);

% For CR sensitivity (F fixed at 0.5)
meanResults_CR = zeros(nCR, nFunc);
stdResults_CR = zeros(nCR, nFunc);

%% Run Sensitivity Analysis for F (with CR = 0.9 fixed)
fprintf('Running Sensitivity Analysis for Mutation Factor (F)...\n');
CR_fixed = 0.9;

for funcIdx = 1:nFunc
    objFun = testFunctions{funcIdx};
    fprintf('  Function: %s\n', functionNames{funcIdx});
    
    for i = 1:nF
        F_current = F_values(i);
        bestFitnesses = zeros(nRuns, 1);
        
        for run = 1:nRuns
            [~, best_fitness] = PWPA(objFun, D, nPop, nIter, lb, ub, F_current, CR_fixed);
            bestFitnesses(run) = best_fitness;
        end
        
        meanResults_F(i, funcIdx) = mean(bestFitnesses);
        stdResults_F(i, funcIdx) = std(bestFitnesses);
    end
end

%% Run Sensitivity Analysis for CR (with F = 0.5 fixed)
fprintf('Running Sensitivity Analysis for Crossover Rate (CR)...\n');
F_fixed = 0.5;

for funcIdx = 1:nFunc
    objFun = testFunctions{funcIdx};
    fprintf('  Function: %s\n', functionNames{funcIdx});
    
    for i = 1:nCR
        CR_current = CR_values(i);
        bestFitnesses = zeros(nRuns, 1);
        
        for run = 1:nRuns
            [~, best_fitness] = PWPA(objFun, D, nPop, nIter, lb, ub, F_fixed, CR_current);
            bestFitnesses(run) = best_fitness;
        end
        
        meanResults_CR(i, funcIdx) = mean(bestFitnesses);
        stdResults_CR(i, funcIdx) = std(bestFitnesses);
    end
end

%% Display Results in Tables

% Table for F Sensitivity
fprintf('\n\n=== SENSITIVITY TO MUTATION FACTOR (F) [CR=0.9] ===\n');
for funcIdx = 1:nFunc
    fprintf('\n--- %s Function (D=%d) ---\n', functionNames{funcIdx}, D);
    fprintf('%10s %20s %20s\n', 'F', 'Mean Best Fitness', 'Std');
    fprintf('%10s %20s %20s\n', '----------', '--------------------', '--------------------');
    for i = 1:nF
        fprintf('%10.1f %20.4e %20.4e\n', F_values(i), meanResults_F(i, funcIdx), stdResults_F(i, funcIdx));
    end
end

% Table for CR Sensitivity
fprintf('\n\n=== SENSITIVITY TO CROSSOVER RATE (CR) [F=0.5] ===\n');
for funcIdx = 1:nFunc
    fprintf('\n--- %s Function (D=%d) ---\n', functionNames{funcIdx}, D);
    fprintf('%10s %20s %20s\n', 'CR', 'Mean Best Fitness', 'Std');
    fprintf('%10s %20s %20s\n', '----------', '--------------------', '--------------------');
    for i = 1:nCR
        fprintf('%10.1f %20.4e %20.4e\n', CR_values(i), meanResults_CR(i, funcIdx), stdResults_CR(i, funcIdx));
    end
end

%% Plot Results

% Plot for F Sensitivity
figure('Position', [100, 100, 1200, 400]);
for funcIdx = 1:nFunc
    subplot(1, 3, funcIdx);
    errorbar(F_values, meanResults_F(:, funcIdx), stdResults_F(:, funcIdx), 'o-', 'MarkerSize', 6, 'LineWidth', 1.5);
    title(sprintf('%s (CR=0.9)', functionNames{funcIdx}), 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Mutation Factor (F)', 'FontSize', 11);
    ylabel('Mean Best Fitness', 'FontSize', 11);
    grid on; box on;
    set(gca, 'FontSize', 10);
end
sgtitle('Sensitivity of PWPA to Mutation Factor (F)', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, 'sensitivity_F.png');

% Plot for CR Sensitivity
figure('Position', [100, 550, 1200, 400]);
for funcIdx = 1:nFunc
    subplot(1, 3, funcIdx);
    errorbar(CR_values, meanResults_CR(:, funcIdx), stdResults_CR(:, funcIdx), 's-', 'MarkerSize', 6, 'LineWidth', 1.5);
    title(sprintf('%s (F=0.5)', functionNames{funcIdx}), 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Crossover Rate (CR)', 'FontSize', 11);
    ylabel('Mean Best Fitness', 'FontSize', 11);
    grid on; box on;
    set(gca, 'FontSize', 10);
end
sgtitle('Sensitivity of PWPA to Crossover Rate (CR)', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, 'sensitivity_CR.png');

fprintf('\n✅ Sensitivity analysis completed. Results saved to tables and figures.\n');

%% ========================
%% CORE PWPA FUNCTION (Modified to accept F and CR as inputs)
%% ========================
function [bestSol, bestFitness, convergenceCurve] = PWPA(objFun, dim, nPop, nIter, lb, ub, F_mut, CR_cross)
    % Initialize population
    X = lb + (ub - lb) * rand(nPop, dim);
    F = zeros(nPop, 1);
    
    % Evaluate initial fitness
    for i = 1:nPop
        F(i) = objFun(X(i, :));
    end
    
    % Find best solution
    [~, idx] = min(F);
    bestSol = X(idx, :);
    bestFitness = F(idx);
    
    % Initialize convergence curve
    convergenceCurve = zeros(nIter, 1);
    
    % Main loop
    for t = 1:nIter
        a = 2 * (1 - t/nIter); % Linear decay
        
        % === PHASE 1: SEDIMENTATION ===
        for i = 1:nPop
            r1 = rand(1, dim);   % ← FIXED: row vector
            r2 = rand(1, dim);   % ← FIXED: row vector
            A = 2 * a * r1 - a;
            C = 2 * r2;
            
            if norm(A) < 1
                D = abs(C .* (bestSol - X(i, :)));
                X(i, :) = bestSol - A .* D;
            else
                randIdx = randi(nPop);
                while randIdx == i
                    randIdx = randi(nPop);
                end
                X_rand = X(randIdx, :);
                D = abs(C .* (X_rand - X(i, :)));
                X(i, :) = X_rand - A .* D;
            end
        end
        
        % Apply bounds
        X = max(min(X, ub), lb);
        
        % === PHASE 2: FILTRATION ===
        for i = 1:nPop
            % Select three distinct random indices
            idxs = randperm(nPop);
            idxs = idxs(idxs ~= i); % Exclude current index
            if length(idxs) < 3
                idxs = [idxs, randi(nPop, 1, 3-length(idxs))]; % Pad if needed (rare)
            end
            r1 = idxs(1); r2 = idxs(2); r3 = idxs(3);
            
            % Mutation (Eq. 5) — USING INPUT F_mut
            V = X(r1, :) + F_mut * (X(r2, :) - X(r3, :));
            
            % Crossover (Eq. 6) — USING INPUT CR_cross
            U = X(i, :);
            j_rand = randi(dim);
            for j = 1:dim
                if rand <= CR_cross || j == j_rand
                    U(j) = V(j);
                end
            end
            
            % Greedy selection
            fU = objFun(U);
            if fU < F(i)
                X(i, :) = U;
                F(i) = fU;
            end
        end
        
        % === PHASE 3: FINAL PURIFICATION ===
        % Sort population to find top 3 (Alpha, Beta, Delta)
        [F_sorted, idx_sorted] = sort(F);
        X_sorted = X(idx_sorted, :);
        X_alpha = X_sorted(1, :); F_alpha = F_sorted(1);
        X_beta  = X_sorted(2, :); F_beta  = F_sorted(2);
        X_delta = X_sorted(3, :); F_delta = F_sorted(3);
        
        for i = 1:nPop
            X_temp = zeros(3, dim);
            leaders = {X_alpha, X_beta, X_delta};
            for k = 1:3
                X_k = leaders{k};
                r1 = rand(1, dim);   % ← FIXED: row vector
                r2 = rand(1, dim);   % ← FIXED: row vector
                A_k = 2 * a * r1 - a;
                C_k = 2 * r2;
                D_k = abs(C_k .* (X_k - X(i, :)));
                X_temp(k, :) = X_k - A_k .* D_k;
            end
            % Update position to centroid of top 3 (Eq. 9)
            X(i, :) = mean(X_temp, 1);
        end
        
        % Apply bounds
        X = max(min(X, ub), lb);
        
        % Evaluate fitness and update best
        for i = 1:nPop
            F(i) = objFun(X(i, :));
        end
        [~, idx] = min(F);
        if F(idx) < bestFitness
            bestFitness = F(idx);
            bestSol = X(idx, :);
        end
        
        convergenceCurve(t) = bestFitness;
    end
end

%% ========================
%% BENCHMARK FUNCTIONS
%% ========================
function y = sphere(x)
    y = sum(x.^2);
end

function y = rastrigin(x)
    n = length(x);
    y = 10*n + sum(x.^2 - 10*cos(2*pi*x));
end

function y = rosenbrock(x)
    d = length(x);
    if d < 2
        y = 0;
    else
        y = sum(100*(x(2:d) - x(1:d-1).^2).^2 + (1 - x(1:d-1)).^2);
    end
end