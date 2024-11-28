function mean_amp = bSME_bootstrap(data, ntrials_left, lch, rch)
    % Author: Martin Constant (martin.constant@unige.ch)
    % Make sure rng("shuffle") has been called in the script calling this function
    arguments
        data double;
        ntrials_left uint16;
        lch uint16 = 1;
        rch uint16 = 2;
    end
    ntrials_total = size(data, 3);
    ntrials_right = ntrials_total - ntrials_left;

    resampled_data_left = data(:, :, randi([1, ntrials_left], 1, ntrials_left));
    resampled_data_right = data(:, :, randi([ntrials_left+1, ntrials_total], 1, ntrials_right));

    ERP_contra = mean(resampled_data_left(rch, :, :), 3)*0.5 ...
        + mean(resampled_data_right(lch, :, :), 3)*0.5;
    ERP_ipsi = mean(resampled_data_left(lch, :, :), 3)*0.5 ...
        + mean(resampled_data_right(rch, :, :), 3)*0.5;
    ERP_cipsi = ERP_contra - ERP_ipsi;
    mean_amp = mean(ERP_cipsi);
end