function [bestCost, convergenceCurve] = GA(fitnessFunc, dim, nPop, MaxIt, lb, ub)
% Simple Genetic Algorithm — FIXED & COMPATIBLE
% Input: fitnessFunc, dim, nPop, MaxIt, lb, ub
% Output: bestCost, convergenceCurve

%% Input Validation
if nargin < 6
    error('GA: Not enough input arguments. Expected 6.');
end

if ~isnumeric(dim) || dim < 1 || mod(dim,1) ~= 0
    error('GA: dim must be a positive integer.');
end

if ~isnumeric(nPop) || nPop < 1 || mod(nPop,1) ~= 0
    error('GA: nPop must be a positive integer.');
end

if ~isnumeric(MaxIt) || MaxIt < 1 || mod(MaxIt,1) ~= 0
    error('GA: MaxIt must be a positive integer.');
end

% Ensure lb, ub are row vectors of size [1 x dim]
if isscalar(lb), lb = lb * ones(1, dim); end
if isscalar(ub), ub = ub * ones(1, dim); end
lb = lb(:)'; ub = ub(:)'; % Force row vector

%% Initialize Population
pop = lb + (ub - lb) .* rand(nPop, dim);  % [nPop x dim] matrix
convergenceCurve = zeros(1, MaxIt);

%% Evaluate Fitness
fitness = zeros(nPop, 1);
for i = 1:nPop
    fitness(i) = fitnessFunc(pop(i, :));
end

% Find best individual
[minFit, bestIdx] = min(fitness);  % bestIdx is scalar integer
BestSol.Position = pop(bestIdx, :);  % ← خط ۲۴ — حالا خطا ندارد
BestSol.Cost = minFit;

%% GA Parameters
mutationRate = 0.1;

%% Main Loop
for it = 1:MaxIt
    newPop = zeros(nPop, dim);
    
    for i = 1:nPop
        % Tournament Selection (size 2)
        idx1 = randi(nPop);
        idx2 = randi(nPop);
        parent1 = pop(idx1, :);
        parent2 = pop(idx2, :);
        
        % Crossover (Single Point)
        if rand < 0.8
            cp = randi([1, dim-1]);  % crossover point
            child = [parent1(1:cp), parent2(cp+1:end)];
        else
            child = parent1;
        end
        
        % Mutation
        if rand < mutationRate
            idx = randi(dim);
            child(idx) = lb(idx) + (ub(idx) - lb(idx)) * rand;
        end
        
        newPop(i, :) = child;
    end
    
    % Update population
    pop = newPop;
    
    % Re-evaluate fitness
    for i = 1:nPop
        fitness(i) = fitnessFunc(pop(i, :));
    end
    
    % Update best solution
    [minFit, bestIdx] = min(fitness);
    if minFit < BestSol.Cost
        BestSol.Cost = minFit;
        BestSol.Position = pop(bestIdx, :);
    end
    
    convergenceCurve(it) = BestSol.Cost;
end

bestCost = BestSol.Cost;

end