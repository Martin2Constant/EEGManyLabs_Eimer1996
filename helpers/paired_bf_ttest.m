function [bf10, logbf] = paired_bf_ttest(t, n, tail, r)
    arguments
        t double;
        n double;
        tail string {mustBeMember(tail, ["two-sided", "greater", "less"])} = "two-sided";
        r double = sqrt(2) / 2;
    end
    df = n - 1;
    r2 = r^2;
    
    if tail == "two-sided"
        % Compute Bayes Factor (Rouder et al., 2009)
        % As in R package BayesFactor 0.9.4
        % Function to be integrated
        fun = @(g, t, n, df, r2) (dinvgamma(g, .5, .5) .* ...
                  exp( (-.5 .* log(1+n.*g.*r2)) + ( -(df+1)/2) .* ...
                  log(1+t.^2 ./ ((1+n.*g.*r2) .* (df)))));
        % JZS Bayes factor calculation
        marginal_likelihood_0 = (1 + t.^2 / df).^(-(df + 1) ./ 2);
        marginal_likelihood_1 = integral(@(g) fun(g, t, n, df, r2), 0, Inf);
        logbf = log(marginal_likelihood_1) - log(marginal_likelihood_0);
        bf10 = exp(logbf);
    elseif tail == "less"
        null_interval = [-Inf, 0];
        bf10 = ttest_area_null(t, n, null_interval, r);
        logbf = log(bf10);
    elseif tail == "greater"
        null_interval = [0, Inf];
        bf10 = ttest_area_null(t, n, null_interval, r);
        logbf = log(bf10);
    else
        bf10 = NaN;
        logbf = NaN;
    end
end