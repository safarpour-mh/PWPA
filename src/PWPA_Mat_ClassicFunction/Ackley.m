function f = Ackley(x)
    n = length(x);
    f = -20*exp(-0.2*sqrt(sum(x.^2)/n)) - exp(sum(cos(2*pi*x))/n) + 20 + exp(1);
end
