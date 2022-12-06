function AMICA(participant_nr, filepath, team, force_amica)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    % Requires the AMICA plugin from EEGLAB
    out_amica = sprintf('%s%s%s%sAMICA%s%i', filepath, filesep, team, filesep, filesep, participant_nr);

    % AMICA takes a long time to run, so if it already exists, we don't run
    % it again unless force_amica is true
    if ~exist(out_amica, 'dir') || force_amica
        rng("shuffle");
        filename = sprintf('%s_participant%i_filtered.set', team, participant_nr);
        EEG = pop_loadset(filename, [filepath filesep team filesep 'EEG']);

        %% Pre-process for ICA
        % Apply stronger high-pass filter (2 Hz passband edge) to help ICA
        % decomposition
        EEG = pop_eegfiltnew(EEG, 'locutoff', 2);
        EEG = eeg_checkset( EEG );

        % Remove data segments with no markers for 5 seconds or more (usually
        % breaks or CRAP data)
        EEG  = pop_erplabDeleteTimeSegments( EEG, ...
            'afterEventcodeBufferMS',  1000, ...
            'beforeEventcodeBufferMS',  1000, ...
            'displayEEG', 0, ...
            'ignoreBoundary', 0, ...
            'ignoreUseType', 'ignore', ...
            'timeThresholdMS',  5000 );

        EEG = eeg_checkset( EEG );

        % Resample to 100 Hz to speed things up
        % This apparently also improves stationarity
        EEG = pop_resample( EEG, 100);
        EEG = eeg_checkset( EEG );

        % Check data rank
        dataRank = sum(eig(cov(double(EEG.data'))) > 1E-6);
        % Call AMICA and save output to ./team/AMICA/participant_nr
        runamica15(double(EEG.data), 'num_chans', EEG.nbchan,...
            'outdir', out_amica, 'max_threads', 16, 'num_models', 1, ...
            'do_reject', 1, 'numrej', 15, 'rejsig', 3, 'rejint', 1, ...
            'max_iter', 512, 'pcakeep', dataRank);
    end
end
