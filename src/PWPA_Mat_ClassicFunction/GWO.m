function [bestVal, curve] = GWO(fHandle, dim, nPop, nIter, lb, ub)
    pop = lb + (ub-lb).*rand(nPop,dim);
    fitness = arrayfun(@(i) fHandle(pop(i,:)), 1:nPop)';
    [~, sortedIdx] = sort(fitness);
    alpha = pop(sortedIdx(1),:);   % α
    beta  = pop(sortedIdx(2),:);   % β
    delta = pop(sortedIdx(3),:);   % δ
    
    bestVal = fitness(sortedIdx(1));
    curve = zeros(1,nIter);
    
    for t = 1:nIter
        a = 2 - 2*t/nIter;
        
        for i = 1:nPop
            for j = 1:dim
                r1 = rand(); r2 = rand();
                A1 = 2*a*r1 - a; C1 = 2*r2;
                D_alpha = abs(C1*alpha(j) - pop(i,j));
                X1 = alpha(j) - A1*D_alpha;
                
                r1 = rand(); r2 = rand();
                A2 = 2*a*r1 - a; C2 = 2*r2;
                D_beta = abs(C2*beta(j) - pop(i,j));
                X2 = beta(j) - A2*D_beta;
                
                r1 = rand(); r2 = rand();
                A3 = 2*a*r1 - a; C3 = 2*r2;
                D_delta = abs(C3*delta(j) - pop(i,j));
                X3 = delta(j) - A3*D_delta;
                
                pop(i,j) = (X1 + X2 + X3)/3;
            end
        end
        
        pop = max(min(pop, ub), lb);
        fitness = arrayfun(@(i) fHandle(pop(i,:)), 1:nPop)';
        [~, sortedIdx] = sort(fitness);
        alpha = pop(sortedIdx(1),:);
        beta  = pop(sortedIdx(2),:);
        delta = pop(sortedIdx(3),:);
        bestVal = fitness(sortedIdx(1));
        curve(t) = bestVal;
    end
end