function create_output_table(filepath, pipelines)
    teams = ["Auckland", "Essex", "GenevaKerzel", "GenevaKliegel", "Gent", "ZJU", "Hildesheim", "ItierLab", "KHas", "Krakow", "LSU", "Magdeburg", "Malaga", "Munich", "NCC_UGR", "Neuruppin", "Onera", "TrierCogPsy", "TrierKamp", "UNIMORE", "UniversityofVienna", "Verona"];
    for pipeline = pipelines
        pipeline = char(pipeline);
        if pipeline == "Original" || pipeline == "ICA"
            if ~exist([filepath filesep 'Meta_analysis' filesep 'results_' pipeline '.csv'], 'file')
                fid = fopen([filepath filesep 'Meta_analysis' filesep 'results_' pipeline '.csv'], 'w');
                fprintf(fid, 'Lab, Condition, t, df, p, gz, BF, pval_meta, tval_meta');
                fclose(fid);
            end
            opts = detectImportOptions([filepath filesep 'Meta_analysis' filesep 'results_' pipeline '.csv']);
            opts = setvartype(opts, ...
                ["Lab",    "Condition",  "t",      "df",   "p",      "gz",     "BF",     "pval_meta", "tval_meta"], ...
                ["string", "string",     "string", "int8", "string", "string", "double", "double",    "double"]);
            es_table = readtable([filepath filesep 'Meta_analysis' filesep 'results_' pipeline '.csv'], opts);
            for condition = ["colors", "forms", "interaction"]
                for team = teams
                    team = char(team);
                    team_folder = [filepath filesep team filesep 'Results' filesep 'Pipeline' filesep pipeline filesep];
                    res_colors = load([team_folder 'results_colors.mat']);
                    res_forms = load([team_folder 'results_forms.mat']);
                    res_interaction = load([team_folder 'results_interaction.mat']);
                    team_row = find(strcmpi(es_table.Lab, team) & strcmpi(es_table.Condition, condition)); %#ok<EFIND>
                    if isempty(team_row)
                        team_row = size(es_table, 1) + 1;
                    end

                    es_table.Lab(team_row) = team;
                    es_table.Condition(team_row) = condition;
                    if condition == "colors"
                        stat = res_colors.stats_amp_colors;
                    elseif condition == "forms"
                        stat = res_forms.stats_amp_forms;
                    elseif condition == "interaction"
                        stat = res_interaction.stats_amp_interaction;
                    end
                    p = strip(sprintf('%.3f', stat.p), 'left', '0');
                    if strcmpi(p, '.000')
                        p = '< .001';
                    elseif strcmpi(p, '1.000')
                        p = '> .999';
                    end
                    es_table.p(team_row) = p;
                    gz = sprintf('%.2f [%.2f, %.2f]', stat.gz.eff, stat.gz.low_ci, stat.gz.high_ci);
                    es_table.gz(team_row) = gz;
                    es_table.df(team_row) = stat.df;
                    t = sprintf('%.2f', stat.t);
                    es_table.t(team_row) = t;
                    es_table.BF(team_row) = nan;
                end
            end
            writetable(es_table, [filepath filesep 'Meta_analysis' filesep 'results_' pipeline '.csv'], 'Delimiter', ',');
            if pipeline == "Original"
                if ~exist([filepath filesep 'Meta_analysis' filesep 'results_behavior.csv'], 'file')
                    fid = fopen([filepath filesep 'Meta_analysis' filesep 'results_behavior.csv'], 'w');
                    fprintf(fid, 'Lab, Condition, t, df, p, gz, BF, pval_meta, tval_meta');
                    fclose(fid);
                end
                opts = detectImportOptions([filepath filesep 'Meta_analysis' filesep 'results_behavior.csv']);
                opts = setvartype(opts, ...
                    ["Lab",    "Condition",  "t",      "df",   "p",      "gz",     "BF",     "pval_meta", "tval_meta"], ...
                    ["string", "string",     "string", "int8", "string", "string", "double", "double",    "double"]);
                behavior_table = readtable([filepath filesep 'Meta_analysis' filesep 'results_behavior.csv'], opts);
                for condition = ["rt", "correct"]
                    for team = teams
                        team = char(team);
                        team_folder = [filepath filesep team filesep 'Results' filesep 'Pipeline' filesep pipeline filesep];
                        res_rt = load([team_folder 'results_rt.mat']);
                        res_correct = load([team_folder 'results_correct.mat']);
                        team_row = find(strcmpi(behavior_table.Lab, team) & strcmpi(behavior_table.Condition, condition)); %#ok<EFIND>
                        if isempty(team_row)
                            team_row = size(behavior_table, 1) + 1;
                        end

                        behavior_table.Lab(team_row) = team;
                        behavior_table.Condition(team_row) = condition;
                        if condition == "rt"
                            stat = res_rt.stats_rt_comparison;
                        elseif condition == "correct"
                            stat = res_correct.stats_correct_comparison;
                        end
                        p = strip(sprintf('%.3f', stat.p), 'left', '0');
                        if strcmpi(p, '.000')
                            p = '< .001';
                        elseif strcmpi(p, '1.000')
                            p = '> .999';
                        end
                        behavior_table.p(team_row) = p;
                        gz = sprintf('%.2f [%.2f, %.2f]', stat.gz.eff, stat.gz.low_ci, stat.gz.high_ci);
                        behavior_table.gz(team_row) = gz;
                        behavior_table.df(team_row) = stat.df;
                        t = sprintf('%.2f', stat.t);
                        behavior_table.t(team_row) = t;
                        behavior_table.BF(team_row) = nan;
                    end
                end
                writetable(behavior_table, [filepath filesep 'Meta_analysis' filesep 'results_behavior.csv'], 'Delimiter', ',');
            end
        elseif pipeline == "Resample" || pipeline == "ICA+Resample"
            if ~exist([filepath filesep 'Meta_analysis' filesep 'results_' pipeline '.csv'], 'file')
                fid = fopen([filepath filesep 'Meta_analysis' filesep 'results_' pipeline '.csv'], 'w');
                fprintf(fid, 'Lab, Condition, time_window, t, df, p, gz, BF, pval_meta, tval_meta, paramP');
                fclose(fid);
            end
            opts = detectImportOptions([filepath filesep 'Meta_analysis' filesep 'results_' pipeline '.csv']);
            opts = setvartype(opts, ...
                ["Lab",    "Condition", "time_window",  "t",      "df",   "p",      "gz",     "BF",     "pval_meta", "tval_meta", "paramP"], ...
                ["string", "string",    "string",       "string", "int8", "string", "string", "double", "double",    "double",    "double"]);
            es_table = readtable([filepath filesep 'Meta_analysis' filesep 'results_' pipeline '.csv'], opts);
            for condition = ["colors", "forms", "interaction"]
                for team = teams
                    team = char(team);
                    team_folder = [filepath filesep team filesep 'Results' filesep 'Pipeline' filesep pipeline filesep];
                    res_colors = load([team_folder 'results_colors.mat']);
                    res_forms = load([team_folder 'results_forms.mat']);
                    res_interaction = load([team_folder 'results_interaction.mat']);
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
                    team_row = find(strcmpi(es_table.Lab, team) & strcmpi(es_table.Condition, condition)); %#ok<EFIND>
                    if isempty(team_row)
                        team_row = size(es_table, 1) + 1;
                    end
                    es_table.Lab(team_row) = team;
                    es_table.Condition(team_row) = condition;
                    es_table.time_window(team_row) = sprintf('%i -- %i ms', onset, offset);
                    if condition == "colors"
                        stat = res_colors.stats_amp_colors;
                        p = strip(sprintf('%.3f', median_pval_colors), 'left', '0');
                        if strcmpi(p, '.000')
                            p = '< .001';
                        elseif strcmpi(p, '1.000')
                            p = '> .999';
                        end
                    elseif condition == "forms"
                        stat = res_forms.stats_amp_forms;
                        p = strip(sprintf('%.3f', median_pval_forms), 'left', '0');
                        if strcmpi(p, '.000')
                            p = '< .001';
                        elseif strcmpi(p, '1.000')
                            p = '> .999';
                        end
                    elseif condition == "interaction"
                        stat = res_interaction.stats_amp_interaction;
                        p = strip(sprintf('%.3f', median_pval_difference), 'left', '0');
                        if strcmpi(p, '.000')
                            p = '< .001';
                        elseif strcmpi(p, '1.000')
                            p = '> .999';
                        end
                    end
                    es_table.p(team_row) = p;
                    gz = sprintf('%.2f [%.2f, %.2f]', stat.gz.eff, stat.gz.low_ci, stat.gz.high_ci);
                    es_table.gz(team_row) = gz;
                    es_table.df(team_row) = stat.df;
                    t = sprintf('%.2f', stat.t);
                    es_table.t(team_row) = t;
                    es_table.BF(team_row) = nan;
                    es_table.paramP(team_row) = stat.p;
                end
            end
            writetable(es_table, [filepath filesep 'Meta_analysis' filesep 'results_' pipeline '.csv'], 'Delimiter', ',');
        end
    end
end