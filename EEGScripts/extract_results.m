function extract_results(filepath, team)
    %% Initialize and load
    files = dir(fullfile([team filesep 'ERP'], [team '_participant*.erp']));
    mean_rts = table('Size',[length(files), 2], ...
        'VariableTypes', {'double', 'double'}, ...
        'VariableNames', {'RT_letters', 'RT_colors'});

    for sub = 1:length(files)
        erp_name = files(sub).name;
        % Load ERP
        ERP = pop_loaderp( 'filename', erp_name, 'filepath', [filepath filesep team filesep 'ERP']);
        mean_rts = get_rts(ERP, mean_rts, sub);
        ALLERP2(sub) = ERP;
    end
    
    [ALLERP2, Amp] = pop_geterpvalues( ALLERP2, [220 300],  [15 18], [ERP.PO7_8_index] , 'Baseline', 'pre', 'Erpsets', 1:length(ALLERP2), 'FileFormat', 'wide', 'Filename',...
        [filepath filesep team filesep 'Results' filesep 'mean_amp_N2pc.txt'], 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  9 );
end
