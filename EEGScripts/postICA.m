function postICA(participant_nr, filepath)
    %% Initialize and load
    id = participant_nr;
    post_ica = sprintf('participant%i_postICA.set', id);
    processed = sprintf('participant%i_clean.set', id);
    erp_name = sprintf('participant%i', id);
    EEG = pop_loadset(post_ica, [filepath filesep 'EEG']);

    EEG = eeg_checkset( EEG );

    EEG  = pop_binlister( EEG , 'BDF', [filepath filesep 'bins.txt'], 'Ignore',  [], 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
% 
%     EEGcomps = pop_firws(EEG, 'fcutoff', 1, 'ftype', 'highpass', 'wtype', 'blackman', 'forder', 2750, 'minphase', 0, 'usefftfilt', 0, 'plotfresp', 0, 'causal', 0);
%     EEGcomps = eeg_checkset( EEGcomps );
%     EEGcomps2 = EEGcomps;
%     EEGcomps = pop_epochbin( EEGcomps , [-200.0  2000.0],  [-200 0]);
%     EEGcomps = eeg_checkset( EEGcomps );
% 
%     EEGcomps  = pop_artextval( EEGcomps , 'Channel', [13 14 18 19 43:45 47:49], 'Flag',  1, 'Threshold', [ -250 250], 'Twindow', [ -200 2000] );
% 
%     badIdx = find(EEGcomps.reject.rejmanual == 1);
%     if badIdx
%         EEGcomps = pop_rejepoch(EEGcomps, badIdx, 0);
%         EEGcomps  = pop_resetrej( EEGcomps , 'ResetArtifactFields', 'on' );
%         EEGcomps.icaact = [];
%     end
%     EEGcomps = eeg_checkset( EEGcomps );
%     EEGcomps = iclabel(EEGcomps, 'default');
%     [~, mostDominantClassLabelVector] = max(EEGcomps.etc.ic_classification.ICLabel.classifications, [], 2);
%     mostDominantClassLabelProbVector = zeros(length(mostDominantClassLabelVector),1);
%     for icIdx = 1:length(mostDominantClassLabelVector)
%         mostDominantClassLabelProbVector(icIdx)  = EEGcomps.etc.ic_classification.ICLabel.classifications(icIdx, mostDominantClassLabelVector(icIdx));
%     end
%     badBrainIdx  = find(mostDominantClassLabelVector == 3 | EEGcomps.etc.ic_classification.ICLabel.classifications(:,2) >= 0.90 );%| EEG.etc.ic_classification.ICLabel.classifications(:,4) >= 0.90 | EEG.etc.ic_classification.ICLabel.classifications(:,5) >= 0.90 | EEG.etc.ic_classification.ICLabel.classifications(:,6) >= 0.90 | EEG.etc.ic_classification.ICLabel.classifications(:,7) >= 0.90 );
% 
% %     EEGcomps2 = pop_firws(EEGcomps2, 'fcutoff', 30, 'ftype', 'lowpass', 'wtype', 'blackman', 'forder', 734, 'minphase', 0, 'usefftfilt', 0, 'plotfresp', 0, 'causal', 0);
%     EEGcomps2 = pop_epochbin( EEGcomps2 , [-200.0  1000.0],  'pre');
%     EEGcomps2 = pop_subcomp(EEGcomps2, badBrainIdx);
%     EEGcomps2 = eeg_checkset( EEGcomps2 );
%     EEGcomps2  = pop_artextval( EEGcomps2 , 'Channel', [13 14 18 19 43:45 47:49], 'Flag',  1, 'Threshold', [ -65 65], 'Twindow', [ -200 1000] );
%     EEGcomps2  = pop_artdiff( EEGcomps2 , 'Channel', [ 13 14 18 19 43:45 47:49], 'Flag',  1, 'Threshold',  50, 'Twindow', [ -200 1000] );

    EEG = pop_epochbin( EEG , [-200.0  1000.0],  'pre');

    EEG = eeg_checkset( EEG );
        EEG  = pop_artextval( EEG , 'Channel', [13 14 18 19 43:45 47:49], 'Flag',  1, 'Threshold', [ -65 65], 'Twindow', [ -200 1000] );
        EEG  = pop_artdiff( EEG, 'Channel', [ 13 14 18 19 43:45 47:49], 'Flag',  1, 'Threshold',  50, 'Twindow', [ -200 1000] );
%     EEG = pop_subcomp(EEG, badBrainIdx);

%     EEG.reject.rejmanual = EEGcomps2.reject.rejmanual;
%     for n = 1:length(EEGcomps2.EVENTLIST.eventinfo)
%         EEG.EVENTLIST.eventinfo(n).flag = EEGcomps2.EVENTLIST.eventinfo(n).flag;
%     end

    EEG = eeg_checkset( EEG , 'eventconsistency' );
    EEG = eeg_checkset( EEG );

    EEG = pop_saveset(EEG, 'filename', processed, 'filepath', [filepath filesep 'EEG']);

    EEG = eeg_checkset( EEG );
    ERP = pop_averager( EEG , 'Criterion', 'good', 'DQ_flag', 1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
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
    ERP = pop_binoperator( ERP, {'bin9 = bin1 - bin2 label M Contra-Ipsi',...
        'bin10 = bin3 - bin4 label W Contra-Ipsi',...
        'bin11 = bin5 - bin6 label Blue Contra-Ipsi',...
        'bin12 = bin7 - bin8 label Green Contra-Ipsi'});
    ERP = pop_binoperator( ERP, {'bin13 = (bin9 + bin10)/2 label Letters',...
        'bin14 = (bin11 + bin12)/2 label Colors'});
    ERP = pop_savemyerp(ERP, 'erpname', erp_name, 'filename', [erp_name '.erp'], 'filepath', [filepath filesep 'ERP'], 'Warning', 'off');
end