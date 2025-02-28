function filter_and_downsample(participant_nr, filepath, team)
    % Author: Martin Constant (martin.constant@unige.ch)
    filename = sprintf('%s_participant%02i_harmonized.set', team, participant_nr);
    savename = sprintf('%s_participant%02i_filtered.set', team, participant_nr);
    if ~exist([filepath filesep team filesep 'EEG' filesep savename], 'file')
        EEG = pop_loadset(filename, [filepath filesep team filesep 'EEG']);
        %% Check flat channels and re-reference
        switch team
            case 'Krakow'
                % Temporary reference to POz for checking flat electrodes
                EEG = pop_reref( EEG, {'POz'} );

                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids, no ref to add back on Biosemi
                % Deviates from original study.
                EEG = pop_reref( EEG, {'M1' 'M2'} );

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

            case 'Gent'
                % Temporary reference to POz for checking flat electrodes
                EEG = pop_reref( EEG, {'POz'} );

                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids, no ref to add back on Biosemi
                % Deviates from original study.
                EEG = pop_reref( EEG, {'M1' 'M2'} );

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

            case 'GenevaKerzel'
                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids and add previous Ref (FCz) as a data channel
                % Deviates from original study.
                ref_index = find(strcmpi({EEG.chaninfo.nodatchans(:).labels}', EEG.chanlocs(1).ref));
                ref = EEG.chaninfo.nodatchans(ref_index);
                EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {ref.labels}, 'type', {ref.type}, 'theta', {ref.theta}, 'radius', {ref.radius}, 'X', {ref.X}, 'Y', {ref.Y}, 'Z', {ref.Z}, 'sph_theta', {ref.sph_theta}, 'sph_phi', {ref.sph_phi}, 'sph_radius', {ref.sph_radius}, 'urchan', {ref.urchan}, 'ref', {ref.ref}, 'datachan', {0}));

            case 'ZJU'
                % Temporary reference to POz for checking flat electrodes
                EEG = pop_reref( EEG, {'POz'} );

                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids, no ref to add back on Biosemi
                % Deviates from original study.
                EEG = pop_reref( EEG, {'M1' 'M2'} );

            case 'LSU'
                % Temporary reference to POz for checking flat electrodes
                EEG = pop_reref( EEG, {'POz'} );

                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids, no ref to add back on Biosemi
                % Deviates from original study.
                EEG = pop_reref( EEG, {'M1' 'M2'} );

            case 'Magdeburg'
                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids, reference is nose, so we
                % don't want to add it back
                % Deviates from original study.
                EEG = pop_reref( EEG, {'M1' 'M2'} );

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

            case 'KHas'
                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids and add previous Ref (Cz) as a data channel
                % Deviates from original study.
                ref_index = find(strcmpi({EEG.chaninfo.nodatchans(:).labels}', EEG.chanlocs(1).ref));
                ref = EEG.chaninfo.nodatchans(ref_index);
                EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {ref.labels}, 'type', {ref.type}, 'theta', {ref.theta}, 'radius', {ref.radius}, 'X', {ref.X}, 'Y', {ref.Y}, 'Z', {ref.Z}, 'sph_theta', {ref.sph_theta}, 'sph_phi', {ref.sph_phi}, 'sph_radius', {ref.sph_radius}, 'urchan', {ref.urchan}, 'ref', {ref.ref}, 'datachan', {0}));

            case 'TrierKamp'
                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids and add previous Ref (Cz) as a data channel
                % Deviates from original study.
                ref_index = find(strcmpi({EEG.chaninfo.nodatchans(:).labels}', EEG.chanlocs(1).ref));
                ref = EEG.chaninfo.nodatchans(ref_index);
                EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {ref.labels}, 'type', {ref.type}, 'theta', {ref.theta}, 'radius', {ref.radius}, 'X', {ref.X}, 'Y', {ref.Y}, 'Z', {ref.Z}, 'sph_theta', {ref.sph_theta}, 'sph_phi', {ref.sph_phi}, 'sph_radius', {ref.sph_radius}, 'urchan', {ref.urchan}, 'ref', {ref.ref}, 'datachan', {0}));

            case 'UniversityofVienna'
                % Temporary reference to POz for checking flat electrodes
                EEG = pop_reref( EEG, {'POz'} );

                if ~ismember(participant_nr, [13, 14, 15])
                    % Remove electrodes which don't have a 10-20 equivalent (based on BioSemi's documentation)
                    EEG = pop_select( EEG, 'nochannel', [2:2:8 9 11:14 16:2:26 27:2:37 38 40 41 44 47:2:57 60 62 64:67 70 73 74 77 78 82 84 86 90 91 95:99 102 105:2:113 114 116 118 121 123 126 133 134 137:143]);
                else
                    % Remove electrodes which don't have a 10-20 equivalent
                    % (based on BioSemi's documentation) and surnumeral
                    % electrodes of participants 13-15 (wrong electrode layout was loaded)
                    EEG = pop_select( EEG, 'nochannel', [2:2:8 9 11:14 16:2:26 27:2:37 38 40 41 44 47:2:57 60 62 64:67 70 73 74 77 78 82 84 86 90 91 95:99 102 105:2:113 114 116 118 121 123 126 129:256 261 262 265:271]);
                end
                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids, no ref to add back on Biosemi
                % Deviates from original study.
                EEG = pop_reref( EEG, {'M1' 'M2'} );

            case 'TrierCogPsy'
                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids and add previous Ref (Fz) as a data channel
                % Deviates from original study.
                ref_index = find(strcmpi({EEG.chaninfo.nodatchans(:).labels}', EEG.chanlocs(1).ref));
                ref = EEG.chaninfo.nodatchans(ref_index);
                EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {ref.labels}, 'type', {ref.type}, 'theta', {ref.theta}, 'radius', {ref.radius}, 'X', {ref.X}, 'Y', {ref.Y}, 'Z', {ref.Z}, 'sph_theta', {ref.sph_theta}, 'sph_phi', {ref.sph_phi}, 'sph_radius', {ref.sph_radius}, 'urchan', {ref.urchan}, 'ref', {ref.ref}, 'datachan', {0}));

            case 'Neuruppin'
                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids and add previous Ref (FCz) as a data channel
                % Deviates from original study.
                ref_index = find(strcmpi({EEG.chaninfo.nodatchans(:).labels}', EEG.chanlocs(1).ref));
                ref = EEG.chaninfo.nodatchans(ref_index);
                EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {ref.labels}, 'type', {ref.type}, 'theta', {ref.theta}, 'radius', {ref.radius}, 'X', {ref.X}, 'Y', {ref.Y}, 'Z', {ref.Z}, 'sph_theta', {ref.sph_theta}, 'sph_phi', {ref.sph_phi}, 'sph_radius', {ref.sph_radius}, 'urchan', {ref.urchan}, 'ref', {ref.ref}, 'datachan', {0}));

            case 'Auckland'
                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids and add previous Ref (FCz) as a data channel
                % Deviates from original study.
                ref_index = find(strcmpi({EEG.chaninfo.nodatchans(:).labels}', EEG.chanlocs(1).ref));
                ref = EEG.chaninfo.nodatchans(ref_index);
                EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {ref.labels}, 'type', {ref.type}, 'theta', {ref.theta}, 'radius', {ref.radius}, 'X', {ref.X}, 'Y', {ref.Y}, 'Z', {ref.Z}, 'sph_theta', {ref.sph_theta}, 'sph_phi', {ref.sph_phi}, 'sph_radius', {ref.sph_radius}, 'urchan', {ref.urchan}, 'ref', {ref.ref}, 'datachan', {0}));

            case 'ItierLab'
                % Temporary reference to POz for checking flat electrodes
                EEG = pop_reref( EEG, {'POz'} );

                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids, no ref to add back on Biosemi
                % Deviates from original study.
                EEG = pop_reref( EEG, {'M1' 'M2'} );

            case 'Malaga'
                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids and add previous Ref (FCz) as a data channel
                % Deviates from original study.
                ref_index = find(strcmpi({EEG.chaninfo.nodatchans(:).labels}', EEG.chanlocs(1).ref));
                ref = EEG.chaninfo.nodatchans(ref_index);
                EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {ref.labels}, 'type', {ref.type}, 'theta', {ref.theta}, 'radius', {ref.radius}, 'X', {ref.X}, 'Y', {ref.Y}, 'Z', {ref.Z}, 'sph_theta', {ref.sph_theta}, 'sph_phi', {ref.sph_phi}, 'sph_radius', {ref.sph_radius}, 'urchan', {ref.urchan}, 'ref', {ref.ref}, 'datachan', {0}));

            case 'Hildesheim'
                % Temporary reference to POz for checking flat electrodes
                EEG = pop_reref( EEG, {'POz'} );

                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids, no ref to add back on Biosemi
                % Deviates from original study.
                EEG = pop_reref( EEG, {'M1' 'M2'} );

            case 'NCC_UGR'
                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids and add previous Ref (Cz) as a data channel
                % Deviates from original study.
                ref_index = find(strcmpi({EEG.chaninfo.nodatchans(:).labels}', EEG.chanlocs(1).ref));
                ref = EEG.chaninfo.nodatchans(ref_index);
                EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {ref.labels}, 'type', {ref.type}, 'theta', {ref.theta}, 'radius', {ref.radius}, 'X', {ref.X}, 'Y', {ref.Y}, 'Z', {ref.Z}, 'sph_theta', {ref.sph_theta}, 'sph_phi', {ref.sph_phi}, 'sph_radius', {ref.sph_radius}, 'urchan', {ref.urchan}, 'ref', {ref.ref}, 'datachan', {0}));

            case 'UNIMORE'
                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids and add previous Ref (FCz) as a data channel
                % Deviates from original study.
                ref_index = find(strcmpi({EEG.chaninfo.nodatchans(:).labels}', EEG.chanlocs(1).ref));
                ref = EEG.chaninfo.nodatchans(ref_index);
                EEG = pop_reref( EEG, {'M1' 'M2'}, 'refloc', struct('labels', {ref.labels}, 'type', {ref.type}, 'theta', {ref.theta}, 'radius', {ref.radius}, 'X', {ref.X}, 'Y', {ref.Y}, 'Z', {ref.Z}, 'sph_theta', {ref.sph_theta}, 'sph_phi', {ref.sph_phi}, 'sph_radius', {ref.sph_radius}, 'urchan', {ref.urchan}, 'ref', {ref.ref}, 'datachan', {0}));

            case 'GenevaKliegel'
                % Temporary reference to POz for checking flat electrodes
                EEG = pop_reref( EEG, {'POz'} );
                
                % Check for flat M1, M2, PO7 or PO8.
                % Throws an error if any are flat.
                % Deviates from original study.
                check_flat_channels(EEG, {'PO7', 'PO8', 'M1', 'M2'}, participant_nr);

                % Rereference to average of mastoids, no ref to add back on Biosemi
                % Deviates from original study.
                EEG = pop_reref( EEG, {'M1' 'M2'} );

            otherwise
                error('Team not found');
        end

        %% Filters
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

        %% Resample to 200 Hz
        % "EEG and EOG were sampled with a digitization rate of 200 Hz."
        EEG = eeg_checkset( EEG );
        EEG = pop_resample(EEG, 200);

        %% Convert our markers to ERPLAB-compatible format
        EEG = pop_creabasiceventlist( EEG, 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset(EEG, 'filename', savename, 'filepath', [filepath filesep team filesep 'EEG']); %#ok<*NASGU>
    end
end
