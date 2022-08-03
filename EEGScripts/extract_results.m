function extract_results(filepath, team)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    files = dir(fullfile(['ERP'], ['participant*.erp']));
    mean_rts = table('Size',[length(files), 2], ...
        'VariableTypes', {'double', 'double'}, ...
        'VariableNames', {'RT_letters', 'RT_colors'});
    ALLERP = buildERPstruct([]);
    for sub = 1:length(files)
        erp_name = files(sub).name;
        ERP = pop_loaderp('filename', erp_name, 'filepath', files(sub).folder);
        %mean_rts = get_rts(ERP, mean_rts, sub);
        ALLERP(sub) = ERP;
    end
    
    [ALLERP, letters_amp] = pop_geterpvalues(ALLERP, [220 300], [5 6], [44] , 'Baseline', 'pre', 'Erpsets', 1:length(ALLERP), 'FileFormat', 'wide', 'Filename',...
        [filepath filesep team filesep 'Results' filesep 'mean_amp_N2pc.txt'], 'Fracreplace', 'NaN', 'InterpFactor', 1, 'Measure', 'meanbl', 'PeakOnset', 1, 'Resolution', 9);
    [ALLERP, colors_amp] = pop_geterpvalues(ALLERP, [220 300], [3 4], [44] , 'Baseline', 'pre', 'Erpsets', 1:length(ALLERP), 'FileFormat', 'wide', 'Filename',...
            [filepath filesep team filesep 'Results' filesep 'mean_amp_N2pc.txt'], 'Fracreplace', 'NaN', 'InterpFactor', 1, 'Measure', 'meanbl', 'PeakOnset', 1, 'Resolution', 9);
    letters_contra_amp = letters_amp(1,:)';
    letters_ipsi_amp = letters_amp(2,:)';
    colors_contra_amp = colors_amp(1,:)';
    colors_ipsi_amp = colors_amp(2,:)';
    [mean_amps_letters, confidence_intervals_letters, stats_letters] = custom_paired_t_test(letters_contra_amp, letters_ipsi_amp)
    [mean_amps_colors, confidence_intervals_colors, stats_colors] = custom_paired_t_test(colors_contra_amp, colors_ipsi_amp)

end
