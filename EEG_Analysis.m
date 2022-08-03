function EEG_Analysis(Preprocess, ExtractResults, participant_list, filepath)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    % Using:
    % MATLAB R2022a
    % Statistics and Machine Learning Toolbox R2022a
    % Optimization Toolbox R2022a
    % Signal Processing Toolbox R2022a
    % EEGLAB version 2022.0
    % ERPLAB v9.00
    % For Asanowicz data import: Biosig v3.8.1
    % For Liesefeld data import: bva-io v1.71
    % For Essex data import: loadcurry v3.2.3
    % firfilt v2.5.1
    path_here = mfilename('fullpath');
    if nargin < 4
        filepath = fileparts(path_here);
    end
    if nargin < 3
        participant_list = [1];
    end
    if nargin < 2
        ExtractResults = true;
    end
    if nargin < 1
        Preprocess = true;
    end

    cd(filepath);
    addpath([filepath filesep 'EEGScripts']);
    if ~isfile('./bins.txt')
        createBins();
    end
    eeglab; close;
    msg = 'Which team?';
    opts = ["Liesefeld" "Asanowicz" "Essex"];
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
    pop_editoptions( 'option_savetwofiles', 0, 'option_single', 0);
    for participant_nr = participant_list
        if Preprocess
%             add_reaction_times(participant_nr, filepath, team)
%             filter_and_resample(participant_nr, filepath, team)
%             ICA(participant_nr, filepath, team)
             epoch_and_average(participant_nr, filepath, team)
        end
    end
    if ExtractResults
        extract_results(filepath, team)
    end
end
