function [ERP_cipsi, ERP_contra, ERP_ipsi, resampled_data] = non_parametric_resample(data, ntrials_left, method, lch, rch)
    % Author: Martin Constant (martin.constant@unige.ch)
    % Make sure rng("shuffle") has been called in the script calling this function
    arguments
        data double;
        ntrials_left uint16;
        method string = "bootstrap"; % "permutation" or "bootstrap"
        lch uint16 = 1;
        rch uint16 = 2;
    end
    ntrials_total = size(data, 3);
    if method == "permutation"
        resampled_data = shuffle(data, 3); % EEGLAB's shuffle, not MATLAB's
    elseif method == "bootstrap"
        resampled_data = data(:, :, randi(ntrials_total, 1, ntrials_total));
    end
    ERP_contra = mean(resampled_data(rch, :, 1:ntrials_left), 3)*0.5 ...
        + mean(resampled_data(lch, :, ntrials_left+1:end), 3)*0.5;
    ERP_ipsi = mean(resampled_data(lch, :, 1:ntrials_left), 3)*0.5 ...
        + mean(resampled_data(rch, :, ntrials_left+1:end), 3)*0.5;
    ERP_cipsi = ERP_contra - ERP_ipsi;
end