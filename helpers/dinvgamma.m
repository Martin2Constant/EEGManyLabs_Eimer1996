function res = dinvgamma(x, shape, scale) 
    if shape <= 0 || scale <= 0 
        error("Shape or scale parameter negative in dinvgamma().\n")
    end
    alpha = shape;
    beta = scale;
    log_density = alpha .* log(beta) - gammaln(alpha) - (alpha + 1) .* log(x) - (beta./x);
    res = exp(log_density);
end