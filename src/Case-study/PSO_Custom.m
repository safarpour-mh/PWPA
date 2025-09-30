function [best_hyperparams, best_fitness, convergence_curve] = PSO_Custom(obj_func, dim, nPop, nIter, lb, ub)
% Custom PSO implementation for fair comparison with PWPA
% Minimization problem

% Initialize particles
X = repmat(lb, nPop, 1) + rand(nPop, dim) .* repmat((ub - lb), nPop, 1);
V = zeros(nPop, dim); % Initial velocity

% Initialize personal best
pbest = X;
fitness = zeros(nPop, 1);
for i = 1:nPop
    fitness(i) = obj_func(X(i, :));
end
pbest_fitness = fitness;

% Initialize global best
[~, gbest_idx] = min(pbest_fitness);
gbest = pbest(gbest_idx, :);
gbest_fitness = pbest_fitness(gbest_idx);

% Inertia weight (linearly decreasing)
w_max = 0.9;
w_min = 0.4;

% Acceleration coefficients
c1 = 2;
c2 = 2;

% Convergence curve
convergence_curve = zeros(nIter, 1);

% Main loop
for t = 1:nIter
    w = w_max - (w_max - w_min) * t / nIter; % Linear decay
    
    for i = 1:nPop
        % Update velocity
        r1 = rand(1, dim);
        r2 = rand(1, dim);
        V(i, :) = w * V(i, :) + c1 * r1 .* (pbest(i, :) - X(i, :)) + c2 * r2 .* (gbest - X(i, :));
        
        % Update position
        X(i, :) = X(i, :) + V(i, :);
        
        % Boundary handling (clamping)
        X(i, :) = max(min(X(i, :), ub), lb);
        
        % Evaluate fitness
        new_fitness = obj_func(X(i, :));
        
        % Update personal best
        if new_fitness < pbest_fitness(i)
            pbest(i, :) = X(i, :);
            pbest_fitness(i) = new_fitness;
            
            % Update global best
            if new_fitness < gbest_fitness
                gbest = X(i, :);
                gbest_fitness = new_fitness;
            end
        end
    end
    
    convergence_curve(t) = gbest_fitness;
end

best_hyperparams = gbest;
best_fitness = gbest_fitness;
end