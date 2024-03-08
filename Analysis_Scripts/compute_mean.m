function erp_mean = compute_mean(amplitudes, sign, time_idx)
    % Author: Martin Constant (martin.constant@unige.ch)
    % If sign is "neg" or "pos", will compute the signed mean.
    % If sign is "rectified", will compute the mean of the absolute amplitudes
    % If sign is "total", just computes mean.
    arguments
        amplitudes (1, :) double;
        sign string {mustBeMember(sign,["neg","pos","rectified", "total"])} = "neg";
        time_idx double = [1:2];
    end
    amplitudes = amplitudes(time_idx(1):time_idx(2));
    if sign ~= "total"
        if sign == "neg"
            % Positive amplitudes become negative
            % Negative amplitudes become positive
            % All negative amplitudes are then set to zero (so we will only
            % use negative amplitudes since they're now positive).
            amplitudes = -amplitudes; 
        elseif sign == "rectified"
            amplitudes = abs(amplitudes);
        end
        amplitudes(amplitudes < 0) = 0;
    end
    erp_mean = mean(amplitudes);
end
