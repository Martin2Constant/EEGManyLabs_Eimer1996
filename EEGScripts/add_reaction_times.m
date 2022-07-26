function add_reaction_times(id, filepath, team)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    %
    switch team
        case 'Asanowicz'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%i.bdf', team, id);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%i.csv', team, id);
            filename_bdf = [filepath filesep team filesep 'RawData' filesep filename_eeg '.bdf'];
            % Importing with POz as temporary reference
            % Re-referenced to average mastoids at a later point.
            EEG = pop_biosig(filename_bdf, 'ref', 30);
        case 'Liesefeld'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%i.vhdr', team, id);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%i.csv', team, id);
            EEG = pop_loadbv([filepath filesep filesep team filesep 'RawData'], filename_eeg);
        case 'Essex'
            filename_eeg = sprintf('%s_EEG_Eimer1996_Sub%02i.cdt', team, id);
            filename_behavior = sprintf('%s_Behavior_Eimer1996_Sub%02i.csv', team, id);
            filename_cdt = [filepath filesep team filesep 'RawData' filesep filename_eeg];
            EEG = loadcurry(filename_cdt, 'KeepTriggerChannel', 'True', 'CurryLocations', 'False');
    end

    filename_tosave = sprintf('%s_participant%i_RT.set', team, id);
    % Add behavior table (without practice trials) to EEG object
    behavior = readtable([filepath filesep team filesep 'RawData' filesep filename_behavior]);
    behavior = behavior(behavior.Practice == 0, :);
    EEG.behavior = behavior;

    switch team
        case 'Asanowicz'
            eventlabels = {EEG.event(:).type}';
            % Remove marker offset; 65535 -> 255
            for i = 1:length(eventlabels)
                eventlabels{i} = eventlabels{i} - (2^16 - 2^8);
            end
            clean = eventlabels;
        case 'Liesefeld'
            eventlabels = {EEG.event(:).type}';
            % Remove the leading "S"; S255 -> 255
            clean = cellfun(@(s)sscanf(s,'S%d'), eventlabels, 'UniformOutput', false);
        case 'Essex'
            eventlabels = {EEG.event(:).type}';
            clean = eventlabels;
    end

    % Get each marker's latency
    latencies = {EEG.event(:).latency}';

    % Remove any empty marker
    idx_correct = ~cellfun(@isempty,clean);
    clean = clean(idx_correct);
    latencies = latencies(idx_correct);

    % Remove all markers with value 50 or 255
    idx_correct2 = ~cellfun(@(x) x==50 | x==255, clean);
    clean = clean(idx_correct2);
    latencies = latencies(idx_correct2);

    % Extract response times from behavior table
    response_times = EEG.behavior.response_time;

    % Initialize response latencies (i.e., that will be placed at the time
    % of response) instead of always being 2150 ms after display onset.
    response_latencies = nan(size(response_times));
    % Initialize an array of 70 to which we'll add the response correctness
    response_labels = ones(size(response_times))*70;


    idx = 1;

    for i = 1:length(clean)  % For all markers
        if clean{i} >= 100  % If marker >= 100 (display onsets)
            % Add display onset time (latencies{i}) to response_time from
            % behavior to create the EEG response_latency
            response_latencies(idx) = latencies{i} + response_times(idx);

            % The marker following display onset is coding correct (1),
            % incorrect (2) or timeout (3) responses.
            % We add that number to the array of 70.
            response_labels(idx) = response_labels(idx) + clean{i+1};
            idx = idx + 1;
        end
    end

    % Keep only non-NaN latencies and labels
    valid_latencies = find(~isnan(response_latencies));
    response_latencies = response_latencies(valid_latencies);
    response_labels = response_labels(valid_latencies);

    % Keep all markers above 70, thus removing the (1), (2), and (3)
    idx_correct3 = cellfun(@(x) x>70, clean);
    clean = clean(idx_correct3);
    latencies = latencies(idx_correct3);

    % Concatenate created markers (response) with remaining markers (display onset)
    newlabels = [clean; num2cell(response_labels)];
    newlatencies = [latencies; num2cell(response_latencies)];
    temptable = table(newlatencies, newlabels);
    % Sort according to latency
    temptable = sortrows(temptable);

    % Clear all markers in EEG object
    EEG.event = [];

    % Replace with our cleaned markers
    [EEG.event(1:length(temptable.newlabels)).type] = temptable.newlabels{:};
    [EEG.event(1:length(temptable.newlatencies)).latency] = temptable.newlatencies{:};

    % Check several times to make sure it's all compliant with EEGLAB expectations
    EEG = eeg_checkset(EEG);
    EEG = eeg_checkset(EEG,'makeur');
    EEG = eeg_checkset(EEG,'eventconsistency');
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset(EEG, 'filename', filename_tosave, 'filepath', [filepath filesep team filesep 'EEG']);
end
