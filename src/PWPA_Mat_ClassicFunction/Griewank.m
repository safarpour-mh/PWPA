function f = Griewank(x)
    f = sum(x.^2)/4000 - prod(cos(x./sqrt(1:length(x)))) + 1;
end