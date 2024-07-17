function eeg_analysis(pipeline, team, participant_list, preprocess, get_results, filepath)
    % Author: Martin Constant (martin.constant@unige.ch)
    % Running with:
    % MATLAB R2024a
    % Statistics and Machine Learning Toolbox R2024a
    % Optimization Toolbox R2024a
    % Image Processing Toolbox R2024a
    % Signal Processing Toolbox R2024a
    % Parallel Computing Toolbox R2024a
    % EEGLAB version 2024.0
    % ERPLAB v10.11
    % For BioSemi data import: Biosig v3.8.3
    % For BrainVision data import: bva-io v1.73
    % For NeuroScan data import: loadcurry v3.2.3
    % firfilt v2.8
    % clean_rawdata v2.91
    % AMICA v1.7.0
    % postAmicaUtility v2.1
    % ICLabel v1.6
    % latency v1.3.0 https://github.com/Liesefeld/latency/releases/tag/v1.3.0
    arguments
        pipeline string {mustBeMember(pipeline, ["Original", "Resample", "ICA", "ICA+Resample"])} = "Original";
        team char = ''
        participant_list double = [];
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
    opts = ["Munich", "Krakow", "Essex", "Gent", "ONERA", "GenevaKerzel", ...
        "GroupLC", "LSU", "Magdeburg", "Verona", "KHas", "TrierKamp", ...
        "UniversityofVienna", "TrierCogPsy", "Neuruppin", "Auckland", ...
        "ItierLab", "Malaga", "Hildesheim", "NCC_UGR", "UNIMORE", "GenevaKliegel"];
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
    if isempty(participant_list)
        file_id = fopen([filepath filesep team filesep 'participant_list.txt'], 'r');
        formatSpec = '%s';
        participant_list = fscanf(file_id, formatSpec, [1 Inf]);
        participant_list = eval(participant_list);
        fclose(file_id);
    end
    for participant_nr = participant_list
        if preprocess
            import_data(participant_nr, filepath, team)
            filter_and_downsample(participant_nr, filepath, team)
            if pipeline == "ICA" || pipeline == "ICA+Resample"
                AMICA(participant_nr, filepath, team, false)
            end
            epoch_and_average(participant_nr, filepath, team, pipeline)
        end
    end
    if get_results
        extract_results(filepath, team, pipeline)
    end
end
