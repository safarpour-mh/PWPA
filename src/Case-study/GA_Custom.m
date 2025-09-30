function [best_hyperparams, best_fitness, convergence_curve] = GA_Custom(obj_func, dim, nPop, nIter, lb, ub)
% Custom GA implementation for fair comparison with PWPA
% Minimization problem

% Initialize population
population = repmat(lb, nPop, 1) + rand(nPop, dim) .* repmat((ub - lb), nPop, 1);
fitness = zeros(nPop, 1);

% Evaluate initial fitness
for i = 1:nPop
    fitness(i) = obj_func(population(i, :));
end

% Convergence curve
convergence_curve = zeros(nIter, 1);

% GA parameters
mutation_rate = 0.1;
crossover_rate = 0.8;
tournament_size = 3;

% Main loop
for gen = 1:nIter
    new_population = zeros(nPop, dim);
    
    for i = 1:2:nPop % Process two parents at a time
        % Tournament selection for parent 1
        candidates = randperm(nPop, tournament_size);
        [~, idx1] = min(fitness(candidates));
        parent1 = population(candidates(idx1), :);
        
        % Tournament selection for parent 2
        candidates = randperm(nPop, tournament_size);
        [~, idx2] = min(fitness(candidates));
        parent2 = population(candidates(idx2), :);
        
        % Crossover
        if rand < crossover_rate
            crossover_point = randi([1, dim-1]);
            child1 = [parent1(1:crossover_point), parent2(crossover_point+1:end)];
            child2 = [parent2(1:crossover_point), parent1(crossover_point+1:end)];
        else
            child1 = parent1;
            child2 = parent2;
        end
        
        % Mutation
        for j = 1:dim
            if rand < mutation_rate
                child1(j) = child1(j) + 0.1 * (ub(j) - lb(j)) * randn; % Gaussian mutation
            end
            if rand < mutation_rate
                child2(j) = child2(j) + 0.1 * (ub(j) - lb(j)) * randn;
            end
        end
        
        % Boundary handling
        child1 = max(min(child1, ub), lb);
        child2 = max(min(child2, ub), lb);
        
        % Add to new population
        new_population(i, :) = child1;
        if i+1 <= nPop
            new_population(i+1, :) = child2;
        end
    end
    
    % Evaluate new population
    new_fitness = zeros(nPop, 1);
    for i = 1:nPop
        new_fitness(i) = obj_func(new_population(i, :));
    end
    
    % Elitism: Keep the best individual
    [~, best_idx_old] = min(fitness);
    [~, best_idx_new] = min(new_fitness);
    
    if fitness(best_idx_old) < new_fitness(best_idx_new)
        % Replace worst in new population with best from old
        [~, worst_idx] = max(new_fitness);
        new_population(worst_idx, :) = population(best_idx_old, :);
        new_fitness(worst_idx) = fitness(best_idx_old);
    end
    
    % Update population
    population = new_population;
    fitness = new_fitness;
    
    % Update convergence curve
    [~, best_idx] = min(fitness);
    convergence_curve(gen) = fitness(best_idx);
end

[~, best_idx] = min(fitness);
best_hyperparams = population(best_idx, :);
best_fitness = fitness(best_idx);
end