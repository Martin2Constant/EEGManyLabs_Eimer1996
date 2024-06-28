function pull_amplitudes(team, pipeline, filepath)
    team_folder = [filepath filesep team filesep 'Results' filesep 'Pipeline' filesep pipeline filesep];
    team_amplitudes = readtable([team_folder team '_amplitudes_table.csv']);
    nb_part = size(team_amplitudes, 1);
    team_amplitudes.Lab = repmat(char(team), nb_part, 1);
    team_amplitudes.Pipeline = repmat(char(pipeline), nb_part, 1);

    if ~exist([filepath filesep 'Meta_analysis' filesep 'amplitudes_' pipeline '.csv'], 'file')
        fid = fopen([filepath filesep 'Meta_analysis' filesep 'amplitudes_' pipeline '.csv'], 'w');
        fprintf(fid, 'Letters_contra, Letters_ipsi, Colors_contra, Colors_ipsi, Letters_Contra_Ipsi, Colors_Contra_Ipsi, Lab, Pipeline');
        fclose(fid);
    end

    opts = detectImportOptions([filepath filesep 'Meta_analysis' filesep 'amplitudes_' pipeline '.csv']);
    opts = setvartype(opts, ...
        ["Letters_contra",    "Letters_ipsi", "Colors_contra", "Colors_ipsi", "Letters_Contra_Ipsi", "Colors_Contra_Ipsi", "Lab", "Pipeline"], ...
        ["double",            "double",       "double",         "double",     "double",               "double",           "string", "string"]);
    all_amplitudes = readtable([filepath filesep 'Meta_analysis' filesep 'amplitudes_' pipeline '.csv'], opts);

    all_amplitudes = [all_amplitudes; team_amplitudes];
    writetable(all_amplitudes, [filepath filesep 'Meta_analysis' filesep 'amplitudes_' pipeline '.csv'], 'Delimiter', ',')
end