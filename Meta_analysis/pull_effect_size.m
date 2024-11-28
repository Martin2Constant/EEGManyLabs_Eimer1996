function pull_effect_size(filepath, pipelines)
    teams = ["Auckland", "Essex", "GenevaKerzel", "GenevaKliegel", "Gent", "ZJU", "Hildesheim", "ItierLab", "KHas", "Krakow", "LSU", "Magdeburg", "Malaga", "Munich", "NCC_UGR", "Neuruppin", "Onera", "TrierCogPsy", "TrierKamp", "UNIMORE", "UniversityofVienna", "Verona"];
    for pipeline = pipelines
        pipeline = char(pipeline);
        for team = teams
            team = char(team);
            team_folder = [filepath filesep team filesep 'Results' filesep 'Pipeline' filesep pipeline filesep];
            res_color = load([team_folder 'results_colors.mat']);
            res_forms = load([team_folder 'results_forms.mat']);
            res_interaction = load([team_folder 'results_interaction.mat']);
            if pipeline == "Original" || pipeline == "ICA"
                if ~exist([filepath filesep 'Meta_analysis' filesep 'effect_sizes_' pipeline '.csv'], 'file')
                    fid = fopen([filepath filesep 'Meta_analysis' filesep 'effect_sizes_' pipeline '.csv'], 'w');
                    fprintf(fid, 'Lab, df, ES_colors, lower_color, upper_color, SE_colors, ES_forms, lower_forms, upper_forms, SE_forms, ES_interaction, lower_interaction, upper_interaction, SE_interaction, pval_colors, pval_forms, pval_interaction');
                    fclose(fid);
                end
                opts = detectImportOptions([filepath filesep 'Meta_analysis' filesep 'effect_sizes_' pipeline '.csv']);
                opts = setvartype(opts, ...
                    ["Lab",    "df",     "ES_colors", "lower_color", "upper_color", "SE_colors", "ES_forms", "lower_forms", "upper_forms", "SE_forms", "ES_interaction", "lower_interaction", "upper_interaction",  "SE_interaction", "pval_colors", "pval_forms", "pval_interaction"], ...
                    ["string", "double", "double",    "double",      "double",      "double",    "double",     "double",        "double",        "double",     "double",         "double",            "double",             "double",         "double",      "double",       "double"]);
                es_table = readtable([filepath filesep 'Meta_analysis' filesep 'effect_sizes_' pipeline '.csv'], opts);

                team_row = find(strcmpi(es_table.Lab, team)); %#ok<EFIND>
                if isempty(team_row)
                    team_row = size(es_table, 1) + 1;
                end

                es_table.Lab(team_row) = team;
                es_table.df(team_row) = res_color.stats_amp_colors.df;
                es_table.ES_colors(team_row) = res_color.stats_amp_colors.gz.eff;
                es_table.lower_color(team_row) = res_color.stats_amp_colors.gz.low_ci;
                es_table.upper_color(team_row) = res_color.stats_amp_colors.gz.high_ci;
                es_table.SE_colors(team_row) = res_color.stats_amp_colors.gz.se;

                es_table.ES_forms(team_row) = res_forms.stats_amp_forms.gz.eff;
                es_table.lower_forms(team_row) = res_forms.stats_amp_forms.gz.low_ci;
                es_table.upper_forms(team_row) = res_forms.stats_amp_forms.gz.high_ci;
                es_table.SE_forms(team_row) = res_forms.stats_amp_forms.gz.se;

                es_table.ES_interaction(team_row) = res_interaction.stats_amp_interaction.gz.eff;
                es_table.lower_interaction(team_row) = res_interaction.stats_amp_interaction.gz.low_ci;
                es_table.upper_interaction(team_row) = res_interaction.stats_amp_interaction.gz.high_ci;
                es_table.SE_interaction(team_row) = res_interaction.stats_amp_interaction.gz.se;

                es_table.pval_colors(team_row) = res_color.stats_amp_colors.p;
                es_table.pval_forms(team_row) = res_forms.stats_amp_forms.p;
                es_table.pval_interaction(team_row) = res_interaction.stats_amp_interaction.p;

                writetable(es_table, [filepath filesep 'Meta_analysis' filesep 'effect_sizes_' pipeline '.csv'], 'Delimiter', ',')

                if pipeline == "Original"
                    res_rt = load([team_folder 'results_rt.mat']);
                    res_correct = load([team_folder 'results_correct.mat']);
                    if ~exist([filepath filesep 'Meta_analysis' filesep 'effect_sizes_behavior.csv'], 'file')
                        fid = fopen([filepath filesep 'Meta_analysis' filesep 'effect_sizes_behavior.csv'], 'w');
                        fprintf(fid, 'Lab, df, ES_RT, lower_RT, upper_RT, SE_RT, ES_correct, lower_correct, upper_correct, SE_correct, pval_RT, pval_correct');
                        fclose(fid);
                    end
                    opts = detectImportOptions([filepath filesep 'Meta_analysis' filesep 'effect_sizes_behavior.csv']);
                    opts = setvartype(opts, ...
                        ["Lab",    "df",     "ES_RT",  "lower_RT", "upper_RT", "SE_RT",  "ES_correct", "lower_correct", "upper_correct", "SE_correct", "pval_RT", "pval_correct"], ...
                        ["string", "double", "double", "double",   "double",   "double", "double",     "double",        "double",         "double",    "double",  "double"]);
                    es_table = readtable([filepath filesep 'Meta_analysis' filesep 'effect_sizes_behavior.csv'], opts);

                    team_row = find(strcmpi(es_table.Lab, team)); %#ok<EFIND>
                    if isempty(team_row)
                        team_row = size(es_table, 1) + 1;
                    end

                    es_table.Lab(team_row) = team;
                    es_table.df(team_row) = res_rt.stats_rt_comparison.df;
                    es_table.ES_RT(team_row) = res_rt.stats_rt_comparison.gz.eff;
                    es_table.lower_RT(team_row) = res_rt.stats_rt_comparison.gz.low_ci;
                    es_table.upper_RT(team_row) = res_rt.stats_rt_comparison.gz.high_ci;
                    es_table.SE_RT(team_row) = res_rt.stats_rt_comparison.gz.se;

                    es_table.ES_correct(team_row) = res_correct.stats_correct_comparison.gz.eff;
                    es_table.lower_correct(team_row) = res_correct.stats_correct_comparison.gz.low_ci;
                    es_table.upper_correct(team_row) = res_correct.stats_correct_comparison.gz.high_ci;
                    es_table.SE_correct(team_row) = res_correct.stats_correct_comparison.gz.se;
                    writetable(es_table, [filepath filesep 'Meta_analysis' filesep 'effect_sizes_behavior.csv'], 'Delimiter', ',')
                end
            else
                fid = fopen([team_folder 'colors_output.txt'], 'r');
                file_str = fscanf(fid, '%s');
                fclose(fid);
                str_size = numel(pipeline) + numel(team) + numel('colors');
                onset = str2double(file_str(50+str_size:50+str_size+2));
                offset = str2double(file_str(58+str_size:58+str_size+2));
                times = -100:5:600;
                time_idx = dsearchn(times', [onset, offset]');
                onset = times(time_idx(1));
                offset = times(time_idx(2));
                load([team_folder 'pvalues_bootstrap.mat']);
                median_pval_forms = median(pval_forms);
                median_pval_colors = median(pval_colors);
                median_pval_difference = median(pval_difference);
                if ~exist([filepath filesep 'Meta_analysis' filesep 'effect_sizes_' pipeline '.csv'], 'file')
                    fid = fopen([filepath filesep 'Meta_analysis' filesep 'effect_sizes_' pipeline '.csv'], 'w');
                    fprintf(fid, 'Lab, df, ES_colors, lower_color, upper_color, SE_colors, ES_forms, lower_forms, upper_forms, SE_forms, ES_interaction, lower_interaction, upper_interaction, SE_interaction, pval_colors, pval_forms, pval_interaction, onset, offset');
                    fclose(fid);
                end
                opts = detectImportOptions([filepath filesep 'Meta_analysis' filesep 'effect_sizes_' pipeline '.csv']);
                opts = setvartype(opts, ...
                    ["Lab",    "df",     "ES_colors", "lower_color", "upper_color", "SE_colors", "ES_forms", "lower_forms", "upper_forms", "SE_forms", "ES_interaction", "lower_interaction", "upper_interaction",  "SE_interaction", "pval_colors", "pval_forms", "pval_interaction", "onset",  "offset"], ...
                    ["string", "double", "double",    "double",      "double",      "double",    "double",     "double",        "double",        "double",     "double",         "double",            "double",             "double",         "double",      "double",       "double",           "double", "double"]);
                es_table = readtable([filepath filesep 'Meta_analysis' filesep 'effect_sizes_' pipeline '.csv'], opts);

                team_row = find(strcmpi(es_table.Lab, team)); %#ok<EFIND>
                if isempty(team_row)
                    team_row = size(es_table, 1) + 1;
                end

                es_table.Lab(team_row) = team;
                es_table.df(team_row) = res_color.stats_amp_colors.df;
                es_table.ES_colors(team_row) = res_color.stats_amp_colors.gz.eff;
                es_table.lower_color(team_row) = res_color.stats_amp_colors.gz.low_ci;
                es_table.upper_color(team_row) = res_color.stats_amp_colors.gz.high_ci;
                es_table.SE_colors(team_row) = res_color.stats_amp_colors.gz.se;

                es_table.ES_forms(team_row) = res_forms.stats_amp_forms.gz.eff;
                es_table.lower_forms(team_row) = res_forms.stats_amp_forms.gz.low_ci;
                es_table.upper_forms(team_row) = res_forms.stats_amp_forms.gz.high_ci;
                es_table.SE_forms(team_row) = res_forms.stats_amp_forms.gz.se;

                es_table.ES_interaction(team_row) = res_interaction.stats_amp_interaction.gz.eff;
                es_table.lower_interaction(team_row) = res_interaction.stats_amp_interaction.gz.low_ci;
                es_table.upper_interaction(team_row) = res_interaction.stats_amp_interaction.gz.high_ci;
                es_table.SE_interaction(team_row) = res_interaction.stats_amp_interaction.gz.se;

                es_table.pval_colors(team_row) = median_pval_colors;
                es_table.pval_forms(team_row) = median_pval_forms;
                es_table.pval_interaction(team_row) = median_pval_difference;

                es_table.onset(team_row) = onset;
                es_table.offset(team_row) = offset;
                writetable(es_table, [filepath filesep 'Meta_analysis' filesep 'effect_sizes_' pipeline '.csv'], 'Delimiter', ',')
            end
        end
    end
end