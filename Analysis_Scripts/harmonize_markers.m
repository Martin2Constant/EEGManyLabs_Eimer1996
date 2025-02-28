function harmonize_markers(EEG, filepath)
    % Author: Martin Constant (martin.constant@unige.ch)
    %% Clean markers
    offset = 0;
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
        case 'GenevaKerzel'
            eventlabels = {EEG.event(:).type}';
            % Remove the leading "S"; S255 -> 255
            clean = cellfun(@(s)sscanf(s, 'S%d'), eventlabels, 'UniformOutput', false);
        case 'ZJU'
            eventlabels = {EEG.event(:).type}';
            clean = eventlabels;
        case 'LSU'
            eventlabels = {EEG.event(:).type}';
            clean = eventlabels;
        case 'Magdeburg'
            eventlabels = {EEG.event(:).type}';
            % Remove the leading "S"; S255 -> 255
            clean = cellfun(@(s)sscanf(s, 'S%d'), eventlabels, 'UniformOutput', false);
        case 'Verona'
            eventlabels = {EEG.event(:).type}';
            % Remove the leading "S"; S255 -> 255
            clean = cellfun(@(s)sscanf(s, 'S%d'), eventlabels, 'UniformOutput', false);
        case 'KHas'
            eventlabels = {EEG.event(:).type}';
            % Remove the leading "S"; S255 -> 255
            clean = cellfun(@(s)sscanf(s, 'S%d'), eventlabels, 'UniformOutput', false);
        case 'TrierKamp'
            eventlabels = {EEG.event(:).type}';
            % Remove the leading "S"; S255 -> 255
            clean = cellfun(@(s)sscanf(s, 'S%d'), eventlabels, 'UniformOutput', false);
        case 'UniversityofVienna'
            eventlabels = {EEG.event(:).type}';
            clean = eventlabels;
        case 'TrierCogPsy'
            offset = 37;
            eventlabels = {EEG.event(:).type}';
            clean = cellfun(@(s)sscanf(s, 'S%d'), eventlabels, 'UniformOutput', false);
        case 'Neuruppin'
            eventlabels = {EEG.event(:).type}';
            clean = cellfun(@(s)sscanf(s, 'S%d'), eventlabels, 'UniformOutput', false);
        case 'Auckland'
            if EEG.behavior.subject_nr(1) == 15 || EEG.behavior.subject_nr(1) == 32
                EEG = pop_select(EEG, 'nochannel', {'photosensor'});
                phIdx = find(strcmpi({EEG.chaninfo.removedchans.labels}, 'photosensor'));
                EEG.chaninfo.removedchans(phIdx) = [];
                EEG = eeg_checkset(EEG);
            else
                EEG = auckland_EEG_Eimer1996_realign_marker_code(EEG);
            end
            eventlabels = {EEG.event(:).type}';
            clean = cellfun(@(s)sscanf(s, 'T%d'), eventlabels, 'UniformOutput', false);
        case 'ItierLab'
            eventlabels = {EEG.event(:).type}';
            clean = eventlabels;
        case 'Malaga'
            eventlabels = {EEG.event(:).type}';
            clean = cellfun(@(s)sscanf(s, 'S%d'), eventlabels, 'UniformOutput', false);
        case 'Hildesheim'
            eventlabels = {EEG.event(:).type}';
            % Remove marker offset; 65535 -> 255
            for i = 1:length(eventlabels)
                eventlabels{i} = eventlabels{i} - (2^16 - 2^8);
            end
            clean = eventlabels;
        case 'NCC_UGR'
            eventlabels = {EEG.event(:).type}';
            clean = cellfun(@(s)sscanf(s, 'S%d'), eventlabels, 'UniformOutput', false);
        case 'UNIMORE'
            eventlabels = {EEG.event(:).type}';
            clean = cellfun(@(s)sscanf(s, 'S%d'), eventlabels, 'UniformOutput', false);
        case 'GenevaKliegel'
            eventlabels = {EEG.event(:).type}';
            clean = eventlabels;
        otherwise
            error('Team not found');
    end

    % Get each marker's latency
    latencies = {EEG.event(:).latency}';

    % Remove any empty cell
    idx_correct = ~cellfun(@isempty,clean);
    clean = clean(idx_correct);
    latencies = latencies(idx_correct);

    % If the first marker is not 255 or if there are more than one 255
    % If there's several 255, we assume the experiment was restarted and we
    % remove everything before the last restart of the experiment.
    % Else if there's only one 255, but it's not the first marker we remove
    % everything before it, assuming the experiment was started before the
    % recording, and then restarted.
    if any([clean{:}] == 255)
        if numel(find([clean{:}] == 255)) > 1
            markers_255 = find([clean{:}] == 255);
            last_255 = markers_255(end);
            if last_255 < 200
                clean(1:last_255) = [];
                latencies(1:last_255) = [];
            end
        elseif clean{1} ~= 255
            first_255 = find([clean{:}] == 255);
            if first_255 < 200
                clean(1:first_255) = [];
                latencies(1:first_255) = [];
            end
        end
    end

    % We find the 1st marker 50 (coding for display offset)
    % Every marker that happens more than 2 seconds before that first
    % display offset must likely be artifactual.
    % This cleaning happens after removing all markers that aren't wanted
    % and if there are more than the expected amount of markers (792*2).
    idx_50 = cellfun(@(x) x == 50, clean);
    latencies_50 = [latencies{idx_50}];
    first_50_lat = latencies_50(1);
    lat_too_low = first_50_lat - 2000;

    % Remove all markers that aren't wanted (sanity check)
    idx_correct2 = cellfun(@(x) x==1 | x==2 | x==3 | x==111 | x==112 | ...
        x==113 | x==121 | x==122 | x==123 | x==211 | x==212 | x==213 | ...
        x==221 | x==222 | x==223, clean);

    clean = clean(idx_correct2);
    latencies = latencies(idx_correct2);


    % Check that onset markers (> 3) are correctly placed (in odd
    % positions)
    % If they're not, there's likely a ghost markers somewhere, so we pull
    % the onset marker information from the behavioral file and search for the first
    % marker in an odd position that does not correspond to the expected
    % onset marker. The marker in position n-2 is likely the culprit so we
    % remove it.
    all_onsets = [clean{1:2:end}]';
    if class(EEG.behavior.onset_marker) == "double"
        all_beh_onsets = EEG.behavior.onset_marker;
    else
        % Convert cells of format {'[121]'} to double
        all_beh_onsets = double(strip(strip(string(EEG.behavior.onset_marker),'['),']'));
    end
    all_correct_response = EEG.behavior.correct;
    exit_loop = false;
    nb_responses = sum([clean{:}]<=3);
    nb_onsets = sum([clean{:}]>3);
    cnt = 0;
    while any(all_onsets <= 3) && ~exit_loop
        for x = 1:numel(all_onsets)
            if x <= size(all_beh_onsets, 1) && x <= size(all_onsets, 1)
                if all_onsets(x) ~= all_beh_onsets(x)
                    if size(clean, 1) >= 792*2
                        if x ~= 1
                            clean(x*2-2) = [];
                            latencies(x*2-2) = [];
                        else
                            clean(1) = [];
                            latencies(1) = [];
                        end
                    else
                        if x == 1
                            exit_loop = true;
                            break
                        end
                        if nb_responses < 792
                            if all_correct_response(x) == 0
                                if isnan(EEG.behavior.response_time(x))
                                    clean = [clean(1:x*2-2-1); {3}; clean(x*2-2:end)];
                                else
                                    clean = [clean(1:x*2-2-1); {2}; clean(x*2-2:end)];
                                end
                            else
                                clean = [clean(1:x*2-2-1); {1}; clean(x*2-2:end)];
                            end

                            latencies = [latencies(1:x*2-2-1); {latencies{x*2-2-1} + (2000 * EEG.srate / 1000)}; latencies(x*2-2:end)];
                        elseif nb_onsets < 792
                            % We're missing a marker for which we can't
                            % interpolate the timing so we just exit
                            exit_loop = true;
                            break
                        end
                    end

                    all_onsets = [clean{1:2:end}]';
                    break
                end
            else
                clean(end) = [];
                latencies(end) = [];
                all_onsets = [clean{1:2:end}]';
            end
        end
        cnt = cnt + 1;
        if cnt > 10000
            exit_loop=true;
        end
    end

    % Additional sanity check
    if size(all_onsets) == size(all_beh_onsets) & all(all_onsets > 3)
        if ~all(all_onsets == all_beh_onsets)
            error('The onset markers for participant %s do not match the ones from the behavioral file.', EEG.setname)
        end
    end
    if size(clean, 1) > 792*2
        idx_correct3 = cellfun(@(x) x > lat_too_low, latencies);
        clean = clean(idx_correct3);
        latencies = latencies(idx_correct3);
    end

    % Extract response times from behavior table (sub-ms precision)
    response_times = EEG.behavior.response_time;

    % Initialize response latencies (i.e., that will be placed at the time
    % of response) instead of always being 2150 ms after display onset.
    response_latencies = nan(size(response_times));
    % Initialize an array of 70 to which we'll add the response correctness
    response_labels = ones(size(response_times))*70;

    idx = 1;
    for i = 1:length(clean)  % For all markers
        if clean{i} >= 100  % If marker >= 100 (display onsets)
            % Add a timing-offset to display onset latencies (due to display timing issues)
            latencies{i} = latencies{i} + (offset * EEG.srate / 1000);
            % Add display onset time (latencies{i}) to response_time from
            % behavior to create the EEG response_latency, we have to scale
            % response_time (in ms) to the sampling rate.
            response_latencies(idx) = latencies{i} + (response_times(idx) * EEG.srate / 1000);

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

    % Keep all markers above 70, thus removing markers = (1), (2) or (3)
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
    EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', [filepath filesep EEG.team filesep 'EEG']); %#ok<*NASGU>
end
