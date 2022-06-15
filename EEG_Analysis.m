function EEG_Analysis(Preprocessing, ERP, GA, participant_list, filepath)
    %     Run with these default arguments if not provided
    path_here = mfilename('fullpath');
    switch nargin
        case 4
            filepath = fileparts(path_here);
        case 3
            participant_list = [1];
            filepath = fileparts(path_here);
        case 2
            GA = 1;
            participant_list = [1];
            filepath = fileparts(path_here);
        case 1
            ERP = 1;
            GA = 1;
            filepath = fileparts(path_here);
            participant_list = [1];
        case 0
            Preprocessing = 1;
            ERP = 1;
            GA = 1;
            filepath = fileparts(path_here);
            participant_list = [1];
    end
    cd(filepath);
    addpath([filepath filesep 'EEGScripts']);
    eeglab; close;
    for participant_nr = participant_list
        if Preprocessing
             add_reaction_times(participant_nr, filepath, 1)
%              preICA(participant_nr, filepath)
%              AMICA(participant_nr, filepath)
%             postICA(participant_nr, filepath)
        end
        if ERP
            % pass
        end
    end
    if GA
        % pass
    end
end
