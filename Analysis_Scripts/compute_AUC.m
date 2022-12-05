function auc = compute_AUC(amplitudes, Ts, sign)
        if sign == "neg"
            amplitudes = -amplitudes;
        end
        amplitudes(amplitudes < 0) = 0;
        
        % AUC
        auc = Ts*trapz(amplitudes); 
end
