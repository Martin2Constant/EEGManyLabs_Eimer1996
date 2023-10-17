function bf_null = ttest_area_null(t, n, null_interval, r, safe_int)
    % Adapted from the R package BayesFactor version 0.9.4
    arguments
        t double;
        n double;
        null_interval double = [-Inf, Inf];
        r double = sqrt(2) / 2;
        safe_int double = .9999;
    end
    df = n - 1;

    safe_range = t ./ sqrt(n) + [-1, 1] .* tinv(1 - (1 - safe_int) ./ 2, df) ./ sqrt(n);

    prior_odds = diff(cauchycdf(null_interval, 0, r));

    null_interval(1) = max(null_interval(1), safe_range(1));
    null_interval(2) = min(null_interval(2), safe_range(2));

    sqN = sqrt(n);

    fun = @(delta, t, sqN, df, r) exp(...
        log(nctpdf(t, df, delta*sqN)) + ...
        cauchylogpdf(delta, 0, r)...
        );

    all_integr = integral(@(delta) fun(delta, t, sqN, df, r),...
        safe_range(1), safe_range(2));

    log_const = log(all_integr);

    fun2 = @(delta, t, sqN, df, r, log_const) exp(...
        log(nctpdf(t, df, delta*sqN)) + ...
        cauchylogpdf(delta, 0, r) - ...
        log_const);

    area_integr = integral(@(delta) fun2(delta, t, sqN, df, r, log_const),...
        null_interval(1), null_interval(2));

    % encompassing vs point null
    [bf, logbf] = paired_bf_ttest(t, n, "two-sided", r);

    val = area_integr(1);
    val = log(val) - log(prior_odds) + logbf;
    bf_null = exp(val);
end