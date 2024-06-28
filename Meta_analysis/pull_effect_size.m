function pull_effect_size(team, pipeline, filepath)
    team_folder = [filepath filesep team filesep 'Results' filesep 'Pipeline' filesep pipeline filesep];
    res_color = load([team_folder 'results_colors.mat']);
    res_letters = load([team_folder 'results_letters.mat']);
    res_interaction = load([team_folder 'results_interaction.mat']);
    opts = detectImportOptions([filepath filesep 'Meta_analysis' filesep 'effect_sizes_' pipeline '.csv']);
    opts = setvartype(opts, ...
        ["Lab",    "ES_colors", "SE_colors", "ES_letters", "SE_letters", "ES_interaction", "SE_interaction"], ...
        ["string", "double",    "double",    "double",     "double",     "double",         "double"]);
    es_table = readtable([filepath filesep 'Meta_analysis' filesep 'effect_sizes_' pipeline '.csv'], opts);

    team_row = find(strcmpi(es_table.Lab, team)); %#ok<EFIND>
    if isempty(team_row)
        team_row = size(es_table, 1) + 1;
    end

    es_table.Lab(team_row) = team;
    es_table.ES_colors(team_row) = res_color.stats_amp_colors.gz.eff;
    es_table.SE_colors(team_row) = res_color.stats_amp_colors.gz.se;

    es_table.ES_letters(team_row) = res_letters.stats_amp_letters.gz.eff;
    es_table.SE_letters(team_row) = res_letters.stats_amp_letters.gz.se;

    es_table.ES_interaction(team_row) = res_interaction.stats_amp_interaction.gz.eff;
    es_table.SE_interaction(team_row) = res_interaction.stats_amp_interaction.gz.se;
    writetable(es_table, [filepath filesep 'Meta_analysis' filesep 'effect_sizes_' pipeline '.csv'], 'Delimiter', ',')
end