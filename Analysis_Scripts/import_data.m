function import_data(participant_nr, filepath, team)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    switch team
        case 'Krakow'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%i.bdf', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%i.csv', team, participant_nr);
            filename_bdf = [filepath filesep team filesep 'RawData' filesep filename_eeg];
         
            % Importing with POz (chan 30) as temporary reference
            % Re-referenced to average mastoids at a later point.
            EEG = pop_biosig(filename_bdf, 'ref', 30);

        case 'Munich'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%i', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%i.csv', team, participant_nr);
            % Loading EEG
            EEG = pop_loadbv([filepath filesep filesep team filesep 'RawData'], [filename_eeg '.vhdr']);

        case 'Essex'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%02i.cdt', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%02i.csv', team, participant_nr);
            filename_cdt = [filepath filesep team filesep 'RawData' filesep filename_eeg];
            % Loading EEG
            EEG = loadcurry(filename_cdt, 'KeepTriggerChannel', 'True', 'CurryLocations', 'False');

    end
    EEG.data = double(EEG.data);
    EEG = eeg_checkset(EEG);
    EEG.setname = sprintf('%s_participant%i_harmonized', team, participant_nr);

    % Add behavior table (without practice trials) to EEG object
    behavior = readtable([filepath filesep team filesep 'RawData' filesep filename_behavior]);
    behavior = behavior(behavior.Practice == 0, :);
    EEG.behavior = behavior;
    EEG.team = team;
    harmonize_markers(EEG, filepath);
end
