function t = compute_t(x, y)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    % x is a vector of double
    % y is either a vector of double (paired-sample t) or 0 (one-sample t)
    % Inputting the contra-ipsi difference as x and y = 0 should be 
    % equivalent to inputting x = contra and y = ipsi.
    arguments
        x double;
        y double = 0;
    end
    x = mean(x, 2);
    if y
        y = mean(y, 2);
    end
    
    t = mean(x - y) / (std(x - y) / sqrt(length(x)));
end
