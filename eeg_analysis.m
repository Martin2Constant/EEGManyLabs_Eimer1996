function eeg_analysis(pipeline, team, participant_list, preprocess, get_results, filepath)
    % Author: Martin Constant (martin.constant@unige.ch)
    % Running with:
    % MATLAB R2023b
    % Statistics and Machine Learning Toolbox R2023b
    % Optimization Toolbox R2023b
    % Image Processing Toolbox R2023b
    % Signal Processing Toolbox R2023b
    % Parallel Computing Toolbox R2023b
    % EEGLAB version 2023.1
    % ERPLAB v10.04
    % For BioSemi data import: Biosig v3.8.1
    % For BrainVision data import: bva-io v1.72
    % For NeuroScan data import: loadcurry v3.2.3
    % firfilt v2.7.1
    % clean_rawdata v2.91
    % AMICA v1.7.0
    % postAmicaUtility v2.1
    % ICLabel v1.4
    % latency v1.3.0 https://github.com/Liesefeld/latency/releases/tag/v1.3.0
    arguments
        pipeline string {mustBeMember(pipeline, ["Original", "Resample", "ICA", "Resample"])} = "Original";
        team char = ''
        participant_list double = [1:28];
        preprocess logical = true;
        get_results logical = true;
        filepath char = fileparts(mfilename('fullpath'));    
    end
    cd(filepath);
    addpath([filepath filesep 'Analysis_Scripts']);
    addpath([filepath filesep 'helpers']);

    if ~isfile('./bins.txt')
        create_bins();
    end
    eeglab; close;
    msg = 'Which team?';
    opts = ["Munich", "Krakow", "Essex", "Gent", "ONERA", "Geneva", ...
        "GroupLC", "LSU", "Magdeburg", "Verona", "KHas", "TrierKamp", ...
        "UniWien", "TrierCogPsy", "Neuruppin", "Auckland", "Bern", ...
        "ItierLab", "Malaga"];
    if isempty(team)
        choice = menu(msg, opts);
        team = char(opts(choice));
    end
    if ~exist(team, 'dir')
        mkdir(team);
    end
    if ~exist(sprintf('%s%sERP%s%s', team, filesep, filesep, pipeline), 'dir')
        mkdir(sprintf('%s%sERP%s%s', team, filesep, filesep, pipeline));
    end
    if ~exist(sprintf('%s%sEEG', team, filesep), 'dir')
        mkdir(sprintf('%s%sEEG', team, filesep));
    end
    if ~exist(sprintf('%s%sResults%sPipeline%s%s', team, filesep, filesep, filesep, pipeline), 'dir')
        mkdir(sprintf('%s%sResults%sPipeline%s%s', team, filesep, filesep, filesep, pipeline));
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
            filter_and_downsample(participant_nr, filepath, team, pipeline)
            if pipeline == "ICA" || pipeline == "ICA+Resample"
                AMICA(participant_nr, filepath, team, false, pipeline)
            end
            epoch_and_average(participant_nr, filepath, team, pipeline)
        end
    end
    if get_results
        extract_results(filepath, team, pipeline, participant_list)
    end
end
