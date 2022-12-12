function extract_results(filepath, team, pipeline, participant_list)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    files = dir(fullfile([filepath filesep team filesep 'ERP' filesep char(pipeline)], [team '_pipeline_' char(pipeline) '_participant*.erp']));
    for id = 1:length(files)
        erp_name = files(id).name;
        ERP = pop_loaderp( 'filename', erp_name, 'filepath', files(id).folder);
        ALLERP(id) = ERP;
    end
    results_path = sprintf('%s%s%s%sResults%sPipeline%s%s%s', filepath, filesep, team, filesep, filesep, filesep, pipeline, filesep);

    if pipeline == "Original" || pipeline == "ICA"
        onset = 220;
        offset = 300;
        % Extract amplitude values for each condition
        [ALLERP, letters_amp] = pop_geterpvalues( ALLERP, [onset offset],  [13 14], [ERP.PO7_8_index], 'Baseline', 'pre', 'Erpsets', 1:length(ALLERP), 'FileFormat', 'wide', 'Filename',...
            [results_path 'mean_amp_letters_N2pc.txt'], 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  9 );
        [ALLERP, colors_amp] = pop_geterpvalues( ALLERP, [onset offset],  [16 17], [ERP.PO7_8_index], 'Baseline', 'pre', 'Erpsets', 1:length(ALLERP), 'FileFormat', 'wide', 'Filename',...
            [results_path 'mean_amp_colors_N2pc.txt'], 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  9 );

    elseif pipeline == "Resample" || pipeline == "ICA+Resample"
        cfg.sign = -1; % Search in the negative polarities
        cfg.peakWidth = 4;
        % Extract 15% peak amplitude onset and offset
        cfg.extract = {'onset', 'offset'};
        cfg.percAmp = 0.15;
        cfg.times = ERP.times;
        cfg.cWinWidth = 200;
        cfg.condition = 15; % Letters
        cfg.peakWin = [100 400]; % Search for N2pc peak between 100 and 400ms
        cfg.aggregate = 'GA';
        cfg.chans = ERP.PO7_8_index;
        [res, ~] = latency(cfg, ALLERP); % Liesefeld (2018), Frontiers in Neuroscience
        onset_letters = res.onset;
        offset_letters = res.offset;
        cfg.condition = 18; % Colors
        [res, ~] = latency(cfg, ALLERP);
        onset_colors = res.onset;
        offset_colors = res.offset;

        onset = round(mean([onset_letters, onset_colors]));
        offset = round(mean([offset_letters, offset_colors]));
        [ALLERP, letters_amp] = pop_geterpvalues( ALLERP, [onset offset],  [13 14], [ERP.PO7_8_index], 'Baseline', 'pre', 'Erpsets', 1:length(ALLERP), 'FileFormat', 'wide', 'Filename',...
            [results_path 'mean_amp_letters_N2pc.txt'], 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  9 );
        [ALLERP, colors_amp] = pop_geterpvalues( ALLERP, [onset offset],  [16 17], [ERP.PO7_8_index], 'Baseline', 'pre', 'Erpsets', 1:length(ALLERP), 'FileFormat', 'wide', 'Filename',...
            [results_path 'mean_amp_colors_N2pc.txt'], 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  9 );
        create_resampled_erps(filepath, team, participant_list, pipeline, onset, offset)
    end
    letters_contra_amp = letters_amp(1,:)';
    letters_ipsi_amp = letters_amp(2,:)';
    colors_contra_amp = colors_amp(1,:)';
    colors_ipsi_amp = colors_amp(2,:)';

    % Run paired-sample t-test on amplitude values
    [mean_amps_letters, between_ci_amp_letters, within_ci_amp_letters, stats_amp_letters] = custom_paired_t_test(letters_contra_amp, letters_ipsi_amp, 0.02, "less");
    [mean_amps_colors, between_ci_amp_colors, within_ci_amp_colors, stats_amp_colors] = custom_paired_t_test(colors_contra_amp, colors_ipsi_amp, 0.02, "less");
    [mean_amps_interaction, between_ci_amp_interaction, within_ci_amp_interaction, stats_amp_interaction] = custom_paired_t_test(letters_contra_amp-letters_ipsi_amp, colors_contra_amp-colors_ipsi_amp, 0.02, "less");

    save(sprintf('%sresults_letters.mat', results_path), 'mean_amps_letters', 'between_ci_amp_letters', 'within_ci_amp_letters', 'stats_amp_letters');
    save(sprintf('%sresults_colors.mat', results_path), 'mean_amps_colors', 'between_ci_amp_colors', 'within_ci_amp_colors', 'stats_amp_colors');
    save(sprintf('%sresults_interaction.mat', results_path), 'mean_amps_interaction', 'between_ci_amp_interaction', 'within_ci_amp_interaction', 'stats_amp_interaction');

    mean_amplitudes_table = table(letters_ipsi_amp, letters_contra_amp, ...
        colors_ipsi_amp, colors_contra_amp, ...
        letters_contra_amp - letters_ipsi_amp, colors_contra_amp - colors_ipsi_amp, ...
        'VariableNames', {'Letters_ipsi', 'Letters_contra', 'Colors_ipsi', 'Colors_contra', 'Letters_Contra-Ipsi', 'Colors_Contra-Ipsi'});
    writetable(mean_amplitudes_table, sprintf('%s%s_amplitudes_table.csv', results_path, team));

    % Export GA time series data
    GA = pop_gaverager( ALLERP , 'DQ_flag', 1, 'Erpsets', 1:length(ALLERP), 'ExcludeNullBin', 'on', 'SEM', 'on' );
    time_series_table = table(GA.bindata(ERP.PO7_8_index, :, 13)', GA.bindata(ERP.PO7_8_index, :, 14)',...
        GA.bindata(ERP.PO7_8_index, :, 16)', GA.bindata(ERP.PO7_8_index, :, 17)',...
        GA.bindata(ERP.PO7_8_index, :, 15)', GA.bindata(ERP.PO7_8_index, :, 18)',...
        'VariableNames', {'Letters_ipsi', 'Letters_contra', 'Colors_ipsi', 'Colors_contra', 'Letters_Contra-Ipsi', 'Colors_Contra-Ipsi'});
    writetable(time_series_table, sprintf('%s%s_time_series_table.csv', results_path, team));

    % Write results of t-tests to console and files.
    letters_output = sprintf("For the team %s with the %s pipeline, letters distractor arrays between %i ms and %i ms with correct responses:\n" + ...
        "The mean contralateral amplitude is %.2f µV ± %.2f.\n" + ...
        "The mean ipsilateral amplitude is %.2f µV ± %.2f.\n" + ...
        "Thus, the mean contra-ipsi difference is %.2f µV ± %.2f.\n" + ...
        "One-tailed paired-sample t-test with N = %i, alpha = %.2e" + ...
        " and hypothesis: contralateral µV < ipsilateral µV.\n" + ...
        "t(%i) = %.2f, p = %.2e, dz = %.2f [%.2f, %.2f], dz s.e. = %.2f," + ...
        " gz = %.2f [%.2f, %.2f], gz s.e = %.2f.\n" + ...
        "The null hypothesis is therefore %s.\n" + ...
        "Effect sizes to convert to r (for meta-analyses):\n" + ...
        "drm = %.2f [%.2f, %.2f], drm s.e. = %.2f." + ...
        " grm = %.2f [%.2f, %.2f], grm s.e. = %.2f.\n", ...
        team, pipeline, onset, offset, mean_amps_letters(1), within_ci_amp_letters(1), ...
        mean_amps_letters(2), within_ci_amp_letters(2), ...
        stats_amp_letters.mean_diff, stats_amp_letters.diff_ci, ...
        stats_amp_letters.n, stats_amp_letters.alpha, ...
        stats_amp_letters.df, stats_amp_letters.t, stats_amp_letters.p, ...
        stats_amp_letters.dz.eff, stats_amp_letters.dz.low_ci,...
        stats_amp_letters.dz.high_ci, stats_amp_letters.dz.se, ...
        stats_amp_letters.gz.eff, stats_amp_letters.gz.low_ci,...
        stats_amp_letters.gz.high_ci, stats_amp_letters.gz.se, ...
        stats_amp_letters.reject_null, ...
        stats_amp_letters.drm.eff, stats_amp_letters.drm.low_ci,...
        stats_amp_letters.drm.high_ci, stats_amp_letters.drm.se,...
        stats_amp_letters.grm.eff, stats_amp_letters.grm.low_ci,...
        stats_amp_letters.grm.high_ci, stats_amp_letters.grm.se)

    letters_fileID = fopen(sprintf('%sletters_output.txt', results_path), 'w');
    fprintf(letters_fileID, letters_output);
    fclose(letters_fileID);

    colors_output = sprintf("For the team %s with the %s pipeline, colors distractor arrays between %i ms and %i ms with correct responses:\n" + ...
        "The mean contralateral amplitude is %.2f µV ± %.2f.\n" + ...
        "The mean ipsilateral amplitude is %.2f µV ± %.2f.\n" + ...
        "Thus, the mean contra-ipsi difference is %.2f µV ± %.2f.\n" + ...
        "One-tailed paired-sample t-test with N = %i, alpha = %.2e" + ...
        " and hypothesis: contralateral µV < ipsilateral µV.\n" + ...
        "t(%i) = %.2f, p = %.2e, dz = %.2f [%.2f, %.2f], dz s.e. = %.2f," + ...
        " gz = %.2f [%.2f, %.2f], gz s.e. = %.2f.\n" + ...
        "The null hypothesis is therefore %s.\n" + ...
        "Effect sizes to convert to r (for meta-analyses):\n" + ...
        "drm = %.2f [%.2f, %.2f], drm s.e. = %.2f." + ...
        " grm = %.2f [%.2f, %.2f], grm s.e. = %.2f.\n", ...
        team, pipeline, onset, offset, mean_amps_colors(1), between_ci_amp_colors(1), ...
        mean_amps_colors(2), between_ci_amp_colors(2),...
        stats_amp_colors.mean_diff, stats_amp_colors.diff_ci,...
        stats_amp_colors.n, stats_amp_colors.alpha,...
        stats_amp_colors.df, stats_amp_colors.t, stats_amp_colors.p,...
        stats_amp_colors.dz.eff, stats_amp_colors.dz.low_ci,...
        stats_amp_colors.dz.high_ci, stats_amp_colors.dz.se,...
        stats_amp_colors.gz.eff, stats_amp_colors.gz.low_ci,...
        stats_amp_colors.gz.high_ci, stats_amp_colors.gz.se,...
        stats_amp_colors.reject_null, ...
        stats_amp_colors.drm.eff, stats_amp_colors.drm.low_ci,...
        stats_amp_colors.drm.high_ci, stats_amp_colors.drm.se,...
        stats_amp_colors.grm.eff, stats_amp_colors.grm.low_ci,...
        stats_amp_colors.grm.high_ci, stats_amp_colors.grm.se)

    colors_fileID = fopen(sprintf('%scolors_output.txt', results_path), 'w');
    fprintf(colors_fileID, colors_output);
    fclose(colors_fileID);

    interaction_output = sprintf("For the team %s with the %s pipeline, contra-ipsi letters vs. colors distractor arrays between %i ms and %i ms with correct responses:\n" + ...
        "The mean contra-ipsi letters amplitude is %.2f µV ± %.2f.\n" + ...
        "The mean contra-ipsi colors amplitude is %.2f µV ± %.2f.\n" + ...
        "Thus, the mean difference between letters and colors is %.2f µV ± %.2f.\n" + ...
        "One-tailed paired-sample t-test with N = %i, alpha = %.2e" + ...
        " and hypothesis: letters µV < colors µV.\n" + ...
        "t(%i) = %.2f, p = %.2e, dz = %.2f [%.2f, %.2f], dz s.e. = %.2f," + ...
        " gz = %.2f [%.2f, %.2f], gz s.e. = %.2f.\n" + ...
        "The null hypothesis is therefore %s.\n" + ...
        "Effect sizes to convert to r (for meta-analyses):\n" + ...
        "drm = %.2f [%.2f, %.2f], drm s.e. = %.2f." + ...
        " grm = %.2f [%.2f, %.2f], grm s.e. = %.2f.\n", ...
        team, pipeline, onset, offset, mean_amps_interaction(1), between_ci_amp_interaction(1), ...
        mean_amps_interaction(2), between_ci_amp_interaction(2),...
        stats_amp_interaction.mean_diff, stats_amp_interaction.diff_ci,...
        stats_amp_interaction.n, stats_amp_interaction.alpha,...
        stats_amp_interaction.df, stats_amp_interaction.t, stats_amp_interaction.p,...
        stats_amp_interaction.dz.eff, stats_amp_interaction.dz.low_ci,...
        stats_amp_interaction.dz.high_ci, stats_amp_interaction.dz.se,...
        stats_amp_interaction.gz.eff, stats_amp_interaction.gz.low_ci,...
        stats_amp_interaction.gz.high_ci, stats_amp_interaction.gz.se,...
        stats_amp_interaction.reject_null, ...
        stats_amp_interaction.drm.eff, stats_amp_interaction.drm.low_ci,...
        stats_amp_interaction.drm.high_ci, stats_amp_interaction.drm.se,...
        stats_amp_interaction.grm.eff, stats_amp_interaction.grm.low_ci,...
        stats_amp_interaction.grm.high_ci, stats_amp_interaction.grm.se)

    interaction_fileID = fopen(sprintf('%sinteraction_output.txt', results_path), 'w');
    fprintf(interaction_fileID, interaction_output);
    fclose(interaction_fileID);
end
