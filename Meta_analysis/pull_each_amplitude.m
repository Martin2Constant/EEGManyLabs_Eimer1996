function pull_each_amplitude(filepath, pipelines)
    teams = ["Auckland", "Essex", "GenevaKerzel", "GenevaKliegel", "Gent", "ZJU", "Hildesheim", "ItierLab", "KHas", "Krakow", "LSU", "Magdeburg", "Malaga", "Munich", "NCC_UGR", "Neuruppin", "Onera", "TrierCogPsy", "TrierKamp", "UNIMORE", "UniversityofVienna", "Verona"];
    for pipeline = pipelines
        pipeline = char(pipeline);
        for team = teams
            team = char(team);
            team_folder = [filepath filesep team filesep 'Results' filesep 'Pipeline' filesep pipeline filesep];
            team_amplitudes = readtable([team_folder team '_amplitudes_table.csv']);
            nb_part = size(team_amplitudes, 1);
            team_amplitudes.Lab = repmat(char(team), nb_part, 1);
            team_amplitudes.Pipeline = repmat(char(pipeline), nb_part, 1);

            if ~exist(sprintf('%s%sMeta_analysis%s%s', filepath, filesep, filesep, pipeline), 'dir')
                mkdir(sprintf('%s%sMeta_analysis%s%s', filepath, filesep, filesep, pipeline));
            end

            if ~exist([filepath filesep 'Meta_analysis' filesep pipeline filesep 'amplitudes_' pipeline '_' team '.csv'], 'file')
                fid = fopen([filepath filesep 'Meta_analysis' filesep pipeline filesep 'amplitudes_' pipeline '_' team '.csv'], 'w');
                fprintf(fid, 'Forms_contra, Forms_ipsi, Colors_contra, Colors_ipsi, Forms_Contra_Ipsi, Colors_Contra_Ipsi, Lab, Pipeline');
                fclose(fid);
            end

            opts = detectImportOptions([filepath filesep 'Meta_analysis' filesep pipeline filesep 'amplitudes_' pipeline '_' team '.csv']);
            opts = setvartype(opts, ...
                ["Forms_contra",    "Forms_ipsi", "Colors_contra", "Colors_ipsi", "Forms_Contra_Ipsi", "Colors_Contra_Ipsi", "Lab", "Pipeline"], ...
                ["double",            "double",       "double",         "double",     "double",               "double",           "string", "string"]);
            all_amplitudes = readtable([filepath filesep 'Meta_analysis' filesep pipeline filesep 'amplitudes_' pipeline '_' team '.csv'], opts);

            all_amplitudes = [team_amplitudes];
            writetable(all_amplitudes, [filepath filesep 'Meta_analysis' filesep pipeline filesep 'amplitudes_' pipeline '_' team '.csv'], 'Delimiter', ',')
        end
    end
end