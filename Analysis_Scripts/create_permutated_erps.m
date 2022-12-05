function [pval_letters, pval_colors] = create_permutated_erps(filepath, team, participant_list)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    rng("shuffle"); % Make sure we don't use MATLAB default's rng behavior

    % Initialize everything
    alpha = .02;
    print_results = true;
    n_permutations = 10000; % Each takes ~0.5 sec on the server
    n_meta = 10000; % 10000 * 0.5sec = 1h23
    time_window = [220; 300]; % In milliseconds
    permuted_letters = zeros(1, n_permutations, 'double');
    permuted_colors = zeros(1, n_permutations, 'double');
    permuted_t_diff = zeros(1, n_permutations, 'double');
    pval_letters = zeros(1, n_meta, 'double');
    pval_colors = zeros(1, n_meta, 'double');
    pval_difference = zeros(1, n_meta, 'double');
    lch = 1; % left chan index
    rch = 2; % right chan index
    bins_letters_left = [1 4];
    bins_letters_right = [2 5];
    bins_colors_left = [7 10];
    bins_colors_right = [8 11];

    % Load 1st dataset to extract sampling rate and time indices
    id = participant_list(1);
    epoched = sprintf('%s_participant%i_epoched_small.set', team, id);
    EEG = pop_loadset(epoched, [filepath filesep team filesep 'EEG']);
    time_idx = dsearchn(EEG.times', time_window)';
    Ts = 1 / EEG.srate;
    observed_letters_cipsi = zeros(length(participant_list), length(time_idx(1):time_idx(2)), 'double');
    observed_colors_cipsi = zeros(length(participant_list), length(time_idx(1):time_idx(2)), 'double');

    % Load each dataset and split hemifield and condition
    for id = participant_list
        epoched = sprintf('%s_participant%i_epoched_small.set', team, id);
        EEG = pop_loadset(epoched, [filepath filesep team filesep 'EEG']);
        
        % Only letters presented in left hemifield
        EEG_letters_left = pop_selectevent( EEG, ...
            'bini', bins_letters_left, ...
            'deleteevents','off', ...
            'deleteepochs','on', ...
            'invertepochs','off');
        % Only letters presented in right hemifield  
        EEG_letters_right = pop_selectevent( EEG, ...
            'bini', bins_letters_right, ...
            'deleteevents','off', ...
            'deleteepochs','on', ...
            'invertepochs','off');
        
        all_eegs_letters(id).dat = cat(3, EEG_letters_left.data, EEG_letters_right.data); %#ok<*AGROW>
        n_letters_left(id) = size(EEG_letters_left.data, 3);
        % Because we concatenate [left_cond; right_cond]
        % 1:n_letters_left = left condition
        % n_letters_left(id)+1:end = right condition
        
        % Only colored squares presented in left hemifield
        EEG_colors_left = pop_selectevent( EEG, ...
            'bini', bins_colors_left, ...
            'deleteevents','off', ...
            'deleteepochs','on', ...
            'invertepochs','off');
        % Only colored squares presented in right hemifield
        EEG_colors_right = pop_selectevent( EEG, ...
            'bini', bins_colors_right, ...
            'deleteevents','off', ...
            'deleteepochs','on', ...
            'invertepochs','off');
        n_colors_left(id) = size(EEG_colors_left.data, 3);
        all_eegs_colors(id).dat = cat(3, EEG_colors_left.data, EEG_colors_right.data);

        % Get original (observed) contra/ipsi ERPs
        % Contra = (right chan for left condition + left chan for right condition) / 2
        % Ipsi = (left chan for left condition + right chan for right condition) / 2
        ERP_letters_contra = mean(all_eegs_letters(id).dat(rch, time_idx(1):time_idx(2), 1:n_letters_left(id)), 3) * 0.5 ...
            + mean(all_eegs_letters(id).dat(lch, time_idx(1):time_idx(2), n_letters_left(id)+1:end), 3) * 0.5;
        ERP_letters_ipsi = mean(all_eegs_letters(id).dat(lch, time_idx(1):time_idx(2), 1:n_letters_left(id)), 3) * 0.5 ...
            + mean(all_eegs_letters(id).dat(rch, time_idx(1):time_idx(2), n_letters_left(id)+1:end), 3) * 0.5;

        ERP_colors_contra = mean(all_eegs_colors(id).dat(rch, time_idx(1):time_idx(2), 1:n_colors_left(id)), 3) * 0.5 ...
            + mean(all_eegs_colors(id).dat(lch, time_idx(1):time_idx(2), n_colors_left(id)+1:end), 3) * 0.5;
        ERP_colors_ipsi = mean(all_eegs_colors(id).dat(lch, time_idx(1):time_idx(2), 1:n_colors_left(id)), 3) * 0.5 ...
            + mean(all_eegs_colors(id).dat(rch, time_idx(1):time_idx(2), n_colors_left(id)+1:end), 3) * 0.5;

        observed_letters_cipsi(id, :) = ERP_letters_contra - ERP_letters_ipsi;
        observed_colors_cipsi(id, :) = ERP_colors_contra - ERP_colors_ipsi;
    end

    observed_cond_diff_cipsi = observed_letters_cipsi - observed_colors_cipsi;
    % Compute observed test statistic
    GA_letters = mean(observed_letters_cipsi, 1);
    GA_colors = mean(observed_colors_cipsi, 1);
    observed_AUC_letters = compute_AUC(GA_letters, Ts, "neg");
    observed_AUC_colors = compute_AUC(GA_colors, Ts, "neg");
    observed_t_diff = compute_t(observed_cond_diff_cipsi);

    % Start meta-permutations (level 2 analysis), we do the permutations
    % many times to extract the median permutation test-statistic.
    for meta = 1:n_meta
        fprintf("\nStarting permutations: %i\n", meta)
        % Start parallel loop permutations
        tic
        parfor perm = 1:n_permutations
            permuted_letters_cipsi = zeros(length(participant_list), length(time_idx(1):time_idx(2)), 'double');
            permuted_colors_cipsi = zeros(length(participant_list), length(time_idx(1):time_idx(2)), 'double');
            % For each participant, we shuffle left and right channels
            % in each condition. Then we create the permuted contra/ipsi
            % erps and get the difference.
            for id = participant_list
                shuffled_EEG_letters = shuffle(all_eegs_letters(id).dat, 3); %#ok<*PFBNS>
                shuffled_EEG_colors = shuffle(all_eegs_colors(id).dat, 3);

                ERP_letters_contra = mean(shuffled_EEG_letters(rch, time_idx(1):time_idx(2), 1:n_letters_left(id)), 3)*0.5 ...
                    + mean(shuffled_EEG_letters(lch,time_idx(1):time_idx(2),n_letters_left(id)+1:end), 3)*0.5;
                ERP_letters_ipsi = mean(shuffled_EEG_letters(lch, time_idx(1):time_idx(2), 1:n_letters_left(id)), 3)*0.5 ...
                    + mean(shuffled_EEG_letters(rch,time_idx(1):time_idx(2),n_letters_left(id)+1:end), 3)*0.5;

                ERP_colors_contra = mean(shuffled_EEG_colors(rch, time_idx(1):time_idx(2), 1:n_colors_left(id)), 3)*0.5 ...
                    + mean(shuffled_EEG_colors(lch,time_idx(1):time_idx(2),n_colors_left(id)+1:end), 3)*0.5;
                ERP_colors_ipsi = mean(shuffled_EEG_colors(lch, time_idx(1):time_idx(2), 1:n_colors_left(id)), 3)*0.5 ...
                    + mean(shuffled_EEG_colors(rch,time_idx(1):time_idx(2),n_colors_left(id)+1:end), 3)*0.5;


                permuted_letters_cipsi(id, :) = ERP_letters_contra - ERP_letters_ipsi;
                permuted_colors_cipsi(id, :) = ERP_colors_contra - ERP_colors_ipsi;
            end

            % Get grand average of the current permuted contra-ipsi waves.
            GA_letters = mean(permuted_letters_cipsi, 1);
            GA_colors = mean(permuted_colors_cipsi, 1);

            % Compute AUC and t
            permuted_letters(perm) = compute_AUC(GA_letters, Ts, "neg");
            permuted_colors(perm) = compute_AUC(GA_colors, Ts, "neg");
            permuted_t_diff(perm) = compute_t(permuted_letters_cipsi, permuted_colors_cipsi);
        end
        toc
        % Get the p-value for the current meta-permutation
        pval_letters(meta) = (sum(permuted_letters >= observed_AUC_letters) / n_permutations);
        pval_colors(meta) = (sum(permuted_colors >= observed_AUC_colors) / n_permutations);
        pval_difference(meta) = (sum(permuted_t_diff >= observed_t_diff) / n_permutations);
    end
    save("pvalues.mat", "pval_letters", "pval_colors", "pval_difference");
    save("last_perm.mat","permuted_letters","permuted_colors","permuted_t_diff");
    if print_results
        if median(pval_letters) < alpha
            fprintf("\nWe reject the null for the letters condition\n")
        else
            fprintf("\nWe don't reject the null for the letters condition\n")
        end
        if median(pval_colors) < alpha
            fprintf("\nWe reject the null for the colors condition\n")
        else
            fprintf("\nWe don't reject the null for the colors condition\n")
        end
        if median(pval_difference) < alpha
            fprintf("\nWe reject the null for the difference between conditions\n")
        else
            fprintf("\nWe don't reject the null for the difference between conditions\n")
        end

        sorted_t = sort(permuted_t_diff);
        sorted_letters = sort(permuted_letters);
        sorted_colors = sort(permuted_colors);
        figure;
        histogram(sorted_letters)
        title(sprintf("Letters, p = %.3g", pval_letters(end)))
        xline(observed_AUC_letters)
        xline(sorted_letters(n_permutations*(1-alpha)), "r--")

        figure;
        histogram(sorted_colors)
        title(sprintf("Colors, p = %.3g", pval_colors(end)))
        xline(observed_AUC_colors)
        xline(sorted_colors(n_permutations*(1-alpha)), "r--")

        figure;
        histogram(sorted_t)
        title(sprintf("Difference, p = %.3g", pval_difference(end)))
        xline(observed_t_diff)
        xline(sorted_t(n_permutations*(1-alpha/2)), "r--")
        xline(sorted_t(n_permutations*(alpha/2)), "r--")
    end
end
