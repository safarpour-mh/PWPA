function [bestVal, curve] = PWPA(fHandle, dim, nPop, nIter, lb, ub)
% Designed for single-objective, continuous optimization problems
% Inspired by: Sedimentation (Global), Filtration (Diversity), Purification (Local)

%% === Ensure lb and ub are row vectors ===
if isscalar(lb), lb = lb * ones(1, dim); end
if isscalar(ub), ub = ub * ones(1, dim); end

%% === Initialization ===
pop = lb + (ub - lb) .* rand(nPop, dim);  % Initial population
fitness = arrayfun(@(i) fHandle(pop(i,:)), 1:nPop)';
[bestVal, idx] = min(fitness);
bestSol = pop(idx,:);  % Best solution found so far
curve = zeros(1, nIter);

%% === Main Loop ===
for t = 1:nIter
    pop_old = pop;  % Store for DE selection later

    %% --- 1. SEDIMENTATION (Global Search via WOA-inspired mechanism) ---
    a_linear = 2 - 2 * t / nIter;  % Linear decrease from 2 to 0
    for i = 1:nPop
        A = 2 * a_linear * rand - a_linear;
        C = 2 * rand;
        
        if abs(A) < 1
            % Exploitation: move toward best solution
            D = abs(C * bestSol - pop(i,:));
            pop(i,:) = bestSol - A * D;
        else
            % Exploration: random encircling
            random_idx = randi(nPop);
            random_sol = pop(random_idx, :);
            D = abs(C * random_sol - pop(i,:));
            pop(i,:) = random_sol - A * D;
        end
    end

    %% --- Boundary Handling after Sedimentation ---
    pop = max(min(pop, repmat(ub, nPop, 1)), repmat(lb, nPop, 1));

    %% --- 2. FILTRATION (Enhanced Diversity via DE Mutation & Crossover) ---
    F = 0.5;   % Mutation factor
    CR = 0.9;  % Crossover probability
    for i = 1:nPop
        % Select 3 distinct random indices different from i
        candidates = setdiff(1:nPop, i);
        if length(candidates) < 3
            continue;  % Skip if not enough candidates (unlikely for nPop>=4)
        end
        idxs = candidates(randperm(length(candidates), 3));
        r1 = idxs(1); r2 = idxs(2); r3 = idxs(3);
        
        % Mutation: DE/rand/1
        mutant = pop(r1,:) + F * (pop(r2,:) - pop(r3,:));
        
        % Crossover: Binomial
        cross_points = rand(1, dim) <= CR;
        if ~any(cross_points)  % Ensure at least one gene crosses over
            cross_points(randi(dim)) = true;
        end
        
        trial = pop(i,:);
        trial(cross_points) = mutant(cross_points);
        
        % Boundary handling for trial
        trial = max(min(trial, ub), lb);
        
        % Greedy Selection: replace only if better
        if fHandle(trial) < fHandle(pop_old(i,:))
            pop(i,:) = trial;
        end
    end

    %% --- 3. PURIFICATION (Local Refinement via GWO-inspired mechanism) ---
    % Find top 3 solutions (alpha, beta, delta)
    [sorted_fitness, sort_idx] = sort(fitness);
    top3_idx = sort_idx(1:min(3, nPop));
    
    alpha_sol = pop(top3_idx(1), :);
    
    % --- Replace ternary operator with if-else for MATLAB compatibility ---
    if length(top3_idx) > 1
        beta_sol = pop(top3_idx(2), :);
    else
        beta_sol = alpha_sol;
    end
    if length(top3_idx) > 2
        delta_sol = pop(top3_idx(3), :);
    else
        delta_sol = alpha_sol;
    end
    % ---------------------------------------------------------------------

    a_gwo = 2 - 2 * t / nIter;  % Same linear decrease
    for i = 1:nPop
        r1 = rand; r2 = rand;
        A1 = 2 * a_gwo * r1 - a_gwo;
        A2 = 2 * a_gwo * r1 - a_gwo;
        A3 = 2 * a_gwo * r1 - a_gwo;
        C1 = 2 * r2; C2 = 2 * r2; C3 = 2 * r2;
        
        D_alpha = abs(C1 * alpha_sol - pop(i,:));
        D_beta  = abs(C2 * beta_sol  - pop(i,:));
        D_delta = abs(C3 * delta_sol - pop(i,:));
        
        X1 = alpha_sol - A1 * D_alpha;
        X2 = beta_sol  - A2 * D_beta;
        X3 = delta_sol - A3 * D_delta;
        
        pop(i,:) = (X1 + X2 + X3) / 3;
    end

    %% --- Final Boundary Handling ---
    pop = max(min(pop, repmat(ub, nPop, 1)), repmat(lb, nPop, 1));

    %% --- Evaluate Fitness ---
    fitness = arrayfun(@(i) fHandle(pop(i,:)), 1:nPop)';
    [currBest, idx] = min(fitness);

    %% --- Update Global Best ---
    if currBest < bestVal
        bestVal = currBest;
        bestSol = pop(idx,:);
    end

    %% --- Record convergence ---
    curve(t) = bestVal;
end

end