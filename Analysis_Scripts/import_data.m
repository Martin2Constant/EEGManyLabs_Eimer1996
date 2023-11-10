function import_data(participant_nr, filepath, team)
    % Author: Martin Constant (martin.constant@unige.ch)
    %% Import data and change electrode names to be BESA-compliant
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
            EEG.VEOG_side = "right";

        case 'Munich'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%i', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%i.csv', team, participant_nr);
            % Loading EEG
            EEG = pop_loadbv([filepath filesep filesep team filesep 'RawData'], [filename_eeg '.vhdr']);

            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'changefield', {5, 'labels', 'LO1'}, 'changefield', {10, 'labels', 'M1'}, 'changefield', {21, 'labels', 'M2'}, 'changefield', {27, 'labels', 'LO2'}, 'changefield', {64, 'labels', 'IO2'}, 'append', 64, 'changefield', {65, 'labels', 'FCz'}, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:65', 'FCz'}, 'eval', '', 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);', 'convert', {'cart2all'});
            EEG.VEOG_side = "right";

        case 'Essex'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%03i.cdt', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%03i.csv', team, participant_nr);
            filename_cdt = [filepath filesep team filesep 'RawData' filesep filename_eeg];
            % Loading EEG
            EEG = loadcurry(filename_cdt, 'KeepTriggerChannel', 'True', 'CurryLocations', 'False');

            % Remove unused channel.
            EEG = pop_select( EEG, 'nochannel', {'TRIGGER'});
            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'changefield', {31, 'labels', 'LO1'}, 'changefield', {32, 'labels', 'LO2'}, 'changefield', {33, 'labels', 'IO2'}, 'append', 33, 'changefield', {34, 'labels', 'M1'}, 'lookup', 'standard-10-5-cap385.elp', 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);', 'setref', {'1:34', 'M1'});
            EEG.VEOG_side = "right";

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
            EEG.VEOG_side = "left";

        case 'ONERA'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%04i', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%i.csv', team, participant_nr);
            % Loading EEG
            EEG = pop_loadbv([filepath filesep filesep team filesep 'RawData'], [filename_eeg '.vhdr']);

            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'append', 63, 'changefield', {64, 'labels', 'FCz'}, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:64', 'FCz'}, 'eval', '', 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);', 'convert', {'cart2all'});
            EEG.VEOG_side = "left";

        case 'Geneva'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%04i', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%i.csv', team, participant_nr);
            % Loading EEG
            EEG = pop_loadbv([filepath filesep filesep team filesep 'RawData'], [filename_eeg '.vhdr']);

            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'changefield', {1, 'labels', 'LO2'}, 'changefield', {2, 'labels', 'LO1'}, 'changefield', {3, 'labels', 'SO2'}, 'changefield', {4, 'labels', 'IO2'}, 'changefield', {5, 'labels', 'M1'}, 'changefield', {6, 'labels', 'M2'}, 'append', 31, 'changefield', {32, 'labels', 'FCz'}, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:32', 'FCz'}, 'eval', '', 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);', 'convert', {'cart2all'});
            EEG.VEOG_side = "right";

        case 'GroupLC'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%02i', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%02i.csv', team, participant_nr);
            filename_bdf = [filepath filesep team filesep 'RawData' filesep filename_eeg '.bdf'];

            % Importing with POz (chan 30) as temporary reference
            % Re-referenced to average mastoids at a later point.
            EEG = pop_biosig(filename_bdf, 'ref', 30, 'importannot','off');
            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'lookup', 'standard-10-5-cap385.elp', 'changefield', {65, 'labels', 'M1'}, 'changefield', {66, 'labels', 'M2'}, 'changefield', {67, 'labels', 'LO1'}, 'changefield', {68, 'labels', 'LO2'}, 'changefield', {69, 'labels', 'SO1'}, 'changefield', {70, 'labels', 'IO1'}, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:72', 'POz'}, 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);');
            % Remove unused electrodes
            EEG = pop_select( EEG, 'nochannel', {'EXG7', 'EXG8'});
            EEG.VEOG_side = "left";

        case 'LSU'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%02i', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%02i.csv', team, participant_nr);
            filename_bdf = [filepath filesep team filesep 'RawData' filesep filename_eeg '.bdf'];

            % Importing with POz (chan 30) as temporary reference
            % Re-referenced to average mastoids at a later point.
            EEG = pop_biosig(filename_bdf, 'ref', 30, 'importannot','off');
            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'lookup', 'standard-10-5-cap385.elp', 'changefield', {66, 'labels', 'IO2'}, 'changefield', {67, 'labels', 'LO1'}, 'changefield', {68, 'labels', 'LO2'}, 'changefield', {69, 'labels', 'M1'}, 'changefield', {70, 'labels', 'M2'}, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:72', 'POz'}, 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);');
            % Remove unused electrodes
            EEG = pop_select( EEG, 'nochannel', {'EXG1', 'EXG7', 'EXG8'});
            EEG.VEOG_side = "right";

        case 'Magdeburg'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%02i', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%02i.csv', team, participant_nr);
            % Loading EEG
            EEG = pop_loadbv([filepath filesep filesep team filesep 'RawData'], [filename_eeg '.vhdr']);

            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:64', 'Nose'}, 'eval', '', 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);', 'convert', {'cart2all'});
            EEG.VEOG_side = "left";

        case 'Verona'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%02i', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%02i.csv', team, participant_nr);
            % Loading EEG
            EEG = pop_loadbv([filepath filesep filesep team filesep 'RawData'], [filename_eeg '.vhdr']);

            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'lookup', 'standard-10-5-cap385.elp', 'changefield', {4, 'labels', 'LO1'}, 'changefield', {26, 'labels', 'LO2'}, 'changefield', {32, 'labels', 'IO2'}, 'changefield', {60, 'labels', 'SO2'}, 'append', 63, 'changefield', {64, 'labels', 'Fz'}, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:64', 'Fz'}, 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);');
            EEG.VEOG_side = "right";

        case 'KHas'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%02i', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%02i.csv', team, participant_nr);
            % Loading EEG
            EEG = pop_loadbv([filepath filesep filesep team filesep 'RawData'], [filename_eeg '.vhdr']);

            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'lookup', 'standard-10-5-cap385.elp', 'changefield', {1, 'labels', 'IO2'}, 'changefield', {5, 'labels', 'LO1'}, 'changefield', {10, 'labels', 'M1'}, 'changefield', {21, 'labels', 'M2'}, 'changefield', {26, 'labels', 'LO2'}, 'changefield', {31, 'labels', 'Fp2'}, 'append', 31, 'changefield', {32, 'labels', 'Cz'}, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:32', 'Cz'}, 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);');
            EEG.VEOG_side = "right";

        case 'TrierKamp'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%04i', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%02i.csv', team, participant_nr);
            % Loading EEG
            EEG = pop_loadbv([filepath filesep filesep team filesep 'RawData'], [filename_eeg '.vhdr']);

            % Change electrode names to match names from the BESA template
            % and load BESA locations
            EEG = pop_chanedit(EEG, 'lookup', 'standard-10-5-cap385.elp', 'changefield', {13, 'labels', 'IO2'}, 'changefield', {14, 'labels', 'LO1'}, 'changefield', {15, 'labels', 'LO2'}, 'changefield', {18, 'labels', 'M1'}, 'changefield', {19, 'labels', 'M2'}, 'append', 19, 'changefield', {20, 'labels', 'FCz'}, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:64', 'Fz'}, 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);');
            EEG.VEOG_side = "right";
        
        case 'UniWien'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%02i', team, participant_nr);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%02i.csv', team, participant_nr);
            filename_bdf = [filepath filesep team filesep 'RawData' filesep filename_eeg '.bdf'];

            % Importing with POz (chan 21) as temporary reference
            % Re-referenced to average mastoids at a later point.
            % EEG = pop_biosig(filename_bdf, 'ref', 21, 'importannot','off');
            EEG = pop_loadset([filename_eeg '.set'], [filepath filesep team filesep 'RawData']);
            
            % Change electrode names from ABC to 10-20 and load BESA locations
            EEG = pop_chanedit(EEG, 'lookup', 'standard-10-5-cap385.elp', ...
                'changefield', {1, 'labels', 'Cz'}, ...
                'changefield', {3, 'labels', 'CPz'}, ... 
                'changefield', {5, 'labels', 'P1'}, ...
                'changefield', {7, 'labels', 'P3'}, ...
                'changefield', {10, 'labels', 'PO7'}, ...
                'changefield', {15, 'labels', 'O1'}, ...
                'changefield', {17, 'labels', 'PO3'}, ... 
                'changefield', {19, 'labels', 'Pz'}, ...
                'changefield', {21, 'labels', 'POz'}, ...
                'changefield', {23, 'labels', 'Oz'}, ...
                'changefield', {25, 'labels', 'Iz'}, ...
                'changefield', {28, 'labels', 'O2'}, ... 
                'changefield', {30, 'labels', 'PO4'}, ...
                'changefield', {32, 'labels', 'P2'}, ...
                'changefield', {34, 'labels', 'CP2'}, ...
                'changefield', {36, 'labels', 'P4'}, ...
                'changefield', {39, 'labels', 'PO8'}, ... 
                'changefield', {42, 'labels', 'P10'}, ...
                'changefield', {43, 'labels', 'P8'}, ...
                'changefield', {45, 'labels', 'P6'}, ...
                'changefield', {46, 'labels', 'TP8'}, ...
                'changefield', {48, 'labels', 'CP6'}, ... 
                'changefield', {50, 'labels', 'CP4'}, ...
                'changefield', {52, 'labels', 'C2'}, ...
                'changefield', {54, 'labels', 'C4'}, ...
                'changefield', {56, 'labels', 'C6'}, ...
                'changefield', {58, 'labels', 'T8'}, ... 
                'changefield', {59, 'labels', 'FT8'}, ...
                'changefield', {61, 'labels', 'FC6'}, ...
                'changefield', {63, 'labels', 'FC4'}, ...
                'changefield', {68, 'labels', 'F4'}, ...
                'changefield', {69, 'labels', 'F6'}, ... 
                'changefield', {71, 'labels', 'F8'}, ...
                'changefield', {72, 'labels', 'AF8'}, ...
                'changefield', {75, 'labels', 'FC2'}, ...
                'changefield', {76, 'labels', 'F2'}, ...
                'changefield', {79, 'labels', 'AF4'}, ... 
                'changefield', {80, 'labels', 'Fp2'}, ...
                'changefield', {81, 'labels', 'Fpz'}, ...
                'changefield', {83, 'labels', 'AFz'}, ...
                'changefield', {85, 'labels', 'Fz'}, ...
                'changefield', {87, 'labels', 'FCz'}, ...
                'changefield', {88, 'labels', 'FC1'}, ... 
                'changefield', {89, 'labels', 'F1'}, ...
                'changefield', {92, 'labels', 'AF3'}, ...
                'changefield', {93, 'labels', 'Fp1'}, ...
                'changefield', {94, 'labels', 'AF7'}, ...
                'changefield', {100, 'labels', 'F3'}, ... 
                'changefield', {101, 'labels', 'F5'}, ...
                'changefield', {103, 'labels', 'F7'}, ...
                'changefield', {104, 'labels', 'FT7'}, ...
                'changefield', {106, 'labels', 'FC5'}, ...
                'changefield', {108, 'labels', 'FC3'}, ... 
                'changefield', {110, 'labels', 'C1'}, ...
                'changefield', {112, 'labels', 'CP1'}, ...
                'changefield', {115, 'labels', 'C3'}, ...
                'changefield', {117, 'labels', 'C5'}, ...
                'changefield', {119, 'labels', 'T7'}, ... 
                'changefield', {120, 'labels', 'TP7'}, ...
                'changefield', {122, 'labels', 'CP5'}, ...
                'changefield', {124, 'labels', 'CP3'}, ...
                'changefield', {125, 'labels', 'P5'}, ...
                'changefield', {127, 'labels', 'P7'}, ...
                'changefield', {128, 'labels', 'P9'}, ...
                'changefield', {129, 'labels', 'M1'}, ...
                'changefield', {130, 'labels', 'M2'}, ... 
                'changefield', {131, 'labels', 'SO2'}, ...
                'changefield', {132, 'labels', 'IO2'}, ...
                'changefield', {135, 'labels', 'LO2'}, ...
                'changefield', {136, 'labels', 'LO1'}, ...
                'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:143', 'POz'}, 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);');
            
            % Remove electrodes which don't have a 10-20 equivalent (based on BioSemi's documentation
            EEG = pop_select( EEG, 'nochannel', [2:2:8 9 11:14 16:2:26 27:2:37 38	40 41 44 47:2:57 60	62 64:67 70 73 74 77 78 82 84 86 90	91 95:99 102 105:2:113 114 116 118 121 123 126 133 134 137:143]);
            EEG = pop_chanedit(EEG, 'lookup', 'standard-10-5-cap385.elp', 'setref', {'1:70', 'POz'}, 'convert', {'cart2all'}, 'eval', 'chans = pop_chancenter( chans, [], []);');
            EEG.VEOG_side = "right";

        otherwise
            error('Team not found');
    end

    % Transform EEG to double precision
    EEG.data = double(EEG.data);
    EEG = eeg_checkset(EEG);
    EEG.setname = sprintf('%s_participant%02i_harmonized', team, participant_nr);

    % Save behavior table (without practice trials) to EEG object
    behavior = readtable([filepath filesep team filesep 'RawData' filesep filename_behavior], 'Delimiter', ',');
    behavior = behavior(behavior.Practice == 0, :);
    EEG.behavior = behavior;
    EEG.team = team;
    harmonize_markers(EEG, filepath);
end
