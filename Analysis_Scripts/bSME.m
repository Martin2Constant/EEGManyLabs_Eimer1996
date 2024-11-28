function bSME(team, pipeline, onset, offset, filepath)
    % Author: Martin Constant (martin.constant@unige.ch)
    rng("shuffle"); % Make sure we don't use MATLAB default's rng seed
    if pipeline == "Original" 
        pipeline = "Resample";
    elseif pipeline == "ICA"
        pipeline = "ICA+Resample";
    end

    files = dir(fullfile([filepath filesep team filesep 'ERP' filesep char(pipeline)], [team '_participant*_' char(pipeline) '.erp']));
    participant_list = [];
    for id = 1:length(files)
        erp_name = files(id).name;
        participant_list = [participant_list, str2double(extractBetween(erp_name, "participant", "_"))];
    end
    % Initialize everything
    participants_idx = 1:numel(participant_list);

    n_boots = 10000;
    time_window = [onset; offset]; % In milliseconds

    n_trials_forms = zeros(1, numel(participant_list), 'double');
    n_trials_colors = zeros(1, numel(participant_list), 'double');

    lch = 1; % left chan index
    rch = 2; % right chan index
    bins_forms_left = [1, 4];
    bins_forms_right = [2, 5];
    bins_colors_left = [7, 10];
    bins_colors_right = [8, 11];

    % Load 1st dataset to extract sampling rate and time indices
    id = participant_list(1);
    epoched = sprintf('%s_participant%02i_%s_epoched_small.set', team, id, pipeline);
    EEG = pop_loadset(epoched, [filepath filesep team filesep 'EEG']);
    search_window = dsearchn(EEG.times', time_window)';

    observed_forms_cipsi = zeros(numel(participant_list), numel(search_window(1):search_window(2)), 'double');
    observed_colors_cipsi = zeros(numel(participant_list), numel(search_window(1):search_window(2)), 'double');

    % Load each dataset and split hemifield and condition
    for idx = participants_idx
        id = participant_list(idx);
        epoched = sprintf('%s_participant%02i_%s_epoched_small.set', team, id, pipeline);
        EEG = pop_loadset(epoched, [filepath filesep team filesep 'EEG']);

        % Forms presented in left hemifield
        EEG_forms_left = pop_selectevent( EEG, ...
            'bini', bins_forms_left, ...
            'deleteevents', 'off', ...
            'deleteepochs', 'on', ...
            'invertepochs', 'off');
        % Forms presented in right hemifield
        EEG_forms_right = pop_selectevent( EEG, ...
            'bini', bins_forms_right, ...
            'deleteevents', 'off', ...
            'deleteepochs', 'on', ...
            'invertepochs', 'off');

        % Because we concatenate in the order [left_cond, right_cond] then
        % 1:n_forms_left = left condition
        % n_forms_left(cnt)+1:end = right condition
        all_eegs_forms(idx).dat = cat(3, EEG_forms_left.data(:, search_window(1):search_window(2), :), EEG_forms_right.data(:, search_window(1):search_window(2), :)); %#ok<*AGROW>
        all_eegs_forms(idx).ntrials_left = size(EEG_forms_left.data, 3);

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

        n_trials_forms(idx) = size(EEG_forms_left.data, 3) + size(EEG_forms_right.data, 3);
        n_trials_colors(idx) = size(EEG_colors_left.data, 3) + size(EEG_colors_right.data, 3);
        % Get original (observed) contra/ipsi ERPs
        % Contra = (right chan for left condition + left chan for right condition) / 2
        % Ipsi = (left chan for left condition + right chan for right condition) / 2
        ERP_forms_contra = mean(all_eegs_forms(idx).dat(rch, :, 1:all_eegs_forms(idx).ntrials_left), 3) * 0.5 ...
            + mean(all_eegs_forms(idx).dat(lch, :, all_eegs_forms(idx).ntrials_left+1:end), 3) * 0.5;
        ERP_forms_ipsi = mean(all_eegs_forms(idx).dat(lch, :, 1:all_eegs_forms(idx).ntrials_left), 3) * 0.5 ...
            + mean(all_eegs_forms(idx).dat(rch, :, all_eegs_forms(idx).ntrials_left+1:end), 3) * 0.5;

        ERP_colors_contra = mean(all_eegs_colors(idx).dat(rch, :, 1:all_eegs_colors(idx).ntrials_left), 3) * 0.5 ...
            + mean(all_eegs_colors(idx).dat(lch, :, all_eegs_colors(idx).ntrials_left+1:end), 3) * 0.5;
        ERP_colors_ipsi = mean(all_eegs_colors(idx).dat(lch, :, 1:all_eegs_colors(idx).ntrials_left), 3) * 0.5 ...
            + mean(all_eegs_colors(idx).dat(rch, :, all_eegs_colors(idx).ntrials_left+1:end), 3) * 0.5;

        observed_forms_cipsi(idx, :) = ERP_forms_contra - ERP_forms_ipsi;
        observed_colors_cipsi(idx, :) = ERP_colors_contra - ERP_colors_ipsi;
    end

    sd_colors = std(observed_colors_cipsi, 0, 2);
    sd_forms = std(observed_forms_cipsi, 0, 2);

    % Doesn't seem valid when compared to the bSME, still leaving it here
    % just in case.
    aSME_colors =  sd_colors ./ sqrt(n_trials_colors');
    aSME_forms = sd_forms ./ sqrt(n_trials_forms');

    % Gurland & Tripathi (1971) ; https://doi.org/ntpx
    correction_colors = (sqrt(2 ./ (n_trials_colors-1)) .* gamma(n_trials_colors/2) ./ gamma((n_trials_colors-1)/2))';
    correction_forms = (sqrt(2 ./ (n_trials_forms-1)) .* gamma(n_trials_forms/2) ./ gamma((n_trials_forms-1)/2))';
    
    % Doesn't seem valid when compared to the bSME, still leaving it here
    % just in case.
    aSME_unbiased_colors = (sd_colors ./ correction_colors) ./ sqrt(n_trials_colors');
    aSME_unbiased_forms =  (sd_forms ./ correction_forms) ./ sqrt(n_trials_forms');

    means_forms = zeros(numel(participant_list), n_boots, 'double');
    means_colors = zeros(numel(participant_list), n_boots, 'double');
    fprintf("Starting bSME bootstraps")
    tic
    parfor boot = 1:n_boots
        mean_amp_forms  = arrayfun(@(eegs) bSME_bootstrap(eegs.dat, eegs.ntrials_left), all_eegs_forms);
        mean_amp_colors = arrayfun(@(eegs) bSME_bootstrap(eegs.dat, eegs.ntrials_left), all_eegs_colors);

        means_forms(:, boot) = mean_amp_forms;
        means_colors(:, boot) = mean_amp_colors;
    end
    toc
    bSME_colors = std(means_forms, 0, 2);
    bSME_forms = std(means_colors, 0, 2);

    % Directly computing and adding RMS to the table
    bSME_colors(end+1) = rms(bSME_colors);
    bSME_forms(end+1) = rms(bSME_forms);
    
    bSME_table = table('Size', [numel(participant_list)+1, 3], ...
        'VariableNames', ["ID", "bSME_colors","bSME_forms"],...
        'VariableTypes', ["string", "double", "double"]);
    bSME_table.ID = [participant_list'; "RMS"];
    bSME_table.bSME_colors = bSME_colors;
    bSME_table.bSME_forms = bSME_forms;
    writetable(bSME_table, [filepath filesep team filesep team '_bSME_' onset '_' offset '.csv']);
end

