function [pval_letters, pval_colors, pval_difference] = non_parametric_tests(filepath, team, participant_list, pipeline, onset, offset)
    % Author: Martin Constant (martin.constant@unige.ch)
    rng("shuffle"); % Make sure we don't use MATLAB default's rng seed
    close all
    % Initialize everything
    results_path = sprintf('%s%s%s%sResults%sPipeline%s%s%s', filepath, filesep, team, filesep, filesep, filesep, pipeline, filesep);
    participants_idx = 1:numel(participant_list);

    alpha = .02;
    print_results = true;
    n_resampling = 10000;
    n_meta = 1000;
    
    time_window = [onset; offset]; % In milliseconds
    pval_letters = zeros(1, n_meta, 'double');
    pval_colors = zeros(1, n_meta, 'double');
    pval_difference = zeros(1, n_meta, 'double');
    lch = 1; % left chan index
    rch = 2; % right chan index 
    bins_letters_left = [1, 4];
    bins_letters_right = [2, 5];
    bins_colors_left = [7, 10];
    bins_colors_right = [8, 11];

    % Load 1st dataset to extract sampling rate and time indices
    id = participant_list(1);
    epoched = sprintf('%s_participant%02i_%s_epoched_small.set', team, id, pipeline);
    EEG = pop_loadset(epoched, [filepath filesep team filesep 'EEG']);
    time_idx = dsearchn(EEG.times', time_window)';
    search_window = dsearchn(EEG.times', [100 450]')';
    offset_eeg_times = EEG.times(search_window(1):search_window(2));
    offset_time_idx = dsearchn(offset_eeg_times', time_window);

    cfg.sign = -1; % Search in the negative polarities
    cfg.peakWidth = 0; % We just want the peak
    % Extract 25% peak amplitude onset and offset
    cfg.extract = {'onset', 'offset'};
    cfg.percAmp = 0.25;
    cfg.times = offset_eeg_times;
    cfg.timeFormat = 'ms';
    cfg.areaBase = 'zero';
    cfg.peakWin = [100 450]; % Search for N2pc peak between 100 and 450ms
    cfg.ampLatWin = 'peakWin'; % Search for the on/offset in the above window
    cfg.aggregate = 'individual';
    cfg.chans = 1;

    observed_letters_cipsi = zeros(numel(participant_list), numel(search_window(1):search_window(2)), 'double');
    observed_colors_cipsi = zeros(numel(participant_list), numel(search_window(1):search_window(2)), 'double');

    % Load each dataset and split hemifield and condition
    for idx = participants_idx
        id = participant_list(idx);
        epoched = sprintf('%s_participant%02i_%s_epoched_small.set', team, id, pipeline);
        EEG = pop_loadset(epoched, [filepath filesep team filesep 'EEG']);

        % Letters presented in left hemifield
        EEG_letters_left = pop_selectevent( EEG, ...
            'bini', bins_letters_left, ...
            'deleteevents', 'off', ...
            'deleteepochs', 'on', ...
            'invertepochs', 'off');
        % Letters presented in right hemifield
        EEG_letters_right = pop_selectevent( EEG, ...
            'bini', bins_letters_right, ...
            'deleteevents', 'off', ...
            'deleteepochs', 'on', ...
            'invertepochs', 'off');

        % Because we concatenate in the order [left_cond, right_cond] then
        % 1:n_letters_left = left condition
        % n_letters_left(cnt)+1:end = right condition
        all_eegs_letters(idx).dat = cat(3, EEG_letters_left.data(:, search_window(1):search_window(2), :), EEG_letters_right.data(:, search_window(1):search_window(2), :)); %#ok<*AGROW>
        all_eegs_letters(idx).ntrials_left = size(EEG_letters_left.data, 3);

        % Colored squares presented in left hemifield
        EEG_colors_left = pop_selectevent( EEG, ...
            'bini', bins_colors_left, ...
            'deleteevents', 'off', ...
            'deleteepochs', 'on', ...
            'invertepochs', 'off');
        % Colored squares presented in right hemifield
        EEG_colors_right = pop_selectevent( EEG, ...
            'bini', bins_colors_right, ...
            'deleteevents', 'off', ...
            'deleteepochs', 'on', ...
            'invertepochs', 'off');
        all_eegs_colors(idx).dat = cat(3, EEG_colors_left.data(:, search_window(1):search_window(2), :), EEG_colors_right.data(:, search_window(1):search_window(2), :));
        all_eegs_colors(idx).ntrials_left = size(EEG_colors_left.data, 3);

        % Get original (observed) contra/ipsi ERPs
        % Contra = (right chan for left condition + left chan for right condition) / 2
        % Ipsi = (left chan for left condition + right chan for right condition) / 2
        ERP_letters_contra = mean(all_eegs_letters(idx).dat(rch, :, 1:all_eegs_letters(idx).ntrials_left), 3) * 0.5 ...
            + mean(all_eegs_letters(idx).dat(lch, :, all_eegs_letters(idx).ntrials_left+1:end), 3) * 0.5;
        ERP_letters_ipsi = mean(all_eegs_letters(idx).dat(lch, :, 1:all_eegs_letters(idx).ntrials_left), 3) * 0.5 ...
            + mean(all_eegs_letters(idx).dat(rch, :, all_eegs_letters(idx).ntrials_left+1:end), 3) * 0.5;

        ERP_colors_contra = mean(all_eegs_colors(idx).dat(rch, :, 1:all_eegs_colors(idx).ntrials_left), 3) * 0.5 ...
            + mean(all_eegs_colors(idx).dat(lch, :, all_eegs_colors(idx).ntrials_left+1:end), 3) * 0.5;
        ERP_colors_ipsi = mean(all_eegs_colors(idx).dat(lch, :, 1:all_eegs_colors(idx).ntrials_left), 3) * 0.5 ...
            + mean(all_eegs_colors(idx).dat(rch, :, all_eegs_colors(idx).ntrials_left+1:end), 3) * 0.5;

        observed_letters_cipsi(idx, :) = ERP_letters_contra - ERP_letters_ipsi;
        observed_colors_cipsi(idx, :) = ERP_colors_contra - ERP_colors_ipsi;
    end

    % Compute observed signed means
    GA_letters = mean(observed_letters_cipsi, 1);
    GA_colors = mean(observed_colors_cipsi, 1);
    observed_mean_letters = compute_mean(GA_letters, "neg", offset_time_idx);
    observed_mean_colors = compute_mean(GA_colors, "neg", offset_time_idx);
    observed_cond_diff = compute_mean(GA_letters - GA_colors, "neg", offset_time_idx);
    methods = ["bootstrap"];
    
    % Start meta-resampling (level 2 analysis), we do the resampling
    % many times. This way, we can select the median p-value of these 
    % resamplings and consider it the true p-value. We can also check whether 
    % all the resampled p-values are below our significance threshold or not.
    for method = methods
        for meta = 1:n_meta
            resampled_letters = zeros(1, n_resampling, 'double');
            resampled_colors = zeros(1, n_resampling, 'double');
            resampled_cond_diff = zeros(1, n_resampling, 'double');
            fprintf("\nStarting %s: %i\n", method, meta)
            tic
            parfor samp = 1:n_resampling
                % Vectorized resampling, see non_parametric_resample()
                resampled_letters_cipsi  = arrayfun(@(eegs) non_parametric_resample(eegs.dat, eegs.ntrials_left, method), all_eegs_letters, 'UniformOutput', false);
                resampled_colors_cipsi = arrayfun(@(eegs) non_parametric_resample(eegs.dat, eegs.ntrials_left, method), all_eegs_colors, 'UniformOutput', false);
                
                % Output is cells, convert it back to matrix
                resampled_letters_cipsi = cell2mat(resampled_letters_cipsi');
                resampled_colors_cipsi = cell2mat(resampled_colors_cipsi');

                % Get grand average of the current resampled contra-ipsi waves.
                GA_letters = mean(resampled_letters_cipsi, 1);
                GA_colors = mean(resampled_colors_cipsi, 1);
                
                % Compute new time window
                [res_letters, ~] = latency_for_nonparam(GA_letters, cfg);
                [res_colors, ~] = latency_for_nonparam(GA_colors, cfg);
                onset_letters = res_letters.onset;
                offset_letters = res_letters.offset;
                onset_colors = res_colors.onset;
                offset_colors = res_colors.offset;
        
                resample_onset = round(mean([onset_letters, onset_colors]));
                resample_offset = round(mean([offset_letters, offset_colors]));
                resample_time_idx = dsearchn(offset_eeg_times', [resample_onset resample_offset]')';

                % Compute mean signed amplitudes
                resampled_letters(samp) = compute_mean(GA_letters, "neg", resample_time_idx);
                resampled_colors(samp) = compute_mean(GA_colors, "neg", resample_time_idx);
                resampled_cond_diff(samp) = compute_mean(GA_letters - GA_colors, "neg", resample_time_idx);
            end
            toc
            % Get the p-value for the current meta-resampling
            pval_letters(meta) = (sum(resampled_letters >= observed_mean_letters) / n_resampling);
            pval_colors(meta) = (sum(resampled_colors >= observed_mean_colors) / n_resampling);
            pval_difference(meta) = (sum(resampled_cond_diff >= observed_cond_diff) / n_resampling);
        end
        save(sprintf('%spvalues_%s.mat', results_path, method), "pval_letters", "pval_colors", "pval_difference");
        save(sprintf('%slast_%s.mat', results_path, method), "resampled_letters", "resampled_colors", "resampled_cond_diff");

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

            sorted_diff = sort(resampled_cond_diff);
            sorted_letters = sort(resampled_letters);
            sorted_colors = sort(resampled_colors);
            figure;
            histogram(sorted_letters)
            title(sprintf("Letters, method = %s, p = %.3g", method, pval_letters(end)))
            xline(observed_mean_letters)
            xline(sorted_letters(n_resampling*(1-alpha)), "r--")

            figure;
            histogram(sorted_colors)
            title(sprintf("Colors, method = %s, p = %.3g", method, pval_colors(end)))
            xline(observed_mean_colors)
            xline(sorted_colors(n_resampling*(1-alpha)), "r--")

            figure;
            histogram(sorted_diff)
            title(sprintf("Difference, method = %s, p = %.3g", method, pval_difference(end)))
            xline(observed_cond_diff)
            xline(sorted_diff(n_resampling*(1-alpha)), "r--")
        end
    end
end
