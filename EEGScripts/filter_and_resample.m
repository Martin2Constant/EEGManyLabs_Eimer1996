function filter_and_resample(participant_nr, filepath, team)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    filename = sprintf('%s_participant%i_RT.set', team, participant_nr);
    savename = sprintf('%s_participant%i_filtered.set', team, participant_nr);
    EEG = pop_loadset(filename, [filepath filesep team filesep 'EEG']);

    switch team
        case 'Munich'
            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'changefield', {5, 'labels', 'LO1'}, 'changefield', {10, 'labels', 'M1'}, 'changefield', {21, 'labels', 'M2'}, 'changefield', {27, 'labels', 'LO2'}, 'changefield', {64, 'labels', 'IO2'}, 'append', 64, 'changefield', {65, 'labels', 'FCz'}, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:65', 'FCz'}, 'eval', '', 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);', 'convert', {'cart2all'});

            % Check for flat mastoids. First, create a high-passed (0.5 Hz passband)
            % copy of the dataset, then remove periods with no markers for
            % more than 5 seconds, then checks whether M1 or M2 are flat
            % for more than 30 seconds.
            EEG_flat = pop_eegfiltnew(EEG, 'locutoff', 0.5, 'usefftfilt', 1);
            EEG_flat  = pop_erplabDeleteTimeSegments( EEG_flat , 'afterEventcodeBufferMS',  1000, 'beforeEventcodeBufferMS',  1000, 'displayEEG', 0, 'ignoreBoundary',...
                0, 'ignoreUseType', 'ignore', 'timeThresholdMS',  5000 );
            EEG_flat = pop_clean_rawdata(EEG_flat, 'FlatlineCriterion', 30, 'ChannelCriterion', 'off', 'LineNoiseCriterion', 'off', 'Highpass', 'off', 'BurstCriterion', 'off', 'WindowCriterion', 'off', 'BurstRejection', 'off', 'Distance', 'Euclidian', 'channels', {'M1', 'M2'});
            if EEG_flat.nbchan < 2
                error("M1 or M2 of participant %i is flat for more than 30 seconds.", participant_nr)
            end
            % Rereference to average of mastoids and add previous Ref (FCz) as a data channel
            EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {'FCz'}, 'type', {'EEG'}, 'theta', {0}, 'radius', {0.12662}, 'X', {32.9279}, 'Y', {0}, 'Z', {78.363}, 'sph_theta', {0}, 'sph_phi', {67.208}, 'sph_radius', {85}, 'urchan', {65}, 'ref', {'FCz'}, 'datachan', {0}));

        case 'Krakow'
            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG=pop_chanedit(EEG, 'lookup', 'standard-10-5-cap385.elp', 'changefield', {65, 'labels', 'SO2'}, 'changefield', {66, 'labels', 'IO2'}, 'changefield', {67, 'labels', 'LO1'}, 'changefield', {68, 'labels', 'LO2'}, 'changefield', {71, 'labels', 'M1'}, 'changefield', {72, 'labels', 'M2'}, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:72', 'POz'}, 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);');

            % Check for flat mastoids. First, create a high-passed (0.5 Hz passband)
            % copy of the dataset, then remove periods with no markers for
            % more than 5 seconds, then checks whether M1 or M2 are flat
            % for more than 30 seconds.
            EEG_flat = pop_eegfiltnew(EEG, 'locutoff', 0.5, 'usefftfilt', 1);
            EEG_flat  = pop_erplabDeleteTimeSegments( EEG_flat , 'afterEventcodeBufferMS',  1000, 'beforeEventcodeBufferMS',  1000, 'displayEEG', 0, 'ignoreBoundary',...
                0, 'ignoreUseType', 'ignore', 'timeThresholdMS',  5000 );
            EEG_flat = pop_clean_rawdata(EEG_flat, 'FlatlineCriterion', 30, 'ChannelCriterion', 'off', 'LineNoiseCriterion', 'off', 'Highpass', 'off', 'BurstCriterion', 'off', 'WindowCriterion', 'off', 'BurstRejection', 'off', 'Distance', 'Euclidian', 'channels', {'M1', 'M2'});
            if EEG_flat.nbchan < 2
                error("M1 or M2 of participant %i is flat for more than 30 seconds.", participant_nr)
            end

            % Remove unused electrodes
            EEG = pop_select( EEG, 'nochannel', {'EXG5', 'EXG6'});
            % Rereference to average of mastoids, no ref to add back on Biosemi
            EEG = pop_reref( EEG, {'M1' 'M2'} );
        case 'Essex'
            EEG = pop_select( EEG, 'nochannel', {'TRIGGER'});
            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG=pop_chanedit(EEG, 'changefield', {29, 'labels', 'LO1'}, 'changefield', {30, 'labels', 'IO2'}, 'changefield', {21, 'labels', 'M2'}, 'insert', 30, 'changefield', {30, 'labels', 'M1'}, 'lookup', 'standard-10-5-cap385.elp', 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);', 'setref', {'1:30', 'M1'});
            EEG = pop_reref( EEG, {'CZ'}, 'refloc', struct('labels', {'M1'}, 'type', {'EEG'}, 'theta', {-100.419}, 'radius', {0.74733}, 'X', {-10.9602}, 'Y', {59.6062}, 'Z', {-59.5984}, 'sph_theta', {100.419}, 'sph_phi', {-44.52}, 'sph_radius', {85}, 'urchan', {30}, 'ref', {'M1'}, 'datachan', {0}));

            % Check for flat mastoids. First, create a high-passed (0.5 Hz passband)
            % copy of the dataset, then remove periods with no markers for
            % more than 5 seconds, then checks whether M1 or M2 are flat
            % for more than 30 seconds.
            EEG_flat = pop_eegfiltnew(EEG, 'locutoff', 0.5, 'usefftfilt', 1);
            EEG_flat  = pop_erplabDeleteTimeSegments( EEG_flat , 'afterEventcodeBufferMS',  1000, 'beforeEventcodeBufferMS',  1000, 'displayEEG', 0, 'ignoreBoundary',...
                0, 'ignoreUseType', 'ignore', 'timeThresholdMS',  5000 );
            EEG_flat = pop_clean_rawdata(EEG_flat, 'FlatlineCriterion', 30, 'ChannelCriterion', 'off', 'LineNoiseCriterion', 'off', 'Highpass', 'off', 'BurstCriterion', 'off', 'WindowCriterion', 'off', 'BurstRejection', 'off', 'Distance', 'Euclidian', 'channels', {'M1', 'M2'});
            if EEG_flat.nbchan < 2
                error("M1 or M2 of participant %i is flat for more than 30 seconds.", participant_nr)
            end
            EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {'CZ'}, 'type', {'EEG'}, 'theta', {0}, 'radius', {0}, 'X', {5.2047e-15}, 'Y', {0}, 'Z', {85}, 'sph_theta', {0}, 'sph_phi', {90}, 'sph_radius', {85}, 'urchan', {13}, 'ref', {'CZ'}, 'datachan', {0}));

    end

    % Filters
    % "The amplifier bandpass was, 0.10-40 Hz."
    %% High-pass filter
    % Onepass-zerophase Hamming-windowed sinc FIR
    % Cutoff (-6 dB) 0.05 Hz
    % Transition width 0.1 Hz, stopband 0-0.0 Hz, passband 0.1 Hz - Nyquist
    % Max. passband deviation 0.0022 (0.22%), stopband attenuation -53 dB
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, 'locutoff', 0.1, 'usefftfilt', 1);

    %% Low-pass filter
    % Lowpass filtering data: onepass-zerophase Hamming-windowed sinc FIR
    % Cutoff (-6 dB) 45 Hz
    % Transition width 10.0 Hz, passband 0-40.0 Hz, stopband 50.0 Hz - Nyquist
    % Max. passband deviation 0.0022 (0.22%), stopband attenuation -53 dB
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, 'hicutoff', 40, 'usefftfilt', 0);

    % Resample to 200 Hz
    % "EEG and EOG were sampled with a digitization rate of 200 Hz."
    EEG = eeg_checkset( EEG );
    EEG = pop_resample( EEG, 200);

    % Convert our markers to ERPLAB-compatible format
    EEG = pop_creabasiceventlist( EEG, 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );

    % Save the file.
    EEG = eeg_checkset( EEG );

    EEG = pop_saveset(EEG, 'filename', savename, 'filepath', [filepath filesep team filesep 'EEG']);
end
