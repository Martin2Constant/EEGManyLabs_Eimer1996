function eeg_analysis(preprocess, get_results, pipeline, participant_list, filepath)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    % Running on GNU/Linux Debian 10 with:
    % MATLAB R2021a
    % Statistics and Machine Learning Toolbox R2021a
    % Optimization Toolbox R2021a
    % Image Processing Toolbox R2021a
    % Signal Processing Toolbox R2021a
    % EEGLAB version 2022.1
    % ERPLAB v9.00
    % For Krakow data import: Biosig v3.8.1
    % For Munich data import: bva-io v1.71
    % For Essex data import: loadcurry v3.2.3
    % firfilt v2.6.0
    % clean_rawdata v2.7.0
    arguments
        preprocess logical = true;
        get_results logical = true;
        pipeline string = "Original"; % "Original", "Resample", "ICA" or "ICA+Resample"
        participant_list double = [1:28];
        filepath char = fileparts(mfilename('fullpath'));
    end
    cd(filepath);
    addpath([filepath filesep 'Analysis_Scripts']);
    if ~isfile('./bins.txt')
        create_bins();
    end
    eeglab; close;
    msg = 'Which team?';
    opts = ["Munich", "Krakow", "Essex"];
    choice = menu(msg, opts);
    team = char(opts(choice));
    if ~exist(team, 'dir')
        mkdir(team);
    end
    if ~exist(sprintf('%s%sERP', team, filesep), 'dir')
        mkdir(sprintf('%s%sERP', team, filesep));
    end
    if ~exist(sprintf('%s%sEEG', team, filesep), 'dir')
        mkdir(sprintf('%s%sEEG', team, filesep));
    end
    if ~exist(sprintf('%s%sResults%s%s_Pipeline', team, filesep, filesep, pipeline), 'dir')
        mkdir(sprintf('%s%sResults%s%s_Pipeline', team, filesep, filesep, pipeline));
    end
    if ~exist(sprintf('%s%sExcluded_ERP', team, filesep), 'dir')
        mkdir(sprintf('%s%sExcluded_ERP', team, filesep));
    end
    if ~exist(sprintf('%s%sRawData', team, filesep), 'dir')
        mkdir(sprintf('%s%sRawData', team, filesep));  % Place raw EEG and behavior file here
    end
    if ~exist(sprintf('%s%sAMICA', team, filesep), 'dir')
        mkdir(sprintf('%s%sAMICA', team, filesep));
    end
    % Change EEGLAB default options to keep double precision throughout
    % the pipeline and use the ERPLAB compatibility option.
    pop_editoptions('option_savetwofiles', 0, 'option_single', 0, 'option_boundary99', 1);
    for participant_nr = participant_list
        if preprocess
            import_data(participant_nr, filepath, team)
            filter_and_resample(participant_nr, filepath, team)
            if pipeline == "ICA" || pipeline == "ICA+Resample"
                AMICA(participant_nr, filepath, team, false)
            end
            epoch_and_average(participant_nr, filepath, team, pipeline)
        end
    end
    if get_results
        if pipeline == "Original" || pipeline == "ICA"
            extract_results(filepath, team, pipeline)
        elseif pipeline == "Resample" || pipeline == "ICA+Resample"
            create_resampled_erps(filepath, team, participant_list, pipeline)
        end
    end
end
