function filter_and_downsample(participant_nr, filepath, team, pipeline)
    % Author: Martin Constant (martin.constant@unige.ch)
    filename = sprintf('%s_participant%02i_harmonized.set', team, participant_nr);
    savename = sprintf('%s_participant%02i_%s_filtered.set', team, participant_nr, pipeline);
    EEG = pop_loadset(filename, [filepath filesep team filesep 'EEG']);
    switch team
        case 'Munich'
            % Check for flat M1, M2, PO7 or PO8.
            % Throws an error if any are flat.
            % Deviates from original study.
            check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

            % Rereference to average of mastoids and add previous Ref (FCz) as a data channel
            % Deviates from original study.
            ref_index = find(strcmpi({EEG.chaninfo.nodatchans(:).labels}', EEG.chanlocs(1).ref));
            ref = EEG.chaninfo.nodatchans(ref_index);
            EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {ref.labels}, 'type', {ref.type}, 'theta', {ref.theta}, 'radius', {ref.radius}, 'X', {ref.X}, 'Y', {ref.Y}, 'Z', {ref.Z}, 'sph_theta', {ref.sph_theta}, 'sph_phi', {ref.sph_phi}, 'sph_radius', {ref.sph_radius}, 'urchan', {ref.urchan}, 'ref', {ref.ref}, 'datachan', {0}));
            EEG.VEOG_side = "right";

        case 'Krakow'
            % Check for flat M1, M2, PO7 or PO8.
            % Throws an error if any are flat.
            % Deviates from original study.
            check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

            % Rereference to average of mastoids, no ref to add back on Biosemi
            % Deviates from original study.
            EEG = pop_reref( EEG, {'M1' 'M2'} );
            EEG.VEOG_side = "right";

        case 'Essex'
            % Check for flat M2, PO7 or PO8.
            % M1 is online reference.
            % Throws an error if any are flat.
            % Deviates from original study
            check_flat_channels(EEG, {'PO7', 'PO8', 'M2'}, participant_nr);

            % Temporary rereference to CZ, so that we can rereference to average mastoids.
            ref_index = find(strcmpi({EEG.chaninfo.nodatchans(:).labels}', EEG.chanlocs(1).ref));
            ref = EEG.chaninfo.nodatchans(ref_index);
            EEG = pop_reref( EEG, {'CZ'}, 'refloc', struct('labels', {ref.labels}, 'type', {ref.type}, 'theta', {ref.theta}, 'radius', {ref.radius}, 'X', {ref.X}, 'Y', {ref.Y}, 'Z', {ref.Z}, 'sph_theta', {ref.sph_theta}, 'sph_phi', {ref.sph_phi}, 'sph_radius', {ref.sph_radius}, 'urchan', {ref.urchan}, 'ref', {ref.ref}, 'datachan', {0}, 'keepref','on'));

            ref_index = find(strcmpi({EEG.chaninfo.nodatchans(:).labels}', EEG.chanlocs(1).ref));
            ref = EEG.chaninfo.nodatchans(ref_index);
            % Rereference to average of mastoids.
            % Deviates from original study.
            EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {ref.labels}, 'type', {ref.type}, 'theta', {ref.theta}, 'radius', {ref.radius}, 'X', {ref.X}, 'Y', {ref.Y}, 'Z', {ref.Z}, 'sph_theta', {ref.sph_theta}, 'sph_phi', {ref.sph_phi}, 'sph_radius', {ref.sph_radius}, 'urchan', {ref.urchan}, 'ref', {ref.ref}, 'datachan', {0}, 'keepref','on'));
            EEG.VEOG_side = "right";

        case 'Gent'
            % Check for flat M1, M2, PO7 or PO8.
            % Throws an error if any are flat.
            % Deviates from original study.
            check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

            % Rereference to average of mastoids, no ref to add back on Biosemi
            % Deviates from original study.
            EEG = pop_reref( EEG, {'M1' 'M2'} );
            EEG.VEOG_side = "left";

        case 'ONERA'
            % Check for flat M1, M2, PO7 or PO8.
            % Throws an error if any are flat.
            % Deviates from original study.
            check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

            % Rereference to average of mastoids and add previous Ref (FCz) as a data channel
            % Deviates from original study.
            ref_index = find(strcmpi({EEG.chaninfo.nodatchans(:).labels}', EEG.chanlocs(1).ref));
            ref = EEG.chaninfo.nodatchans(ref_index);
            EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {ref.labels}, 'type', {ref.type}, 'theta', {ref.theta}, 'radius', {ref.radius}, 'X', {ref.X}, 'Y', {ref.Y}, 'Z', {ref.Z}, 'sph_theta', {ref.sph_theta}, 'sph_phi', {ref.sph_phi}, 'sph_radius', {ref.sph_radius}, 'urchan', {ref.urchan}, 'ref', {ref.ref}, 'datachan', {0}));
            EEG.VEOG_side = "left";
        
        case 'Geneva'
            % Check for flat M1, M2, PO7 or PO8.
            % Throws an error if any are flat.
            % Deviates from original study.
            check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

            % Rereference to average of mastoids and add previous Ref (FCz) as a data channel
            % Deviates from original study.
            ref_index = find(strcmpi({EEG.chaninfo.nodatchans(:).labels}', EEG.chanlocs(1).ref));
            ref = EEG.chaninfo.nodatchans(ref_index);
            EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {ref.labels}, 'type', {ref.type}, 'theta', {ref.theta}, 'radius', {ref.radius}, 'X', {ref.X}, 'Y', {ref.Y}, 'Z', {ref.Z}, 'sph_theta', {ref.sph_theta}, 'sph_phi', {ref.sph_phi}, 'sph_radius', {ref.sph_radius}, 'urchan', {ref.urchan}, 'ref', {ref.ref}, 'datachan', {0}));
            EEG.VEOG_side = "right";
        
        case 'GroupLC'
            % Check for flat M1, M2, PO7 or PO8.
            % Throws an error if any are flat.
            % Deviates from original study.
            check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

            % Rereference to average of mastoids and add previous Ref (CPPz) as a data channel
            % Deviates from original study.
            ref_index = find(strcmpi({EEG.chaninfo.nodatchans(:).labels}', EEG.chanlocs(1).ref));
            ref = EEG.chaninfo.nodatchans(ref_index);
            EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {ref.labels}, 'type', {ref.type}, 'theta', {ref.theta}, 'radius', {ref.radius}, 'X', {ref.X}, 'Y', {ref.Y}, 'Z', {ref.Z}, 'sph_theta', {ref.sph_theta}, 'sph_phi', {ref.sph_phi}, 'sph_radius', {ref.sph_radius}, 'urchan', {ref.urchan}, 'ref', {ref.ref}, 'datachan', {0}));
            EEG.VEOG_side = "left";
        
        case 'LSU'
            % Check for flat M1, M2, PO7 or PO8.
            % Throws an error if any are flat.
            % Deviates from original study.
            check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

            % Rereference to average of mastoids, no ref to add back on Biosemi
            % Deviates from original study.
            EEG = pop_reref( EEG, {'M1' 'M2'} );
            EEG.VEOG_side = "right";
        
        case 'Magdeburg'
            % Check for flat M1, M2, PO7 or PO8.
            % Throws an error if any are flat.
            % Deviates from original study.
            check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

            % Rereference to average of mastoids, reference is nose, so we
            % don't want to add it back
            % Deviates from original study.
            EEG = pop_reref( EEG, {'M1' 'M2'} );
            EEG.VEOG_side = "left";
        
        case 'Verona'
            % Check for flat M1, M2, PO7 or PO8.
            % Throws an error if any are flat.
            % Deviates from original study.
            check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);
            
            % Rereference to average of mastoids and add previous Ref (Fz) as a data channel
            % Deviates from original study.
            ref_index = find(strcmpi({EEG.chaninfo.nodatchans(:).labels}', EEG.chanlocs(1).ref));
            ref = EEG.chaninfo.nodatchans(ref_index);
            EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {ref.labels}, 'type', {ref.type}, 'theta', {ref.theta}, 'radius', {ref.radius}, 'X', {ref.X}, 'Y', {ref.Y}, 'Z', {ref.Z}, 'sph_theta', {ref.sph_theta}, 'sph_phi', {ref.sph_phi}, 'sph_radius', {ref.sph_radius}, 'urchan', {ref.urchan}, 'ref', {ref.ref}, 'datachan', {0}));
            EEG.VEOG_side = "right";
        otherwise
            error('Team not found');
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
    EEG = eeg_checkset( EEG );

    % Try to save in MAT files in v6 format, if it doesn't work (because file is too big), save in v7.3
    % Given the resampling to 200 Hz, this should not happpen.
    EEGs = EEG;
    lastwarn('');
    pop_editoptions('option_saveversion6', 1);
    EEG = pop_saveset(EEG, 'filename', savename, 'filepath', [filepath filesep team filesep 'EEG']); %#ok<*NASGU>
    if strcmpi(lastwarn, "Variable 'EEG' was not saved. For variables larger than 2GB use MAT-file version 7.3 or later.")
        pop_editoptions('option_saveversion6', 0);
        EEG = EEGs;
        EEG = pop_saveset(EEG, 'filename', savename, 'filepath', [filepath filesep team filesep 'EEG']);
        pop_editoptions('option_saveversion6', 1);
    end
end
