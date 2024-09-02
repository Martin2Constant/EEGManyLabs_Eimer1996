function [mean_amps, between_confidence_intervals, within_confidence_intervals, stats] = custom_paired_t_test(x, y, alpha, tail)
    % Author: Martin Constant (martin.constant@unige.ch)
    % Computes paired-sample t test, BayesFactor t test, (1-alpha) between- and within-participant CIs,
    % Cohen's dz and its (1-alpha) confidence intervals, Hedges' gz and its (1-alpha) confidence intervals.
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
    %       stats.dz: struct with fields -> eff, low_ci, high_ci, se
    %           Contains Cohen's dz, its confidence intervals and its standard error.
    %       stats.gz: struct with fields -> eff, low_ci, high_ci, se
    %           Contains Hedges's gz, its confidence intervals and its standard error.
    %       stats.drm: struct with fields -> eff, low_ci, high_ci, se
    %           Contains Cohen's drm, its confidence intervals and its standard error.
    %           Use in meta-analyses when converting to other effect sizes.
    %       stats.grm: struct with fields -> eff, low_ci, high_ci, se
    %           Contains Hedges's grm, its confidence intervals and its standard error.
    %           Use in meta-analyses when converting to other effect sizes.
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
    % * Lakens, D. (2013). Calculating and reporting effect sizes to facilitate cumulative science: A practical primer for t-tests and ANOVAs. Frontiers in Psychology, 4. https://doi.org/10/f96zbh
    %
    % * Morey, R. D. (2008). Confidence intervals from normalized data: A correction to Cousineau (2005). Tutorials in Quantitative Methods for psychology, 4(2), 61–64. https://doi.org/10/ggbnjg
    %
    % * Morey, R. D., & Wagenmakers, E.-J. (2014). Simple relation between Bayesian order-restricted and point-null hypothesis tests. Statistics & Probability Letters, 92, 121–124. https://doi.org/10/ggcpcq
    %
    % * Rouder, J. N., Speckman, P. L., Sun, D., Morey, R. D., & Iverson, G. (2009). Bayesian t tests for accepting and rejecting the null hypothesis. Psychonomic Bulletin & Review, 16(2), 225–237. https://doi.org/10/b3hsdp
    arguments
        x (:, 1) double;
        y (:, 1) double;
        alpha double = .02;
        tail string {mustBeMember(tail, ["two-sided", "greater", "less"])} = "two-sided";
    end
    mean_x = mean(x);
    mean_y = mean(y);
    mean_diff = mean(x - y);
    std_diff = std(x - y);
    n = length(x);
    df = n - 1;
    sqN = sqrt(n);
    r = corr2(x, y);
    if r == 1
        r = 1 - 3*eps;  % Prevents a crash when r == 1 
    end
    % Lakens (2013) Eq. 8 (should be equivalent to std_diff, thus we use that)
    std_diff_lakens = std_diff;  % sqrt(std(x)^2 + std(y)^2 - 2 * r * std(x) * std(y));
    % Lakens (2013, Eq. 9)
    correction_factor = sqrt(2 * (1 - r));

    % Computing within CIs on normalized dataset (Cousineau, 2005; Morey, 2008; Cousineau & O'Brien, 2014)
    means_participant = means([x'; y'])';
    grand_average = mean([x; y]);
    nb_cond = 2;
    correction = sqrt(nb_cond / (nb_cond - 1));

    % Cousineau & O'Brien (2014); Eq. 2 -> Ysj = Xsj - mean(Xs) + mean(X)
    norm_x = x - means_participant + grand_average;
    norm_y = y - means_participant + grand_average;

    % Cousineau & O'Brien (2014); Eq. 4 -> Zsj = correction * (Ysj - mean(Yj)) + mean(Yj)
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
    % Fitts (2020); Eq. 7
    % Can also be approximated with: Jv = 1 - (3 / (4 * df - 1))
    Jv = exp(gammaln(df / 2) - (log(sqrt(df / 2)) + gammaln((df - 1) / 2)));
    
    % Fitts (2020); Eq. 8a
    hedges_gz = cohen_dz .* Jv;  % Hedges' gz for unbiased estimation of the effect size

    % Fitts (2020); Goulet-Pelletier & Cousineau (2018, 2019)
    non_central_parameter_gz = hedges_gz .* sqN;  % Non-central parameter
    llgt = nctinv(alpha / 2, df, non_central_parameter_gz);  % lower-limit non-central t
    ulgt = nctinv(1 - alpha / 2, df, non_central_parameter_gz);  % upper-limit non-central t
    low_gz = llgt / sqN;
    high_gz = ulgt / sqN;
    
    % Fitts (2020); Eq. 5
    dz_var = (1/n) .* (df / (df-2)) .* (1 + n .* cohen_dz.^2) - (cohen_dz.^2) / (Jv.^2);

    % Fitts (2020); Eq. 8b
    gz_var = dz_var .* Jv.^2;
    
    cohen_drm = (mean_diff / std_diff_lakens) * correction_factor;
    hedges_grm = cohen_drm * Jv;
    
    % Fitts (2020); Goulet-Pelletier & Cousineau (2018, 2019)
    non_central_parameter_drm = cohen_drm * sqN;  % Non-central parameter
    lldt = nctinv(alpha / 2, df, non_central_parameter_drm);  % lower-limit non-central t
    uldt = nctinv(1 - alpha / 2, df, non_central_parameter_drm);  % upper-limit non-central t
    low_drm = lldt / sqN;
    high_drm = uldt / sqN;

    drm_var = (1/n) * (df / (df-2)) * (1 + n * cohen_drm^2) - (cohen_drm^2) / (Jv^2);

    % Fitts (2020); Goulet-Pelletier & Cousineau (2018, 2019)
    non_central_parameter_grm = hedges_grm * sqN;  % Non-central parameter
    lldt = nctinv(alpha / 2, df, non_central_parameter_grm);  % lower-limit non-central t
    uldt = nctinv(1 - alpha / 2, df, non_central_parameter_grm);  % upper-limit non-central t
    low_grm = lldt / sqN;
    high_grm = uldt / sqN;
    grm_var = drm_var * Jv^2;

    t = mean_diff / (std_diff / sqN);
    p = 1 - tcdf(abs(t), df);
    if tail == "two-sided"
        p = p * 2;
    elseif tail == "greater" && t < 0
        p = 1 - p;
    elseif tail == "less" && t > 0
        p = 1 - p;
    end
    
    bf10 = paired_bf_ttest(t, n, tail, sqrt(2)/2);
    bf_wide = paired_bf_ttest(t, n, tail, 1);
    bf_ultrawide = paired_bf_ttest(t, n, tail, sqrt(2));

    % Creating values to return
    mean_amps = [mean_x, mean_y];
    between_confidence_intervals = [between_x_ci, between_y_ci];
    within_confidence_intervals = [within_x_ci, within_y_ci];
    stats.t = t;
    stats.alpha = alpha;
    stats.n = n;
    stats.df = df;
    stats.dz = struct("eff", cohen_dz, "low_ci", low_dz, "high_ci", high_dz, "se", sqrt(dz_var));
    stats.gz = struct("eff", hedges_gz, "low_ci", low_gz, "high_ci", high_gz, "se", sqrt(gz_var));
    stats.drm = struct("eff", cohen_drm, "low_ci", low_drm, "high_ci", high_drm, "se", sqrt(drm_var));
    stats.grm = struct("eff", hedges_grm, "low_ci", low_grm, "high_ci", high_grm, "se", sqrt(grm_var));
    stats.p = p;
    stats.bf10 = bf10;
    stats.bf_wide = bf_wide;
    stats.bf_ultrawide = bf_ultrawide;
    stats.mean_diff = mean_diff;
    stats.diff_ci = diff_ci;
    if p <= alpha
        stats.reject_null = "rejected";
    else
        stats.reject_null = "not rejected";
    end
end
