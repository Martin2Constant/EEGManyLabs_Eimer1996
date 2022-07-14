function EEG_Analysis(Preprocess, CreateGrandAverage, ExtractResults, participant_list, filepath)
    %     Run with these default arguments if not provided
    path_here = mfilename('fullpath');
    if nargin < 5
        filepath = fileparts(path_here);
    end
    if nargin < 4
        participant_list = [1:2];
    end
    if nargin < 3
        ExtractResults = true;
    end
    if nargin < 2
        CreateGrandAverage = true;
    end
    if nargin < 1
        Preprocess = true;
    end

    cd(filepath);
    addpath([filepath filesep 'EEGScripts']);
    eeglab; close;
    msg = 'Which team?';
    opts = ["Liesefeld" "Asanowicz"];
    choice = menu(msg, opts);
    team = char(opts(choice));
    if ~exist(team, 'dir')
        mkdir(team);
        mkdir(sprintf('%s%sERP',team, filesep))
        mkdir(sprintf('%s%sEEG',team, filesep))
        mkdir(sprintf('%s%sResults',team, filesep))
        mkdir(sprintf('%s%sExcluded_ERP',team, filesep))
    end

    for participant_nr = participant_list
        if Preprocess
            add_reaction_times(participant_nr, filepath, team)
            filter_and_resample(participant_nr, filepath, team)
            epoch_and_average(participant_nr, filepath, team)
        end
        if CreateGrandAverage
            % pass
        end
    end
    if ExtractResults
        % pass
    end
end
