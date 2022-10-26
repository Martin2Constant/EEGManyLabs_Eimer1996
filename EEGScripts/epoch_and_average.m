function epoch_and_average(participant_nr, filepath, team),
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    filtered = sprintf('%s_participant%i_filtered.set', team, participant_nr);
    epoched = sprintf('%s_participant%i_epoched.set', team, participant_nr);
    erp_name = sprintf('%s_participant%i', team, participant_nr);

    EEG = pop_loadset(filtered, [filepath filesep team filesep 'EEG']);
    EEG = eeg_checkset(EEG);

    % Assign bins to each epoch based on ./bins.txt
    EEG = pop_binlister(EEG, 'BDF', [filepath filesep 'bins.txt'], 'IndexEL', 1, 'SendEL2', 'EEG', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
    EEG = eeg_checkset(EEG);

    % Create epochs from -100 ms to 600 ms and baseline correct to
    % pre-stimulus interval.
    % "EEG and EOG were epoched off-line into periods of 700 ms, starting
    % 100 ms prior to the onset of the letter stimulus, and ending 600 ms
    % after letter onset."
    % "All measures were taken relative to the mean voltage of the 100 ms
    % interval preceding the onset of the stimulus array."
    EEG = pop_epochbin(EEG, [-100.0 600+(1000/EEG.srate)], 'pre');
    EEG = eeg_checkset(EEG);
    chanlocs = {EEG.chanlocs(:).labels}';
    nb_chans = size(EEG.data, 1);
    PO7_index = find(strcmpi(chanlocs, 'PO7'));
    PO8_index = find(strcmpi(chanlocs, 'PO8'));
    IO2_index = find(strcmpi(chanlocs, 'IO2'));
    LO1_index = find(strcmpi(chanlocs, 'LO1'));
    LO2_index = find(strcmpi(chanlocs, 'LO2'));
    SO2_index = find(strcmpi(chanlocs, 'SO2'));
    if isempty(SO2_index)
        SO2_index = find(strcmpi(chanlocs, 'Fp2'));
    end
    VEOG_index = nb_chans + 1;
    HEOG_index = nb_chans + 2;
    % "Horizontal EOG was recorded bipolarly from electrodes at the
    % outer canthi of both eyes, vertical EOG was recorded from
    % electrodes above and beside the right eye."
    % Thus we re-create bipolar eye electrodes and run rejection
    % procedure on these.
    % Deviates from original study: VEOG was above minus besides.
    EEG = pop_eegchanoperator(EEG, ...
        {sprintf('ch%i = ch%i-ch%i label VEOG', VEOG_index, SO2_index, IO2_index), ...
        sprintf('ch%i = ch%i-ch%i label HEOG', HEOG_index, LO1_index, LO2_index)}, ...
        'ErrorMsg', 'popup', 'KeepChLoc', 'on', 'Warning', 'on', 'Saveas', 'off');

    % Removing trials with flat PO7/PO8/EOGs
    % Deviates from original study.
    EEG  = pop_artflatline(EEG , 'Channel', [PO7_index PO8_index IO2_index LO1_index LO2_index SO2_index],...
        'Duration',  350, 'Flag', [ 1 4], 'LowPass',  -1,...
        'Threshold', [ -1 1], 'Twindow', [ -100 600] );

    % "Trials with eyeblinks (VEOG amplitude exceeding +/- 60 µV)"
    EEG = pop_artextval(EEG, 'Channel', VEOG_index, 'Flag', [ 1 2], 'LowPass', -1, 'Threshold', [ -60 60], 'Twindow', [ -100 600] );
    % "horizontal eye movements (HEOG amplitude exceeding +/- 25 µV)"
    EEG = pop_artextval(EEG, 'Channel', HEOG_index, 'Flag', [ 1 3], 'LowPass', -1, 'Threshold', [ -25 25], 'Twindow', [ -100 600] );

    EEG = eeg_checkset(EEG, 'eventconsistency' );
    EEG = eeg_checkset(EEG);

    EEG = pop_saveset(EEG, 'filename', epoched, 'filepath', [filepath filesep team filesep 'EEG']);

    EEG = eeg_checkset(EEG);

    % All functions returning ERP are ERPLAB functions
    ERP = pop_averager(EEG, 'Criterion', 'good', 'DQ_custom_wins', 0, 'DQ_flag', 1, 'DQ_preavg_txt', 0, 'ExcludeBoundary', 'on', 'SEM', 'on' );

    switch team
        case 'Munich'
            LeftChans = 'Lch = [ 1 34 3 35 4 5 7 37 6 38 8 39 9 11 41 10 42 13 43 14 15 32 31 36 40 45 44 2 12 16 22 33 46 51 63];';
            RightChans = 'Rch = [ 30 61 28 58 29 25 27 56 26 55 23 54 24 21 52 20 50 18 49 19 17 60 59 57 53 47 48 2 12 16 22 33 46 51 63];';
        case 'Krakow'
            LeftChans = 'Lch = [ 1 3 2 4:8 11:-1:9 12:16 19:-1:17 20:24 26 25 27 67 28:33 37 38 47 48 69 70];';
            RightChans = 'Rch = [ 34 36 35 39:43 46:-1:44 49:53 56:-1:54 57:61 63 62 64 68 28:33 37 38 47 48 69 70];';
        case 'Essex'
            LeftChans ='Lch = [ 1 4 8 7 11 12 16 15 21 20 25 2 5 17 22 29 30];';
            RightChans ='Rch = [ 3:3:9 10 14 13 18 19 23 24 26 2 5 17 22 29 30];';
    end

    % Create contra and ipsi waves
    ERP = pop_binoperator( ERP, {'prepareContraIpsi', ...
        sprintf('%s', LeftChans), ...
        sprintf('%s', RightChans), ...
        'nbin1 = 0.5*bin1@Rch + 0.5*bin2@Lch label M Contra', ...
        'nbin2 = 0.5*bin1@Lch + 0.5*bin2@Rch label M Ipsi', ...
        'nbin3 = 0.5*bin4@Rch + 0.5*bin5@Lch label W Contra', ...
        'nbin4 = 0.5*bin4@Lch + 0.5*bin5@Rch label W Ipsi', ...
        'nbin5 = 0.5*bin7@Rch + 0.5*bin8@Lch label Blue Contra', ...
        'nbin6 = 0.5*bin7@Lch + 0.5*bin8@Rch label Blue Ipsi', ...
        'nbin7 = 0.5*bin10@Rch + 0.5*bin11@Lch label Green Contra', ...
        'nbin8 = 0.5*bin10@Lch + 0.5*bin11@Rch label Green Ipsi'});


    % Compute difference waves for each condition
    ERP = pop_binoperator( ERP, {'bin9 = bin1 - bin2 label M Contra-Ipsi', ...
        'bin10 = bin3 - bin4 label W Contra-Ipsi', ...
        'bin11 = bin5 - bin6 label Blue Contra-Ipsi', ...
        'bin12 = bin7 - bin8 label Green Contra-Ipsi'});

    % Compute contra and ipsi (and difference waves) for each category
    % (letters and colors) as well as the average for all conditions.
    ERP = pop_binoperator( ERP, {'bin13 = (bin1 + bin3)/2 label Letters Contra', ...
        'bin14 = (bin2 + bin4)/2 label Letters Ipsi', ...
        'bin15 = (bin9 + bin10)/2 label Letters Contra-Ipsi', ...
        'bin16 = (bin5 + bin7)/2 label Colors Contra', ...
        'bin17 = (bin6 + bin8)/2 label Colors Ipsi', ...
        'bin18 = (bin11 + bin12)/2 label Colors Contra-Ipsi', ...
        'bin19 = (bin1+bin3+bin5+bin7)/4 label All Contra', ...
        'bin20 = (bin2+bin4+bin6+bin8)/4 label All Ipsi', ...
        'bin21 = (bin9 + bin10 + bin11 + bin12)/4 label All Contra-Ipsi'});

    ERP.PO7_8_index = PO7_index;
    ERP.LO1_2_index = LO1_index;
    ERP.behavior = EEG.behavior;
    ERP.rejected_trials = logical(EEG.reject.rejmanual);
    % "A maximal residual EOG deviation exceeding +/- 2 µV would have led
    % to the disqualification of the subject."
    if abs(mean(ERP.bindata(ERP.LO1_2_index, :, 21))) >= 2
        ERP = pop_savemyerp(ERP, 'erpname', ['excluded' erp_name], 'filename', ['excluded_' erp_name '.erp'], 'filepath', [filepath filesep team filesep 'Excluded_ERP'], 'Warning', 'off'); %#ok<NASGU>
    else
        ERP = pop_savemyerp(ERP, 'erpname', erp_name, 'filename', [erp_name '.erp'], 'filepath', [filepath filesep team filesep 'ERP'], 'Warning', 'off'); %#ok<NASGU>
    end
end
