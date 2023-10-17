function res = cauchycdf(x, loc, scale)
    res = .5 + atan( (x - loc) ./ scale) / pi;
end