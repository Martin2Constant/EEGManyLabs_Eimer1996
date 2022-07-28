function extract_results(filepath, team)
    %% Initialize and load
    files = dir(fullfile([team filesep 'ERP'], [team '_participant*.erp']));
    for s = 1:length(files)
        erp_name = files(s).name;
        % Load ERP
        ERP = pop_loaderp( 'filename', erp_name, 'filepath', [filepath filesep team filesep 'ERP'] );
        ALLERP2(s) = ERP;
    end
    chanlocs = {ERP.chanlocs(:).labels}';
    PO7_8_index = find(strcmp(chanlocs, 'PO7/PO8'));
            
    % Collapsed localizer is all epochs and participants pooled together at
    % the computed Fc_COI electrode
    cfg.sign = -1; % Search in the negative polarities
    cfg.peakWidth = 4;
    % Extract 15% peak amplitude onset and offset
    cfg.extract = {'onset', 'offset'};
    cfg.percAmp = 0.15;
    cfg.times = ERP.times;
    % We search for a counter-peak because N1 does not necessarily go back to a baseline of 0 µV
    cfg.cWinWidth = 200;

    % Collapsed localizer made from the average of condition 1 and 2 which contain half of all trials each.
    cfg.condition = 1:2; 
    cfg.peakWin = [0 200]; % Search for N1 peak between 0 and 200ms
    cfg.aggregate = 'GA';
    cfg.chans = 69; %Fc_COI
    [res, ~] = latency(cfg, ALLERP2);
    
    onset = round(res.onset);
    offset = round(res.offset); 
    sprintf('N1 Onset: %i\nN1 Offset: %i\n', onset, offset)

    ALLERP2 = pop_geterpvalues( ALLERP2, [onset offset],  1:2, [69] , 'Baseline', 'pre', 'Erpsets', 1:length(ALLERP2), 'FileFormat', 'wide', 'Filename',...
        [filepath filesep 'Results' filesep 'mean_amp_N1.txt'], 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  9 );

    ALLERP2 = pop_geterpvalues( ALLERP2, [300 500],  3:4,  [69], 'Baseline', 'pre', 'Erpsets', 1:length(ALLERP2), 'FileFormat', 'wide', 'Filename',...
        [filepath filesep 'Results' filesep 'mean_amp_FN400.txt'], 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  9 );

end
