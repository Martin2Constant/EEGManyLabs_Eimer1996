function [ERP_cipsi, ERP_contra, ERP_ipsi, resampled_data] = resample_data(data, ntrials_left, method)
    arguments
        data double;
        ntrials_left int16;
        method string = "permutation";
    end
    ntrials_total = size(data, 3);
    lch = 1;
    rch = 2;
    if method == "permutation"
        resampled_data = shuffle(data, 3);
    elseif method == "bootstrap"
        resampled_data = data(:, :, randi(ntrials_total, 1, ntrials_total));
    end
    ERP_contra = mean(resampled_data(rch, :, 1:ntrials_left), 3)*0.5 ...
                    + mean(resampled_data(lch,:,ntrials_left+1:end), 3)*0.5;
    ERP_ipsi = mean(resampled_data(lch, :, 1:ntrials_left), 3)*0.5 ...
                    + mean(resampled_data(rch,:,ntrials_left+1:end), 3)*0.5;
    ERP_cipsi = ERP_contra - ERP_ipsi;
end
