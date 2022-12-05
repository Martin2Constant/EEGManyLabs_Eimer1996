function auc = compute_AUC(amplitudes, Ts, sign)
    arguments
        amplitudes (1, :) double;
        Ts double = 1/200;
        sign string = "neg";
    end
    if sign == "neg"
        amplitudes = -amplitudes;
    elseif sign == "total"
        amplitudes = abs(amplitudes);
    end
    amplitudes(amplitudes < 0) = 0;
    
    % AUC
    auc = Ts*trapz(amplitudes);
end
