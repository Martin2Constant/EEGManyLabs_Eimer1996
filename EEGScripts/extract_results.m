function extract_results(filepath, team)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    files = dir(fullfile([team filesep 'ERP'], [team '_participant*.erp']));
    mean_rts = table('Size',[length(files), 2], ...
        'VariableTypes', {'double', 'double'}, ...
        'VariableNames', {'RT_letters', 'RT_colors'});
    for sub = 1:length(files)
        erp_name = files(sub).name;
        ERP = pop_loaderp( 'filename', erp_name, 'filepath', files(sub).folder);
        mean_rts = get_rts(ERP, mean_rts, sub);
        ALLERP(sub) = ERP;
    end
    
    [ALLERP, letters_amp] = pop_geterpvalues( ALLERP, [220 300],  [13 14], [ERP.PO7_8_index] , 'Baseline', 'pre', 'Erpsets', 1:length(ALLERP), 'FileFormat', 'wide', 'Filename',...
        [filepath filesep team filesep 'Results' filesep 'mean_amp_N2pc.txt'], 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  9 );
    [ALLERP, colors_amp] = pop_geterpvalues( ALLERP, [220 300],  [16 17], [ERP.PO7_8_index] , 'Baseline', 'pre', 'Erpsets', 1:length(ALLERP), 'FileFormat', 'wide', 'Filename',...
            [filepath filesep team filesep 'Results' filesep 'mean_amp_N2pc.txt'], 'Fracreplace', 'NaN', 'InterpFactor',  1, 'Measure', 'meanbl', 'PeakOnset',  1, 'Resolution',  9 );
    letters_contra_amp = letters_amp(1,:)';
    letters_ipsi_amp = letters_amp(2,:)';
    colors_contra_amp = colors_amp(1,:)';
    colors_ipsi_amp = colors_amp(2,:)';
    [mean_amps_letters, between_ci_amp_letters, within_ci_amp_letters, stats_amp_letters] = custom_paired_t_test(letters_contra_amp, letters_ipsi_amp);
    [mean_amps_colors, between_ci_amp_colors, within_ci_amp_colors, stats_amp_colors] = custom_paired_t_test(colors_contra_amp, colors_ipsi_amp);
    [mean_rt, between_ci_rt, within_ci_rt, stats_rt] = custom_paired_t_test(mean_rts.RT_letters, mean_rts.RT_colors);

end
