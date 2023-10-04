function import_data(participant_nr, filepath, team)
    % Author: Martin Constant (martin.constant@unige.ch)
    switch team
        case 'Krakow'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%i.bdf', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%i.csv', team, participant_nr);
            filename_bdf = [filepath filesep team filesep 'RawData' filesep filename_eeg];

            % Importing with POz (chan 30) as temporary reference
            % Re-referenced to average mastoids at a later point.
            EEG = pop_biosig(filename_bdf, 'ref', 30, 'importannot','off');
            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'lookup', 'standard-10-5-cap385.elp', 'changefield', {65, 'labels', 'SO2'}, 'changefield', {66, 'labels', 'IO2'}, 'changefield', {67, 'labels', 'LO1'}, 'changefield', {68, 'labels', 'LO2'}, 'changefield', {71, 'labels', 'M1'}, 'changefield', {72, 'labels', 'M2'}, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:72', 'POz'}, 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);');
            % Remove unused electrodes
            EEG = pop_select( EEG, 'nochannel', {'EXG5', 'EXG6'});

        case 'Munich'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%i', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%i.csv', team, participant_nr);
            % Loading EEG
            EEG = pop_loadbv([filepath filesep filesep team filesep 'RawData'], [filename_eeg '.vhdr']);

            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'changefield', {5, 'labels', 'LO1'}, 'changefield', {10, 'labels', 'M1'}, 'changefield', {21, 'labels', 'M2'}, 'changefield', {27, 'labels', 'LO2'}, 'changefield', {64, 'labels', 'IO2'}, 'append', 64, 'changefield', {65, 'labels', 'FCz'}, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:65', 'FCz'}, 'eval', '', 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);', 'convert', {'cart2all'});

        case 'Essex'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%02i.cdt', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%02i.csv', team, participant_nr);
            filename_cdt = [filepath filesep team filesep 'RawData' filesep filename_eeg];
            % Loading EEG
            EEG = loadcurry(filename_cdt, 'KeepTriggerChannel', 'True', 'CurryLocations', 'False');

            % Remove unused channel.
            EEG = pop_select( EEG, 'nochannel', {'TRIGGER'});
            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'changefield', {29, 'labels', 'LO1'}, 'changefield', {30, 'labels', 'IO2'}, 'changefield', {21, 'labels', 'M2'}, 'append', 30, 'changefield', {31, 'labels', 'M1'}, 'lookup', 'standard-10-5-cap385.elp', 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);', 'setref', {'1:31', 'M1'});

        case 'Gent'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%i.bdf', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%i.csv', team, participant_nr);
            filename_bdf = [filepath filesep team filesep 'RawData' filesep filename_eeg];

            % Importing with POz (chan 30) as temporary reference
            % Re-referenced to average mastoids at a later point.
            EEG = pop_biosig(filename_bdf, 'ref', 30, 'importannot','off');
            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'lookup', 'standard-10-5-cap385.elp', 'changefield', {65, 'labels', 'M1'}, 'changefield', {66, 'labels', 'M2'}, 'changefield', {67, 'labels', 'LO1'}, 'changefield', {68, 'labels', 'LO2'}, 'changefield', {69, 'labels', 'SO1'}, 'changefield', {70, 'labels', 'IO1'}, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:72', 'POz'}, 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);');
            % Remove unused electrodes
            EEG = pop_select( EEG, 'nochannel', {'EXG7', 'EXG8'});
        case 'ONERA'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%04i', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%i.csv', team, participant_nr);
            % Loading EEG
            EEG = pop_loadbv([filepath filesep filesep team filesep 'RawData'], [filename_eeg '.vhdr']);

            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'append', 63, 'changefield', {64, 'labels', 'FCz'}, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:64', 'FCz'}, 'eval', '', 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);', 'convert', {'cart2all'});

        case 'Geneva'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%04i', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%i.csv', team, participant_nr);
            % Loading EEG
            EEG = pop_loadbv([filepath filesep filesep team filesep 'RawData'], [filename_eeg '.vhdr']);

            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'changefield', {1, 'labels', 'LO2'}, 'changefield', {2, 'labels', 'LO1'}, 'changefield', {3, 'labels', 'SO2'}, 'changefield', {4, 'labels', 'IO2'}, 'changefield', {5, 'labels', 'M1'}, 'changefield', {6, 'labels', 'M2'}, 'append', 31, 'changefield', {32, 'labels', 'FCz'}, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:32', 'FCz'}, 'eval', '', 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);', 'convert', {'cart2all'});
        
        case 'GroupLC'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%i', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%i.csv', team, participant_nr);
            filename_cdt = [filepath filesep team filesep 'RawData' filesep filename_eeg '.cdt'];
            
            if ~exist([filepath filesep team filesep 'RawData' filesep filename_eeg '.cdt.ceo'], 'file')
                if exist([filepath filesep team filesep 'RawData' filesep filename_eeg '.ceo'], 'file')
                    movefile([filepath filesep team filesep 'RawData' filesep filename_eeg '.ceo'], [filepath filesep team filesep 'RawData' filesep filename_eeg '.cdt.ceo'])
                end
            end

            if ~exist([filepath filesep team filesep 'RawData' filesep filename_eeg '.cdt.dpo'], 'file')
                if exist([filepath filesep team filesep 'RawData' filesep filename_eeg '.dpo'], 'file')
                    movefile([filepath filesep team filesep 'RawData' filesep filename_eeg '.dpo'], [filepath filesep team filesep 'RawData' filesep filename_eeg '.cdt.dpo'])
                end
            end

            % Loading EEG
            EEG = loadcurry(filename_cdt, 'KeepTriggerChannel', 'True', 'CurryLocations', 'False');

            % Remove unused channel.
            EEG = pop_select( EEG, 'nochannel', {'EKG', 'EMG', 'TRIGGER'});
            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'changefield', {60, 'labels', 'I1'}, 'changefield', {64, 'labels', 'I2'}, 'changefield', {65, 'labels', 'LO1'}, 'changefield', {66, 'labels', 'IO1'}, 'append', 66, 'changefield', {67, 'labels', 'CCPz'}, 'lookup', 'standard-10-5-cap385.elp', 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);', 'setref', {'1:67', 'CCpz'});
        case 'LSU'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%02i.bdf', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%02i.csv', team, participant_nr);
            filename_bdf = [filepath filesep team filesep 'RawData' filesep filename_eeg];

            % Importing with POz (chan 30) as temporary reference
            % Re-referenced to average mastoids at a later point.
            EEG = pop_biosig(filename_bdf, 'ref', 30, 'importannot','off');
            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'lookup', 'standard-10-5-cap385.elp', 'changefield', {66, 'labels', 'IO2'}, 'changefield', {67, 'labels', 'LO1'}, 'changefield', {68, 'labels', 'LO2'}, 'changefield', {69, 'labels', 'M1'}, 'changefield', {70, 'labels', 'M2'}, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:72', 'POz'}, 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);');
            % Remove unused electrodes
            EEG = pop_select( EEG, 'nochannel', {'EXG1', 'EXG7', 'EXG8'});
        case 'Magdeburg'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%02i', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%02i.csv', team, participant_nr);
            % Loading EEG
            EEG = pop_loadbv([filepath filesep filesep team filesep 'RawData'], [filename_eeg '.vhdr']);

            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:64', 'Nose'}, 'eval', '', 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);', 'convert', {'cart2all'});
        
        otherwise
            error('Team not found');
    end
    EEG.data = double(EEG.data);
    EEG = eeg_checkset(EEG);
    EEG.setname = sprintf('%s_participant%02i_harmonized', team, participant_nr);

    % Add behavior table (without practice trials) to EEG object
    behavior = readtable([filepath filesep team filesep 'RawData' filesep filename_behavior], 'Delimiter', ',');
    behavior = behavior(behavior.Practice == 0, :);
    EEG.behavior = behavior;
    EEG.team = team;
    harmonize_markers(EEG, filepath);
end
