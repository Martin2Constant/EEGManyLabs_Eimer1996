function t = compute_t(x, y)
    if nargin < 2
        y = 0;
    end
    x = mean(x, 2);
    if y
        y = mean(y, 2);
    end
    
    t = mean(x - y) / (std(x - y) / sqrt(length(x)));
end
