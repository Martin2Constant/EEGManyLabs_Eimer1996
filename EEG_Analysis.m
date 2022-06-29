function EEG_Analysis(Preprocess, CreateAverage, ExtractResults, participant_list, filepath)
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
        CreateAverage = true;
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
    team = opts(choice);
    for participant_nr = participant_list
        if Preprocess
             add_reaction_times(participant_nr, filepath, team)
              preICA(participant_nr, filepath, team)
%              AMICA(participant_nr, filepath)
             postICA(participant_nr, filepath, team)
        end
        if CreateAverage
            % pass
        end
    end
    if ExtractResults
        % pass
    end
end
