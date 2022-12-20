function erp_mean = compute_mean(amplitudes, sign)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    % If sign is "neg" or "pos", will compute the signed mean.
    % If sign is "rectified", will compute the mean of the absolute amplitudes
    % If sign is "total", just computes mean.
    arguments
        amplitudes (1, :) double;
        sign string {mustBeMember(sign,["neg","pos","rectified", "total"])} = "neg";
    end
    if sign ~= "total"
        if sign == "neg"
            amplitudes = -amplitudes;
        elseif sign == "rectified"
            amplitudes = abs(amplitudes);
        end
        amplitudes(amplitudes < 0) = 0;
    end
    erp_mean = mean(amplitudes);
end
