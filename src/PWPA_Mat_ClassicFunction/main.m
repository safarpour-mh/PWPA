clc; clear; close all;

% Settings
nRuns = 30;
nPop = 50;
nIter = 100;
dim = 100;

lb = -100;
ub = 100;

% Benchmark functions


% ✅ Benchmark functions — 6 functions
benchmarks = {@Sphere, @Rosenbrock, @Rastrigin, @Griewank, @Ackley, @Schwefel};
funcNames = {'Sphere', 'Rosenbrock', 'Rastrigin', 'Griewank', 'Ackley', 'Schwefel'};

% ✅ Algorithms  
algos = {@GA, @PSO, @GWO, @HHO, @COA,@PWPA };
algoNames = {'GA','PSO','GWO','HHO','COA','PWPA'};

colors = lines(length(algoNames)); % برای نمودارها

% Results storage
allResults = struct();

for f = 1:length(benchmarks)
    fHandle = benchmarks{f};
    fname = funcNames{f};
    fprintf('Running on %s...\n', fname);
    
    for a = 1:length(algos)
        algoFunc = algos{a};
        algoName = algoNames{a};
        
        bestVals = zeros(1,nRuns);
        convCurves = zeros(nRuns,nIter);
        
        for r = 1:nRuns
            [bestVal, curve] = algoFunc(fHandle, dim, nPop, nIter, lb, ub);
            bestVals(r) = bestVal;
            convCurves(r,:) = curve;
        end
        
        % Save results
        allResults.(fname).(algoName).best = min(bestVals);
        allResults.(fname).(algoName).mean = mean(bestVals);
        allResults.(fname).(algoName).std  = std(bestVals);
        allResults.(fname).(algoName).curves = convCurves;
        allResults.(fname).(algoName).allRuns = bestVals; % برای Boxplot
    end
end

save('results_full.mat','allResults');
disp(' ');
disp('✅ All experiments completed and saved to results_full.mat');
disp(' ');

%% ========== جدول مقایسه‌ای به‌روز ==========
fprintf('%-12s | %-6s |', 'Function', 'Metric');
for i = 1:length(algoNames)
    fprintf(' %-10s |', algoNames{i}); % ⬅️ اصلاح شده با {}
end
fprintf('\n');

fprintf('%-12s | %-6s |', '------------', '------');
for i = 1:length(algoNames)
    fprintf(' %-10s |', '----------');
end
fprintf('\n');

for f = 1:length(funcNames)
    fname = funcNames{f};
    
    % Extract metrics
    metrics = struct();
    for a = 1:length(algoNames)
        aname = algoNames{a};
        metrics.(aname).best = allResults.(fname).(aname).best;
        metrics.(aname).mean = allResults.(fname).(aname).mean;
        metrics.(aname).std  = allResults.(fname).(aname).std;
    end
    
    % Print Best
    fprintf('%-12s | %-6s |', fname, 'Best');
    for a = 1:length(algoNames)
        an = algoNames{a};
        fprintf(' %-10.2e |', metrics.(an).best);
    end
    fprintf('\n');
    
    % Print Mean
    fprintf('%-12s | %-6s |', '', 'Mean');
    for a = 1:length(algoNames)
        an = algoNames{a};
        fprintf(' %-10.2e |', metrics.(an).mean);
    end
    fprintf('\n');
    
    % Print Std
    fprintf('%-12s | %-6s |', '', 'Std');
    for a = 1:length(algoNames)
        an = algoNames{a};
        fprintf(' %-10.2e |', metrics.(an).std);
    end
    fprintf('\n');
    
    % Separator
    fprintf('%-12s | %-6s |', '------------', '------');
    for i = 1:length(algoNames)
        fprintf(' %-10s |', '----------');
    end
    fprintf('\n');
end

%% ========== رسم Convergence Curves ==========
figure('Position', [50, 50, 1400, 900]);
numFuncs = length(funcNames);
cols = 2;
rows = ceil(numFuncs / cols);

for f = 1:numFuncs
    fname = funcNames{f};
    subplot(rows, cols, f);
    
    hold on;
    for a = 1:length(algoNames)
        aname = algoNames{a};
        curve = mean(allResults.(fname).(aname).curves, 1); % میانگین 30 اجرا
        plot(1:nIter, curve, 'Color', colors(a,:), 'LineWidth', 2, 'DisplayName', aname);
    end
    
    title(sprintf('Convergence Curve: %s', fname), 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Iteration');
    ylabel('Best Fitness (log scale)');
    set(gca, 'YScale', 'log');
    grid on;
    legend('Location', 'northeastoutside');
    box on;
end
sgtitle('Convergence Curves (Average over 30 runs)', 'FontSize', 14);
saveas(gcf, 'convergence_curves.png');

%% ========== رسم Boxplot ==========
figure('Position', [100, 100, 1400, 900]);
for f = 1:numFuncs
    fname = funcNames{f};
    subplot(rows, cols, f);
    
    % ⬇️ اصلاح: تبدیل cell به ماتریس عددی
    dataMatrix = [];
    for a = 1:length(algoNames)
        aname = algoNames{a};
        runs = allResults.(fname).(aname).allRuns; % 1x30
        dataMatrix = [dataMatrix, runs']; % هر الگوریتم یک ستون (30x1)
    end
    
    % حالا dataMatrix یک ماتریس 30x6 است
    boxplot(dataMatrix, 'Labels', algoNames, 'Notch', 'on', 'OutlierSize', 3);
    
    title(sprintf('Boxplot: %s', fname), 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Best Fitness Value (log scale)');
    set(gca, 'YScale', 'log');
    grid on;
    xtickangle(45);
    ylim auto;
end
sgtitle('Boxplots of 30 Runs (log scale)', 'FontSize', 14);
saveas(gcf, 'boxplots.png');

disp('📊 Boxplots saved to boxplots.png');