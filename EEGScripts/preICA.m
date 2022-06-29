function preICA(participant_nr, filepath, team)
    %% Initialize and load
    ALLEEG = [];
    id = participant_nr;
    % Create filenames
    filename = sprintf('participant%i_RT.set', id);
    savename = sprintf('participant%i_preICA.set', id);
    EEG = pop_loadset(filename, [filepath filesep 'EEG']);
    switch team
        case 'Liesefeld'
            % Change electrode names and load BESA locations
            EEG = pop_chanedit(EEG, 'changefield', {5,'labels','LO1'}, 'changefield',{27,'labels','LO2'}, 'changefield',{64,'labels','IO2'},'append',64,'changefield',{65,'labels','FCz'},'lookup','standard-10-5-cap385.elp');
            EEG = pop_chanedit(EEG, 'convert',{'cart2all'});
            EEG = pop_chanedit(EEG, 'eval','chans = pop_chancenter( chans, [],[]);');
            EEG = pop_chanedit(EEG, 'convert',{'cart2all'});

            % Rereference to average of mastoids and add previous Ref (FCz) as a data channel
            EEG = pop_reref( EEG, {'A1' 'A2'} ,'refloc',struct('labels',{'FCz'},'type',{'EEG'},'theta',{0},'radius',{0.12662},'X',{32.9279},'Y',{0},'Z',{78.363},'sph_theta',{0},'sph_phi',{67.208},'sph_radius',{85},'urchan',{65},'ref',{''},'datachan',{0}));

        case 'Asanowicz'
            % Change electrode names and load BESA locations
            EEG = pop_chanedit(EEG, 'changefield', {65,'labels','SO2'}, 'changefield', {66,'labels','IO2'}, 'changefield', {67,'labels','LO1'}, 'changefield', {68,'labels','LO2'}, 'changefield', {71,'labels','A1'}, 'changefield',{72,'labels','A2'},'lookup','standard-10-5-cap385.elp');
            EEG = pop_chanedit(EEG, 'convert',{'cart2all'});
            EEG = pop_chanedit(EEG, 'eval','chans = pop_chancenter( chans, [],[]);');
            EEG = pop_chanedit(EEG, 'convert',{'cart2all'});

            % Remove unused electrodes
            EEG = pop_select( EEG, 'nochannel',{'EXG5','EXG6'});
            % Rereference to average of mastoids, no ref to add back on Biosemi
            EEG = pop_reref( EEG, {'A1' 'A2'} );
    end
    
    % Filters
    % "The amplifier bandpass was, 0.10-40 Hz."
    %% High-pass filter
    %       Onepass-zerophase, order 33000, hamming-windowed sinc FIR
    %       Cutoff (-6 dB) 0.05 Hz
    %       Transition width 0.1 Hz, stopband 0-0.0 Hz, passband 0.1-500 Hz
    %       Max. passband deviation 0.0022 (0.22%), stopband attenuation -53 dB
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, 'locutoff', 0.1);

    %% Low-pass filter (specifications given for 1000 Hz)
    %       Lowpass filtering data: onepass-zerophase, order 330, hamming-windowed sinc FIR
    %       Cutoff (-6 dB) 45 Hz
    %       Transition width 10.0 Hz, passband 0-40.0 Hz, stopband 50.0-500 Hz
    %       Max. passband deviation 0.0022 (0.22%), stopband attenuation -53 dB
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, 'hicutoff', 40);
    
    % Resample to 200 Hz
    % "EEG and EOG were sampled with a digitization rate of 200 Hz."
    EEG = eeg_checkset( EEG );
    EEG = pop_resample( EEG, 200);

    % ICA needs independent sources. We check that the data rank is equal to
    % the number of channels. Only relevant if ICA is done.
    EEG.dataRank = sum(eig(cov(double(EEG.data'))) > 1E-6);

    % Convert our markers to ERPLAB-compatible format
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );

    % Save the file.
    EEG = eeg_checkset( EEG );

    EEG = pop_saveset(EEG, 'filename', savename, 'filepath', [filepath filesep 'EEG']);
end
