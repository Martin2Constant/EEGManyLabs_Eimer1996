function AMICA(participant_nr, filepath)
    % Requires the AMICA and postAMICA utility plugins from EEGLAB
    %% Initialize and load
    id = participant_nr;
    filename = sprintf('participant%i_preICA.set', id);
    post_ica = sprintf('participant%i_postICA.set', id);

    EEG = pop_loadset(filename, [filepath filesep 'EEG']);

    %% Pre-process for ICA
    EEG_forICA = EEG;
    EEG_forICA = eeg_checkset( EEG_forICA );
    % Resample to 100Hz for linearity
    EEG_forICA = pop_resample( EEG_forICA, 100);
    % Stronger high pass filter for stationarity
    %   Onepass-zerophase, order 550, blackman-windowed sinc FIR
    %   Cutoff (-6 dB) 1.5 Hz
    %   Transition width 1.0 Hz, stopband 0-1.0 Hz, passband 2.0-50 Hz
    %   Max. passband deviation 0.0002 (0.02%), stopband attenuation -74 dB
    %EEG_forICA = pop_firws(EEG_forICA, 'fcutoff', 1, 'ftype', 'highpass', 'wtype', 'hamming', 'forder', 166, 'minphase', 0, 'usefftfilt', 0, 'plotfresp', 0, 'causal', 0);
    EEG_forICA = pop_firws(EEG_forICA, 'fcutoff', 1, 'ftype', 'highpass', 'wtype', 'blackman', 'forder', 276, 'minphase', 0, 'usefftfilt', 0, 'plotfresp', 0, 'causal', 0);
    %EEG_forICA = pop_clean_rawdata(EEG_forICA, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );
    EEG_forICA = eeg_checkset( EEG_forICA );
    EEG_forICA  = pop_erplabDeleteTimeSegments( EEG_forICA , 'displayEEG', 0, 'endEventcodeBufferMS',  1000, 'ignoreUseType', 'ignore', 'startEventcodeBufferMS',...
        1000, 'timeThresholdMS',  3000 );
    EEG_forICA = eeg_checkset( EEG_forICA );

    EEG_forICA.data = double(EEG_forICA.data);
    % ICA is ran on epoched data (recommended on EEGLAB website)
    %EEG_forICA = pop_epoch( EEG_forICA, {'103'}, [-0.4 1]);
    %EEG_forICA = eeg_checkset( EEG_forICA );
    %EEG_forICA = pop_rmbase( EEG_forICA, [],[]);
    %EEG_forICA = eeg_checkset( EEG_forICA );
    dataRank = min(EEG.dataRank,sum(eig(cov(double(EEG_forICA.data'))) > 1E-6));

    %% ICA
    outAmica = sprintf('%s%sAMICA%s%i',filepath,filesep,filesep,id);
    runamica15(double(EEG_forICA.data), 'num_chans', EEG_forICA.nbchan,...
        'outdir', outAmica, 'max_threads', 16,...
        'num_models', 1, 'do_reject', 1, 'numrej', 15, 'rejsig', 3, 'rejint', 1, 'max_iter', 16000,'pcakeep',dataRank);

    %% Load ICA weights
    EEG  = pop_loadmodout(EEG, outAmica);

    EEG = eeg_checkset( EEG );
    EEG = pop_saveset(EEG, 'filename', post_ica, 'filepath', [filepath filesep 'EEG']);
end