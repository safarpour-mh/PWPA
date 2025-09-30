function [best_hyperparams, best_fitness, convergence_curve] = RandomSearch_Custom(obj_func, dim, lb, ub, max_evals)
% Random Search implementation for fair comparison
% Minimization problem

best_fitness = inf;
best_hyperparams = [];
convergence_curve = zeros(max_evals, 1);

for eval = 1:max_evals
    % Generate random hyperparameters
    rand_hyper = lb + rand(1, dim) .* (ub - lb);
    
    % Evaluate fitness
    current_fitness = obj_func(rand_hyper);
    
    % Update best
    if current_fitness < best_fitness
        best_fitness = current_fitness;
        best_hyperparams = rand_hyper;
    end
    
    convergence_curve(eval) = best_fitness;
end
end