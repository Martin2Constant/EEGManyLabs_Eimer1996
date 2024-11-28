function pull_amplitudes(filepath, pipelines)
    teams = ["Auckland", "Essex", "GenevaKerzel", "GenevaKliegel", "Gent", "ZJU", "Hildesheim", "ItierLab", "KHas", "Krakow", "LSU", "Magdeburg", "Malaga", "Munich", "NCC_UGR", "Neuruppin", "Onera", "TrierCogPsy", "TrierKamp", "UNIMORE", "UniversityofVienna", "Verona"];
    for pipeline = pipelines
        pipeline = char(pipeline);
        for team = teams
            team = char(team);
            team_folder = [filepath filesep team filesep 'Results' filesep 'Pipeline' filesep pipeline filesep];
            team_amplitudes = readtable([team_folder team '_amplitudes_table.csv']);
            if any(strcmp('Letters_contra',team_amplitudes.Properties.VariableNames))
                team_amplitudes = renamevars(team_amplitudes, ["Letters_contra", "Letters_ipsi", "Letters_Contra_Ipsi"], ["Forms_contra", "Forms_ipsi", "Forms_Contra_Ipsi"]);
                t_series = readtable([team_folder team '_time_series_table.csv']);
                t_series = renamevars(t_series, ["Letters_contra", "Letters_ipsi", "Letters_Contra_Ipsi"], ["Forms_contra", "Forms_ipsi", "Forms_Contra_Ipsi"]);
                writetable(team_amplitudes, [team_folder team '_amplitudes_table.csv'], 'Delimiter', ',');
                writetable(t_series, [team_folder team '_time_series_table.csv'], 'Delimiter', ',');
            end
            nb_part = size(team_amplitudes, 1);
            team_amplitudes.Lab = repmat(char(team), nb_part, 1);
            team_amplitudes.Pipeline = repmat(char(pipeline), nb_part, 1);

            if ~exist([filepath filesep 'Meta_analysis' filesep 'amplitudes_' pipeline '.csv'], 'file')
                fid = fopen([filepath filesep 'Meta_analysis' filesep 'amplitudes_' pipeline '.csv'], 'w');
                fprintf(fid, 'Forms_contra, Forms_ipsi, Colors_contra, Colors_ipsi, Forms_Contra_Ipsi, Colors_Contra_Ipsi, Lab, Pipeline');
                fclose(fid);
            end

            opts = detectImportOptions([filepath filesep 'Meta_analysis' filesep 'amplitudes_' pipeline '.csv']);
            opts = setvartype(opts, ...
                ["Forms_contra",    "Forms_ipsi", "Colors_contra", "Colors_ipsi", "Forms_Contra_Ipsi", "Colors_Contra_Ipsi", "Lab", "Pipeline"], ...
                ["double",            "double",       "double",         "double",     "double",               "double",           "string", "string"]);
            all_amplitudes = readtable([filepath filesep 'Meta_analysis' filesep 'amplitudes_' pipeline '.csv'], opts);
            if ~any(contains(string(all_amplitudes.Lab), team))
                all_amplitudes = [all_amplitudes; team_amplitudes];
                writetable(all_amplitudes, [filepath filesep 'Meta_analysis' filesep 'amplitudes_' pipeline '.csv'], 'Delimiter', ',')
            end
        end
    end
end