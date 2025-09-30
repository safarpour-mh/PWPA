function [bestVal, curve] = HHO(fHandle, dim, nPop, nIter, lb, ub)
    pop = lb + (ub-lb).*rand(nPop,dim);
    fitness = arrayfun(@(i) fHandle(pop(i,:)), 1:nPop)';
    [bestVal, idx] = min(fitness);
    bestSol = pop(idx,:);
    
    curve = zeros(1,nIter);
    
    for t = 1:nIter
        E1 = 2*(1 - t/nIter);
        
        for i = 1:nPop
            E = E1 * (2*rand() - 1);
            if abs(E) >= 1
                % جستجوی اکتشافی
                q = rand();
                if q >= 0.5
                    randIdx = randi(nPop);
                    pop(i,:) = pop(randIdx,:) - rand() .* abs(pop(randIdx,:) - 2*rand() .* pop(i,:));
                else
                    pop(i,:) = bestSol - mean(pop) - rand() .* (ub - lb);
                end
            else
                % جستجوی بهره‌برداری
                r = rand(); jump = 2*(1-rand());
                if r >= 0.5 && abs(E) < 0.5
                    % حالت نشستن
                    pop(i,:) = bestSol - E .* abs(bestSol - pop(i,:));
                elseif r >= 0.5 && abs(E) >= 0.5
                    % حالت حصارکشی
                    pop(i,:) = bestSol - E .* abs(jump*bestSol - pop(i,:));
                elseif r < 0.5 && abs(E) >= 0.5
                    % حالت سریع شکار
                    Y = bestSol - E .* abs(jump*bestSol - pop(i,:));
                    Z = Y - rand() .* (lb + rand() .* (ub - lb));
                    if fHandle(Y) < fitness(i)
                        pop(i,:) = Y;
                    elseif fHandle(Z) < fitness(i)
                        pop(i,:) = Z;
                    end
                else
                    % حالت سریع شکار با نرم‌افزاری
                    Y = bestSol - E .* abs(jump*bestSol - pop(i,:));
                    Z = Y - rand() .* (lb + rand() .* (ub - lb));
                    if fHandle(Y) < fitness(i)
                        pop(i,:) = Y;
                    elseif fHandle(Z) < fitness(i)
                        pop(i,:) = Z;
                    else
                        pop(i,:) = bestSol - E .* abs(bestSol - pop(i,:));
                    end
                end
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