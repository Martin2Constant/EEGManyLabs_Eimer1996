function extract_results_from_multiple_timewindows(filepath, team)
    % Author: Martin Constant (martin.constant@unige.ch)
    arguments
        filepath char;
        team char;
    end
    pipeline = 'Original';
    files = dir(fullfile([filepath filesep team filesep 'ERP' filesep char(pipeline)], [team '_participant*_' pipeline '.erp']));
    participant_list = [];
    for id = 1:length(files)
        erp_name = files(id).name;
        participant_list = [participant_list, str2double(extractBetween(erp_name, "participant", "_"))];
        ERP = pop_loaderp( 'filename', erp_name, 'filepath', files(id).folder);
        ALLERP(id) = ERP; %#ok<AGROW>
    end

    % Create output file if it doesn't exist
    if ~exist([filepath filesep 'multiple_time_windows.csv'], 'file')
        fid = fopen([filepath filesep 'multiple_time_windows.csv'], 'w');
        fprintf(fid, 'Team, Condition, Paper, TimeWindow, Replicated, gz');
        fclose(fid);
    end
    opts = detectImportOptions([filepath filesep 'multiple_time_windows.csv']);
    opts = setvartype(opts, ...
        ["Team",   "Condition", "Paper", "TimeWindow", "Replicated", "gz"], ...
        ["string", "string",   "string",    "string",   "double",     "double"]);

    % Load the existing output file and append new results to it
    multiple_time_windows = readtable([filepath filesep 'multiple_time_windows.csv'], opts);
    n = length(ALLERP);
    df = n - 1;
    Jv = exp(gammaln(df / 2) - (log(sqrt(df / 2)) + gammaln((df - 1) / 2)));

    twindows = readtable([filepath filesep 'twindows.csv']);
    papers = twindows.Paper;
    for idx = 1:numel(papers)
        paper = papers{idx};
        onset = twindows.onset(idx);
        offset = twindows.offset(idx);
        cfg = {};
        cfg.sign = -1; % Search in the negative polarities
        cfg.extract = {'mean'};
        cfg.times = ERP.times;
        cfg.timeFormat = 'ms';
        cfg.areaBase = 'zero';
        cfg.condition = 15; % Forms
        cfg.meanWin = [onset offset];
        cfg.aggregate = 'individual';
        cfg.warnings = false;
        cfg.chans = ERP.PO7_8_index;
        [res_forms, ~] = latency(cfg, ALLERP); % Liesefeld (2018), Frontiers in Neuroscience
        cfg.condition = 18; % Colors
        [res_colors, ~] = latency(cfg, ALLERP);

        forms_amp = res_forms.mean;
        colors_amp = res_colors.mean;

        [~, p, ~, stats_amp_forms] = ttest(forms_amp, 0, "Tail", "left");
        stats_amp_forms.p = p;
        stats_amp_forms.gz.eff = stats_amp_forms.tstat / sqrt(n) * Jv;

        [~, p, ~, stats_amp_colors] = ttest(colors_amp, 0, "Tail", "left");
        stats_amp_colors.p = p;
        stats_amp_colors.gz.eff = stats_amp_colors.tstat / sqrt(n) * Jv;

        [~, p, ~, stats_amp_interaction] = ttest(forms_amp, colors_amp, "Tail", "left");
        stats_amp_interaction.p = p;
        stats_amp_interaction.gz.eff = stats_amp_interaction.tstat / sqrt(n) * Jv;


        for condition = ["colors", "forms", "interaction"]
            twin = sprintf("%i -- %i ms", onset, offset);
            team_row = find(strcmpi(multiple_time_windows.Team, team) & strcmpi(multiple_time_windows.Condition, condition) & strcmpi(multiple_time_windows.TimeWindow, twin)); %#ok<EFIND>
            if isempty(team_row)
                team_row = size(multiple_time_windows, 1) + 1;
            end

            multiple_time_windows.Team(team_row) = team;
            multiple_time_windows.Condition(team_row) = condition;
            multiple_time_windows.Paper(team_row) = paper;
            multiple_time_windows.TimeWindow(team_row) = twin;

            if condition == "colors"
                stat = stats_amp_colors;
            elseif condition == "forms"
                stat = stats_amp_forms;
            elseif condition == "interaction"
                stat = stats_amp_interaction;
            end
            if stat.p <= .02
                multiple_time_windows.Replicated(team_row) = 1;
            else
                multiple_time_windows.Replicated(team_row)= 0;
            end

            multiple_time_windows.gz(team_row) = stat.gz.eff;

        end
    end
    writetable(multiple_time_windows, [filepath filesep 'multiple_time_windows.csv'], 'Delimiter', ',')
end
