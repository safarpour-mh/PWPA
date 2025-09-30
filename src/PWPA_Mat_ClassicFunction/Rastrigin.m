function f = Rastrigin(x)
    f = 10*length(x) + sum(x.^2 - 10*cos(2*pi*x));
end