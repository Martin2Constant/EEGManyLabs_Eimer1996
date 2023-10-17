function res = cauchylogpdf(x, loc, scale)
    res = log(1 ./ (pi .* scale) .* (1 + ((x - loc)./scale).^2).^-1);
end