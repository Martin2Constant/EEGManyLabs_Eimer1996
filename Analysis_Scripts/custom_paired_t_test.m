function [mean_amps, between_confidence_intervals, within_confidence_intervals, stats] = custom_paired_t_test(x, y, alpha, tail)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    % Computes paired-sample t test, BayesFactor t test, 95% between- and within-participant CIs,
    % Cohen's dz and its 95% confidence intervals, Hedges' gz and its 95% confidence intervals.
    %
    % Parameters
    % ----------
    % x: vector of double
    %     First vector of values to compare, one value per participant.
    %     x(i) should refer to the same participant as y(i).
    % y: vector of double
    %     Second vector of values to compare, one value per participant.
    %     y(i) should refer to the same participant as x(i).
    % alpha: double, optional 
    %     Significance threshold of the test. The default is .02.
    % tail : string, optional (one of: "two-sided", "greater", "less")
    %     t-test tail. The default is "two-sided".
    %
    % Notes
    % ----------
    % The t value is computed from (x - y), so for contra minus ipsi comparisons
    % x should be the vector of contralateral amplitudes and y the vector
    % of ipsilateral amplitudes.
    % The same goes for the tail, "less" means that we will test
    % whether contra (x) is less than ipsi (y).
    %
    % Returns
    % ----------
    % mean_amps: vector of double
    %     Mean value (one per condition) of x and y.
    % between_confidence_intervals: vector of double
    %     Between-participants confidence intervals for x and y.
    % within_confidence_intervals: vector of double
    %     Within-participants confidence intervals for x and y.
    % stats: struct
    %     Structure containing:
    %       stats.t: double
    %           T value.
    %       stats.alpha: double
    %           Significance threshold for that test.
    %       stats.n: double
    %           Number of data points
    %       stats.df: double
    %           Degrees of freedom used to compute BF and p value.
    %       stats.dz: vector of double -> [dz, low_dz, high_dz]
    %           Contains Cohen's dz and its confidence intervals.
    %       stats.gz: vector of double -> [gz, low_gz, high_gz]
    %           Contains Hedges's gz and its confidence intervals.
    %       stats.p: double
    %           Computed p value.
    %       stats.bf10: double or NaN (if tail is not two-sided)
    %           Bayes Factor for the alternative hypothesis.
    %       stats.mean_diff: double
    %           Mean difference of (x - y).
    %       stats.diff_ci: double
    %           Within-participant confidence interval of the (x - y) difference.
    %       stats.reject_null: string
    %           Whether the null hypothesis should be rejected.
    %           "rejected" if p <= alpha else "not rejected".
    %
    % References
    % ----------
    % * Cohen, J. (1988). Statistical power analysis for the behavioral sciences (2nd ed.). Routledge. https://doi.org/10/vv3
    %
    % * Cousineau, D. (2005). Confidence intervals in within-subject designs: A simpler solution to Loftus and Masson’s method. Tutorials in Quantitative Methods for psychology, 1(1), 42–45. https://doi.org/10/b9z7
    %
    % * Cousineau, D., & O’Brien, F. (2014). Error bars in within-subject designs: A comment on Baguley (2012). Behavior Research Methods, 46(4), 1149–1151. https://doi.org/10/f6vdsw
    %
    % * Fitts, D. A. (2020). Commentary on “A review of effect sizes and their confidence intervals, Part I: The Cohen’s d family”: The degrees of freedom for paired samples designs. The Quantitative Methods for psychology, 16(4), 281–294. https://doi.org/10/gk3rr4
    %
    % * Goulet-Pelletier, J.-C., & Cousineau, D. (2018). A review of effect sizes and their confidence intervals, Part I: The Cohen’s d family. The Quantitative Methods for psychology, 14(4), 242–265. https://doi.org/10/gkzn9m
    %
    % * Goulet-Pelletier, J.-C., & Cousineau, D. (2019). Corrigendum to “A review of effect sizes and their confidence intervals, Part I: The Cohen’s d family.” The Quantitative Methods for psychology, 15(1), 54–54. https://doi.org/10/gk3pvk
    %
    % * Hedges, L. V. (1981). Distribution theory for Glass’s estimator of effect size and related estimators. Journal of Educational Statistics, 6(2), 107. https://doi.org/10/dbqn45
    %
    % * Hedges, L. V., & Olkin, I. (1985). Statistical methods for meta-analysis. Academic Press.
    %
    % * Morey, R. D. (2008). Confidence intervals from normalized data: A correction to Cousineau (2005). Tutorials in Quantitative Methods for psychology, 4(2), 61–64. https://doi.org/10/ggbnjg
    %
    % * Morey, R. D., & Wagenmakers, E.-J. (2014). Simple relation between Bayesian order-restricted and point-null hypothesis tests. Statistics & Probability Letters, 92, 121–124. https://doi.org/10/ggcpcq
    %
    % * Rouder, J. N., Speckman, P. L., Sun, D., Morey, R. D., & Iverson, G. (2009). Bayesian t tests for accepting and rejecting the null hypothesis. Psychonomic Bulletin & Review, 16(2), 225–237. https://doi.org/10/b3hsdp
    arguments (Input)
        x (:, 1) double;
        y (:, 1) double;
        alpha double = .02;
        tail string = "two-sided";
    end
    arguments (Output)
        mean_amps (1, 2) double;
        between_confidence_intervals (1, 2) double;
        within_confidence_intervals (1, 2) double;
        stats struct;
    end

    mean_x = mean(x);
    mean_y = mean(y);
    mean_diff = mean(x - y);
    std_diff = std(x - y);
    n = length(x);
    df = n-1;
    sqN = sqrt(n);

    % Computing within CIs on normalized dataset (Cousineau, 2005; Morey, 2008; Cousineau & O'Brien, 2014)
    means_participant = means([x'; y'])';
    grand_average = mean([x; y]);
    nb_cond = 2;
    correction = sqrt(nb_cond / (nb_cond - 1));

    % Cousineau & O'Brien (2014) Eq. 2 -> Ysj = Xsj - mean(Xs) + mean(X)
    norm_x = x - means_participant + grand_average;
    norm_y = y - means_participant + grand_average;

    % Cousineau & O'Brien (2014) Eq. 4 -> Zsj = correction * (Ysj - mean(Yj)) + mean(Yj)
    norm_x = correction * (norm_x - mean(norm_x)) + mean(norm_x);
    norm_y = correction * (norm_y - mean(norm_y)) + mean(norm_y);

    % Confidence interval = SEM * critical t-value
    critical_t = tinv(1 - alpha / 2, df);
    between_x_ci = (std(x) / sqN) * critical_t;
    between_y_ci = (std(y) / sqN) * critical_t;
    within_x_ci = (std(norm_x) / sqN) * critical_t;
    within_y_ci = (std(norm_y) / sqN) * critical_t;
    diff_ci = (std_diff / sqN) * critical_t;

    cohen_dz = mean_diff / std_diff;  % Cohen's dz for difference scores, (Cohen, 1988)

    % Fitts (2020); Goulet-Pelletier & Cousineau (2018, 2019)
    non_central_parameter_dz = cohen_dz * sqN;  % Non-central parameter
    lldt = nctinv(alpha / 2, df, non_central_parameter_dz);  % lower-limit non-central t
    uldt = nctinv(1 - alpha / 2, df, non_central_parameter_dz);  % upper-limit non-central t
    low_dz = lldt / sqN;
    high_dz = uldt / sqN;

    % Correction factor (Hedges, 1981, Hedges & Olkins, 1985)
    % Can also be approximated with: Jv = 1 - (3 / (4 * df - 1))
    Jv = exp(gammaln(df / 2) - (log(sqrt(df / 2)) + gammaln((df - 1) / 2)));

    hedges_gz = cohen_dz * Jv;  % Hedges' gz for unbiased estimation of the effect size

    % Fitts (2020); Goulet-Pelletier & Cousineau (2018, 2019)
    non_central_parameter_gz = hedges_gz * sqN;  % Non-central parameter
    llgt = nctinv(alpha / 2, df, non_central_parameter_gz);  % lower-limit non-central t
    ulgt = nctinv(1 - alpha / 2, df, non_central_parameter_gz);  % upper-limit non-central t
    low_gz = llgt / sqN;
    high_gz = ulgt / sqN;

    t = mean_diff / (std_diff / sqN);
    p = 1 - tcdf(abs(t), df);
    if strcmp(tail, "two-sided")
        p = p * 2;
    elseif strcmp(tail, "greater") && t < 0
        p = 1 - p;
    elseif strcmp(tail, "less") && t > 0
        p = 1 - p;
    end

    % Directed BF not implemented
    if strcmp(tail, "two-sided")
        % Compute Bayes Factor (Rouder et al., 2009)
        % Function to be integrated
        fun = @(g, t, n, r) (1 + n .* g .* r.^2).^(-.5) .* ...
            (1 + t.^2 ./ ((1 + n .* g .* r.^2) .* (n - 1))).^(-n./2) .* ...
            (2 .* pi).^(-.5) .* g.^(-3. / 2) .* exp(-1 ./ (2 .* g));
        % JZS Bayes factor calculation
        r = sqrt(2) / 2;  % JZS prior
        numerator = (1 + t^2 / df)^(-(df + 1) / 2);
        integr = integral(@(g) fun(g, t, n, r), 0, Inf);
        bf01 = numerator / integr;
        bf10 = 1 / bf01;
    else
        bf10 = NaN;
    end

    % Creating values to return
    mean_amps = [mean_x, mean_y];
    between_confidence_intervals = [between_x_ci, between_y_ci];
    within_confidence_intervals = [within_x_ci, within_y_ci];
    stats.t = t;
    stats.alpha = alpha;
    stats.n = n;
    stats.df = df;
    stats.dz = [cohen_dz, low_dz, high_dz];
    stats.gz = [hedges_gz, low_gz, high_gz];
    stats.p = p;
    stats.bf10 = bf10;
    stats.mean_diff = mean_diff;
    stats.diff_ci = diff_ci;
    if p <= alpha
        stats.reject_null = "rejected";
    else
        stats.reject_null = "not rejected";
    end
end
