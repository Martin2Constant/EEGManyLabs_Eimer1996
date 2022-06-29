function postICA(participant_nr, filepath, team)
    %% Initialize and load
    id = participant_nr;
    post_ica = sprintf('participant%i_preICA.set', id);
    processed = sprintf('participant%i_clean.set', id);
    erp_name = sprintf('participant%i', id);
    EEG = pop_loadset(post_ica, [filepath filesep 'EEG']);

    EEG = eeg_checkset( EEG );
    EEG  = pop_binlister( EEG , 'BDF', [filepath filesep 'bins.txt'], 'IndexEL',  1, 'SendEL2', 'EEG', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
    EEG = eeg_checkset( EEG );

    % "EEG and EOG were epoched off-line into periods of 700 ms, starting 
    % 100 ms prior to the onset of the letter stimulus, and ending 600 ms 
    % after letter onset." 
    % "All measures were taken relative to the mean voltage of the 100 ms 
    % interval preceding the onset of the stimulus array."
    EEG = pop_epochbin( EEG , [-100.0  600+(1000/EEG.srate)],  'pre');
    EEG = eeg_checkset( EEG );

    switch team
        case 'Liesefeld'
            % "Horizontal EOG was recorded bipolarly from electrodes at the
            % outer canthi of both eyes, vertical EOG was recorded from 
            % electrodes above and beside the right eye."
            % Thus we re-create bipolar electrodes
            EEG = pop_eegchanoperator( EEG, {  'ch64 = ch30-ch62 label VEOG', 'ch65 = ch5-ch25 label HEOG'} , 'ErrorMsg', 'popup', 'KeepChLoc', 'on', 'Warning', 'on' );

            % "Trials with eyeblinks (VEOG amplitude exceeding +/- 60 µV)"
            EEG  = pop_artextval( EEG , 'Channel',  64, 'Flag', [ 1 2], 'LowPass',  -1, 'Threshold', [ -60 60], 'Twindow', [ -100 600] );
            % "horizontal eye movements (HEOG amplitude exceeding +/- 25µV)"
            EEG  = pop_artextval( EEG , 'Channel',  65, 'Flag', [ 1 3], 'LowPass',  -1, 'Threshold', [ -25 25], 'Twindow', [ -100 600] );

        case 'Asanowicz'
            EEG = pop_eegchanoperator( EEG, {  'ch69 = ch65 - ch66 label VEOG',  'ch70 = ch67 - ch68 label HEOG'} , 'ErrorMsg', 'popup', 'KeepChLoc', 'on', 'Warning', 'on' );

            EEG  = pop_artextval( EEG , 'Channel',  69, 'Flag', [ 1 2], 'LowPass',  -1, 'Threshold', [ -60 60], 'Twindow', [ -100 600] );

            EEG  = pop_artextval( EEG , 'Channel',  70, 'Flag', [ 1 3], 'LowPass',  -1, 'Threshold', [ -25 25], 'Twindow', [ -100 600] );
    end

    EEG = eeg_checkset( EEG , 'eventconsistency' );
    EEG = eeg_checkset( EEG );

    EEG = pop_saveset(EEG, 'filename', processed, 'filepath', [filepath filesep 'EEG']);

    EEG = eeg_checkset( EEG );
    ERP = pop_averager( EEG , 'Criterion', 'good', 'DQ_custom_wins', 0, 'DQ_flag', 1, 'DQ_preavg_txt', 0, 'ExcludeBoundary', 'on', 'SEM', 'on' );

    switch team
        case 'Liesefeld'
            ERP = pop_binoperator( ERP, {'prepareContraIpsi',...
                'Lch = [ 1 34 3 35 4 5 7 37 6 38 8 39 9 11 41 10 42 13 43 14 15 32 31 36 40 45 44 2 12 16 22 33 46 51 63];',...
                'Rch = [ 30 61 28 58 29 25 27 56 26 55 23 54 24 21 52 20 50 18 49 19 17 60 59 57 53 47 48 2 12 16 22 33 46 51 63];',...
                'nbin1 = 0.5*bin1@Rch + 0.5*bin2@Lch label M Contra',...
                'nbin2 = 0.5*bin1@Lch + 0.5*bin2@Rch label M Ipsi',...
                'nbin3 = 0.5*bin4@Rch + 0.5*bin5@Lch label W Contra',...
                'nbin4 = 0.5*bin4@Lch + 0.5*bin5@Rch label W Ipsi',...
                'nbin5 = 0.5*bin7@Rch + 0.5*bin8@Lch label Blue Contra',...
                'nbin6 = 0.5*bin7@Lch + 0.5*bin8@Rch label Blue Ipsi',...
                'nbin7 = 0.5*bin10@Rch + 0.5*bin11@Lch label Green Contra',...
                'nbin8 = 0.5*bin10@Lch + 0.5*bin11@Rch label Green Ipsi'});
        case 'Asanowicz'
            ERP = pop_binoperator( ERP, {'prepareContraIpsi',...
                'Lch = [ 1 3 2 4:8 11:-1:9 12:16 19:-1:17 20:24 26 25 27 67 28:33 37 38 47 48 69 70];',...
                'Rch = [ 34 36 35 39:43 46:-1:44 49:53 56:-1:54 57:61 63 62 64 68 28:33 37 38 47 48 69 70];',...
                'nbin1 = 0.5*bin1@Rch + 0.5*bin2@Lch label M Contra',...
                'nbin2 = 0.5*bin1@Lch + 0.5*bin2@Rch label M Ipsi',...
                'nbin3 = 0.5*bin4@Rch + 0.5*bin5@Lch label W Contra',...
                'nbin4 = 0.5*bin4@Lch + 0.5*bin5@Rch label W Ipsi',...
                'nbin5 = 0.5*bin7@Rch + 0.5*bin8@Lch label Blue Contra',...
                'nbin6 = 0.5*bin7@Lch + 0.5*bin8@Rch label Blue Ipsi',...
                'nbin7 = 0.5*bin10@Rch + 0.5*bin11@Lch label Green Contra',...
                'nbin8 = 0.5*bin10@Lch + 0.5*bin11@Rch label Green Ipsi'});
    end

    ERP = pop_binoperator( ERP, {'bin9 = bin1 - bin2 label M Contra-Ipsi',...
        'bin10 = bin3 - bin4 label W Contra-Ipsi',...
        'bin11 = bin5 - bin6 label Blue Contra-Ipsi',...
        'bin12 = bin7 - bin8 label Green Contra-Ipsi'});

    ERP = pop_binoperator( ERP, {'bin13 = (bin9 + bin10)/2 label Letters Contra-Ipsi',...
        'bin14 = (bin11 + bin12)/2 label Colors Contra-Ipsi'});

    ERP = pop_savemyerp(ERP, 'erpname', erp_name, 'filename', [erp_name '.erp'], 'filepath', [filepath filesep 'ERP'], 'Warning', 'off');
end
