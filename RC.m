function RC = RC(t, T, Beta)
    % Raised cosine pulse definition
    RC = sinc(t/T) .* cos(pi * Beta * t / T) ./ (1 - (2 * Beta * t / T) .^ 2);
    RC(t == T/(2*Beta)) = (pi/4) .* sinc(1/(2*Beta));
    RC(t == -T/(2*Beta)) = (pi/4) .* sinc(1/(2*Beta));
end