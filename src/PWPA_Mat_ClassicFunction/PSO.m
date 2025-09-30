function [bestVal, curve] = PSO(fHandle, dim, nPop, nIter, lb, ub)
    % Simple PSO
    
    w = 0.7; c1 = 1.5; c2 = 1.5;
    pos = lb + (ub-lb)*rand(nPop,dim);
    vel = zeros(nPop,dim);
    
    pbest = pos;
    pbestVal = arrayfun(@(i) fHandle(pos(i,:)), 1:nPop)';
    [bestVal, idx] = min(pbestVal);
    gbest = pos(idx,:);
    
    curve = zeros(1,nIter);
    
    for t = 1:nIter
        for i = 1:nPop
            vel(i,:) = w*vel(i,:) + c1*rand*(pbest(i,:)-pos(i,:)) + c2*rand*(gbest-pos(i,:));
            pos(i,:) = pos(i,:) + vel(i,:);
            pos(i,:) = max(min(pos(i,:),ub),lb);
            
            val = fHandle(pos(i,:));
            if val < pbestVal(i)
                pbestVal(i) = val;
                pbest(i,:) = pos(i,:);
            end
            if val < bestVal
                bestVal = val;
                gbest = pos(i,:);
            end
        end
        curve(t) = bestVal;
    end
end
