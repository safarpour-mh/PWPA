function y = Schwefel(x)
    % Schwefel Function
    % Global minimum at x_i = 420.9687, f(x) = -dim * 418.9829
    % Usual range: [-500, 500]
    y = 0;
    for i = 1:length(x)
        y = y - x(i) * sin(sqrt(abs(x(i))));
    end
end