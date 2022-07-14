function AMICA(participant_nr, filepath, team)
    % Requires the AMICA and postAMICA utility plugins from EEGLAB
    % We are computing ICA weights, but at least for the pure replication,
    % this step is useless since we're not using it.
    filename = sprintf('%s_participant%i_filtered.set', team, participant_nr);
    EEG = pop_loadset(filename, [filepath filesep team filesep 'EEG']);

    %% Pre-process for ICA
    EEG_forICA = EEG;

    % Apply stronger high-pass filter (2 Hz passband edge) to help ICA
    % decomposition
    EEG_forICA = pop_eegfiltnew(EEG_forICA, 'locutoff', 2);
    EEG_forICA = eeg_checkset( EEG_forICA );

    % Remove data segments with no markers for 5 seconds or more (usually
    % breaks or CRAP data)
    EEG_forICA  = pop_erplabDeleteTimeSegments( EEG_forICA , 'afterEventcodeBufferMS',  1000, 'beforeEventcodeBufferMS',  1000, 'displayEEG', 0, 'ignoreBoundary',...
        0, 'ignoreUseType', 'ignore', 'timeThresholdMS',  5000 );

    EEG_forICA = eeg_checkset( EEG_forICA );
    % Resample to 100 Hz to speed things up
    EEG_forICA = pop_resample( EEG_forICA, 100);

    EEG_forICA = eeg_checkset( EEG_forICA );
    % Check that data rank is still okay, in case there's a discrepancy,
    % keep the lowest of the two.
    dataRank = min(EEG_forICA.dataRank, sum(eig(cov(double(EEG_forICA.data'))) > 1E-6));
    %% ICA
    outAmica = sprintf('%s%sAMICA%s%i',filepath,filesep,filesep,id);
    runamica15(double(EEG_forICA.data), 'num_chans', EEG_forICA.nbchan,...
        'outdir', outAmica, 'max_threads', 16, 'num_models', 1, ...
        'do_reject', 1, 'numrej', 15, 'rejsig', 3, 'rejint', 1, ...
        'max_iter', 16000, 'pcakeep', dataRank);

    %% Load ICA weights
    EEG  = pop_loadmodout(EEG, outAmica);

    EEG = eeg_checkset( EEG );
    EEG = pop_saveset(EEG, 'filename', filename, 'filepath', [filepath filesep team filesep 'EEG']);
end
