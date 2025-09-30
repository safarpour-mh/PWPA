function [best_hyperparams, best_fitness, best_position_history] = PWPA(fHandle, dim, nPop, nIter, lb, ub, varargin)
% PWPA.m — Enhanced with Progress Display for Q1 Experiments

% Initialize population
pop = lb + (ub - lb) .* rand(nPop, dim);
fitness = zeros(nPop, 1);

% Evaluate initial population
fprintf('Initializing population...\n');
for i = 1:nPop
    fprintf('Evaluating individual %d/%d...', i, nPop);
    tic;
    fitness(i) = fHandle(pop(i,:), varargin{:});
    toc;
end

[best_fitness, best_idx] = min(fitness);
best_hyperparams = pop(best_idx, :);
best_position_history = zeros(nIter, dim);
best_position_history(1,:) = best_hyperparams;

% Main loop
for iter = 1:nIter
    fprintf('\n--- ITERATION %d / %d ---\n', iter, nIter);
    pop_old = pop;
    
    for i = 1:nPop
        % Generate trial vector (example: random walk — adjust based on your PWPA logic)
        trial = pop(i,:) + 0.1 * randn(1, dim) .* (ub - lb);
        trial = max(min(trial, ub), lb); % Bound enforcement
        
        % Evaluate fitness
        fprintf('🔄 Iter %d, Individual %d: Evaluating fitness... ', iter, i);
        tic;
        trial_fitness = fHandle(trial, varargin{:});
        toc_time = toc;
        fprintf('✅ Fitness=%.4f (in %.2fs)\n', trial_fitness, toc_time);
        
        % Selection
        if trial_fitness < fitness(i)
            pop(i,:) = trial;
            fitness(i) = trial_fitness;
            
            if trial_fitness < best_fitness
                best_fitness = trial_fitness;
                best_hyperparams = trial;
            end
        end
    end
    
    best_position_history(iter,:) = best_hyperparams;
    fprintf('🌟 Best Fitness so far: %.4f\n', best_fitness);
end

end