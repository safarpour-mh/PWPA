function [bestVal, curve] = WOA(fHandle, dim, nPop, nIter, lb, ub)
    pop = lb + (ub-lb).*rand(nPop,dim);
    fitness = arrayfun(@(i) fHandle(pop(i,:)), 1:nPop)';
    [bestVal, idx] = min(fitness);
    bestSol = pop(idx,:);
    
    curve = zeros(1,nIter);
    
    % ========================
    % ⬇️ اضافه شده: تعریف پارامتر b
    b = 1; % Spiral constant (معمولاً 1 در نظر گرفته می‌شود)
    % ========================
    
    for t = 1:nIter
        a = 2 - 2*t/nIter; % خطی کاهشی
        
        for i = 1:nPop
            r = rand();
            A = 2*a*r - a;
            C = 2*r;
            
            if rand() < 0.5
                if abs(A) < 1
                    D = abs(C*bestSol - pop(i,:));
                    pop(i,:) = bestSol - A .* D;
                else
                    randIdx = randi(nPop);
                    randSol = pop(randIdx,:);
                    D = abs(C*randSol - pop(i,:));
                    pop(i,:) = randSol - A .* D;
                end
            else
                D = abs(bestSol - pop(i,:));
                l = -1 + 2*rand();
                pop(i,:) = D .* exp(b*l) .* cos(2*pi*l) + bestSol; % ⬅️ اینجا از b استفاده می‌شه
            end
        end
        
        pop = max(min(pop, ub), lb);
        fitness = arrayfun(@(i) fHandle(pop(i,:)), 1:nPop)';
        [currBest, idx] = min(fitness);
        if currBest < bestVal
            bestVal = currBest;
            bestSol = pop(idx,:);
        end
        curve(t) = bestVal;
    end
end