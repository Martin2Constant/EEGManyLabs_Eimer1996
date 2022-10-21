function EEG_Analysis(Preprocess, ExtractResults, participant_list, filepath)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    % Using:
    % MATLAB R2022b
    % Statistics and Machine Learning Toolbox R2022b
    % Optimization Toolbox R2022b
    % Image Processing Toolbox R2022b
    % Signal Processing Toolbox R2022b
    % EEGLAB version 2022.1
    % ERPLAB v9.00
    % For Krakow data import: Biosig v3.8.1
    % For Munich data import: bva-io v1.71
    % For Essex data import: loadcurry v3.2.3
    % firfilt v2.6.0
    arguments
        Preprocess logical = true;
        ExtractResults logical = true;
        participant_list double = [1];
        filepath char = fileparts(mfilename('fullpath'));
    end
    cd(filepath);
    addpath([filepath filesep 'EEGScripts']);
    if ~isfile('./bins.txt')
        createBins();
    end
    eeglab; close;
    msg = 'Which team?';
    opts = ["Munich" "Krakow" "Essex"];
    choice = menu(msg, opts);
    team = char(opts(choice));
    if ~exist(team, 'dir')
        mkdir(team);
        mkdir(sprintf('%s%sERP', team, filesep))
        mkdir(sprintf('%s%sEEG', team, filesep))
        mkdir(sprintf('%s%sResults', team, filesep))
        mkdir(sprintf('%s%sExcluded_ERP', team, filesep))
        mkdir(sprintf('%s%sRawData', team, filesep))  % Place raw EEG and behavior file here
    end
    % Change EEGLAB default options to keep double precision throughout the pipeline.
    pop_editoptions('option_savetwofiles', 0, 'option_single', 0);
    for participant_nr = participant_list
        if Preprocess
            add_reaction_times(participant_nr, filepath, team)
            filter_and_resample(participant_nr, filepath, team)
            epoch_and_average(participant_nr, filepath, team)
        end
    end
    if ExtractResults
        extract_results(filepath, team)
    end
end
