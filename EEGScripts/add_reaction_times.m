function add_reaction_times(id, filepath, team)
    filename_raw = sprintf('%s_EimerSub%i', team, id);
    switch team
        case 'Asanowicz'
            filename_bdf = [filepath filesep team filesep 'RawData' filesep filename_raw '.bdf'];
            % Importing with POz as temporary reference
            % Re-referenced to average mastoids at a later point.
            EEG = pop_biosig(filename_bdf, 'ref', 30);
        case 'Liesefeld'
            filename_vhdr = [filename_raw '.vhdr'];
            EEG = pop_loadbv([filepath filesep filesep team filesep 'RawData'], filename_vhdr);
    end

    filename = sprintf('%s_participant%i_RT.set', team, id);
    filename_behavior = sprintf('%s.csv', filename_raw);
    behavior = readtable([filepath filesep team filesep 'RawData' filesep filename_behavior]);
    behavior = behavior(behavior.Practice == 0, :);
    EEG.behavior = behavior;

    switch team
        case 'Asanowicz'
            eventlabels = {EEG.event(:).type}';
            for i = 1:length(eventlabels)
                eventlabels{i} = eventlabels{i} - (2^16 - 2^8);
            end
            clean = eventlabels;
        case 'Liesefeld'
            eventlabels = {EEG.event(:).type}';
            clean = cellfun(@(s)sscanf(s,'S%d'), eventlabels, 'UniformOutput', false);
    end

    latencies = {EEG.event(:).latency}';

    idx_correct = ~cellfun(@isempty,clean);
    clean = clean(idx_correct);
    latencies = latencies(idx_correct);
    idx_correct2 = ~cellfun(@(x) x==50 | x==255, clean);
    clean = clean(idx_correct2);
    latencies = latencies(idx_correct2);

    response_times = EEG.behavior.response_time;

    response_latencies = nan(size(response_times));
    response_labels = ones(size(response_times))*70;
    idx = 1;
    for i = 1:length(clean)
        if clean{i} >= 100
            response_latencies(idx) = latencies{i} + response_times(idx);
            response_labels(idx) = response_labels(idx) + clean{i+1};
            idx = idx + 1;
        end
    end

    valid_latencies = find(~isnan(response_latencies));
    response_latencies = response_latencies(valid_latencies);
    response_labels = response_labels(valid_latencies);

    idx_correct3 = cellfun(@(x) x>70, clean);
    clean = clean(idx_correct3);
    latencies = latencies(idx_correct3);

    newlabels = [clean; num2cell(response_labels)];
    newlatencies = [latencies; num2cell(response_latencies)];
    temptable = table(newlatencies, newlabels);
    temptable = sortrows(temptable);

    EEG.event = [];
    [EEG.event(1:length(temptable.newlabels)).type] = temptable.newlabels{:};
    [EEG.event(1:length(temptable.newlatencies)).latency] = temptable.newlatencies{:};
    EEG = eeg_checkset(EEG);
    EEG = eeg_checkset(EEG,'makeur');
    EEG = eeg_checkset(EEG,'eventconsistency');
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset(EEG, 'filename', filename, 'filepath', [filepath filesep team filesep 'EEG']);
end
