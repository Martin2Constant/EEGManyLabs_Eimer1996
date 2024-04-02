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
        ERP_contra = mean(resampled_data(rch, :, 1:ntrials_left), 3)*0.5 ...
            + mean(resampled_data(lch,:,ntrials_left+1:end), 3)*0.5;
        ERP_ipsi = mean(resampled_data(lch, :, 1:ntrials_left), 3)*0.5 ...
            + mean(resampled_data(rch,:,ntrials_left+1:end), 3)*0.5;
    elseif method == "bootstrap"
        % Experiment had 792 trials overall. Half of these were in each
        % condition and within each condition 4 out of 6 trials had the target
        % lateralized on one side only. We bootstrap as many trials as if
        % no trials was rejected.
        ntrials_bootstrapped = 792 / 2 * (4/6);
        % We assign the first half of these trials as left channel
        ntrials_left = ntrials_bootstrapped / 2;
        resampled_data = data(:, :, randi(ntrials_total, 1, ntrials_bootstrapped));
        ERP_contra = mean(resampled_data(rch, :, 1:ntrials_left), 3)*0.5 ...
            + mean(resampled_data(lch,:,ntrials_left+1:end), 3)*0.5;
        ERP_ipsi = mean(resampled_data(lch, :, 1:ntrials_left), 3)*0.5 ...
            + mean(resampled_data(rch,:,ntrials_left+1:end), 3)*0.5;
    end
    ERP_cipsi = ERP_contra - ERP_ipsi;
end
