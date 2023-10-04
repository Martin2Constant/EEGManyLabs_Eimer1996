function harmonize_markers(EEG, filepath)
    % Author: Martin Constant (martin.constant@unige.ch)
    switch EEG.team
        case 'Krakow'
            eventlabels = {EEG.event(:).type}';
            % Remove marker offset; 65535 -> 255
            for i = 1:length(eventlabels)
                eventlabels{i} = eventlabels{i} - (2^16 - 2^8);
            end
            clean = eventlabels;
        case 'Munich'
            eventlabels = {EEG.event(:).type}';
            % Remove the leading "S"; S255 -> 255
            clean = cellfun(@(s)sscanf(s, 'S%d'), eventlabels, 'UniformOutput', false);
        case 'Essex'
            eventlabels = {EEG.event(:).type}';
            clean = eventlabels;
        case 'Gent'
            eventlabels = {EEG.event(:).type}';
            clean = eventlabels;
        case 'ONERA'
            eventlabels = {EEG.event(:).type}';
            % Remove the leading "S"; S255 -> 255
            clean = cellfun(@(s)sscanf(s, 'S%d'), eventlabels, 'UniformOutput', false);
        case 'Geneva'
            eventlabels = {EEG.event(:).type}';
            % Remove the leading "S"; S255 -> 255
            clean = cellfun(@(s)sscanf(s, 'S%d'), eventlabels, 'UniformOutput', false);
        case 'GroupLC'
            eventlabels = {EEG.event(:).type}';
            clean = eventlabels;
        case 'LSU'
            eventlabels = {EEG.event(:).type}';
            clean = eventlabels;
        case 'Magdeburg'
            eventlabels = {EEG.event(:).type}';
            % Remove the leading "S"; S255 -> 255
            clean = cellfun(@(s)sscanf(s, 'S%d'), eventlabels, 'UniformOutput', false);
        otherwise
            error('Team not found');
    end

    % Get each marker's latency
    latencies = {EEG.event(:).latency}';

    % Remove any empty marker
    idx_correct = ~cellfun(@isempty,clean);
    clean = clean(idx_correct);
    latencies = latencies(idx_correct);

    % Remove all markers with value == 50 or >= 255
    idx_correct2 = ~cellfun(@(x) x==50 | x>=255, clean);
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
    EEG = eeg_checkset(EEG, 'makeur');
    EEG = eeg_checkset(EEG, 'eventconsistency');
    EEG = eeg_checkset(EEG);

    % Try to save in MAT files in v6 format, if it doesn't work, save in v7.3
    EEGs = EEG;
    lastwarn('');
    pop_editoptions('option_saveversion6', 1);
    EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', [filepath filesep EEG.team filesep 'EEG']); %#ok<*NASGU>
    if strcmpi(lastwarn, "Variable 'EEG' was not saved. For variables larger than 2GB use MAT-file version 7.3 or later.")
        pop_editoptions('option_saveversion6', 0);
        EEG = EEGs;
        EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', [filepath filesep EEG.team filesep 'EEG']);
        pop_editoptions('option_saveversion6', 1);
    end
end
