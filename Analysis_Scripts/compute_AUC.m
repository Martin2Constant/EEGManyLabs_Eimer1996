function auc = compute_AUC(amplitudes, sampling_period, sign)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    arguments
        amplitudes (1, :) double;
        sampling_period double = 1/200; % 1/sampling rate
        sign string = "neg"; % "neg" or "total" or "pos"
    end
    if sign == "neg"
        amplitudes = -amplitudes;
    elseif sign == "total"
        amplitudes = abs(amplitudes);
    end
    amplitudes(amplitudes < 0) = 0;
    
    % AUC
    auc = sampling_period*trapz(amplitudes);
end
