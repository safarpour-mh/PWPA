function [bestCost, convergenceCurve] = COA(fitnessFunc, dim, nPop, MaxIt, lb, ub)
% Capybara Optimization Algorithm (COA) — FINAL VERSION
% Compatible with main.m structure

%% Input Validation
if nargin < 6
    error('COA: Not enough input arguments. Expected 6.');
end

if ~isnumeric(dim) || dim < 1 || mod(dim,1) ~= 0
    error('COA: dim must be a positive integer.');
end

if ~isnumeric(nPop) || nPop < 1 || mod(nPop,1) ~= 0
    error('COA: nPop must be a positive integer.');
end

if ~isnumeric(MaxIt) || MaxIt < 1 || mod(MaxIt,1) ~= 0
    error('COA: MaxIt must be a positive integer.');
end

% Ensure lb, ub are row vectors of size [1 x dim]
if isscalar(lb), lb = lb * ones(1, dim); end
if isscalar(ub), ub = ub * ones(1, dim); end
lb = lb(:)'; ub = ub(:)'; % Force row vector

%% Initialize Population
pop = struct('Position', {}, 'Cost', {});
BestSol.Cost = inf;
convergenceCurve = zeros(1, MaxIt);

for i = 1:nPop
    pop(i).Position = lb + (ub - lb) .* rand(1, dim);
    pop(i).Cost = fitnessFunc(pop(i).Position);
    if pop(i).Cost < BestSol.Cost
        BestSol = pop(i);
    end
end

%% Main Loop
for it = 1:MaxIt
    % Sort population
    [~, idx] = sort([pop.Cost]);
    pop = pop(idx);
    
    if pop(1).Cost < BestSol.Cost
        BestSol = pop(1);
    end
    convergenceCurve(it) = BestSol.Cost;
    
    % Compute average position
    positions = cell2mat(arrayfun(@(i) pop(i).Position, 1:nPop, 'UniformOutput', false))';
    Xavg = mean(positions, 1);  % [1 x dim]
    
    r = 2 * (1 - it/MaxIt);  % Adaptive coefficient
    
    for i = 1:nPop
        if i <= nPop/2
            % Social foraging
            pop(i).Position = pop(i).Position + r * rand() * (BestSol.Position - pop(i).Position);
        else
            % Individual foraging
            randomVec = rand(1, dim) - 0.5;
            pop(i).Position = Xavg + r * randomVec .* (ub - lb);
        end
        
        % Boundary handling
        pop(i).Position = max(pop(i).Position, lb);
        pop(i).Position = min(pop(i).Position, ub);
        
        % Evaluate
        pop(i).Cost = fitnessFunc(pop(i).Position);
        if pop(i).Cost < BestSol.Cost
            BestSol = pop(i);
        end
    end
end

bestCost = BestSol.Cost;
end