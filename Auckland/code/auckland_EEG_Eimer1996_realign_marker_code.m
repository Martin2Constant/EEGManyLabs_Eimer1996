function EEG = auckland_EEG_Eimer1996_realign_marker_code(EEG)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    Eimer 1996 N2pc replication - Markers realignement to photosensor    %
    %                                                                         %
    % Script to verify marker-stimulus delays and re-align the events         %
    % according to the photosensor signal                                     %
    % Author: Daniele Scanzi
    % Modified by: Martin Constant (martin.constant@unige.ch)

    %% Settings
    screenRefreshRate = 60;  % Hz
    % Maximum stimulus-marker delay acceptable (ms) - Here set to 1 frame
    delay_tolerance   = (1 / screenRefreshRate) * 1000;
    % markers to re-align
    markers_to_align   = {'T111', 'T112', 'T113', 'T121', 'T122', 'T123',...
        'T211', 'T212', 'T213', 'T221', 'T222', 'T223'};
    % Name of the photosensor channel
    photo_trigger_name  = 'photoTrigger';

    % Minimum height for a peak to be considered valid. Useful to exclude
    % accidental peaks, e.g., changes in contrast at experiment start-up.
    min_peak_height = 0.8;

    %% Sanity check
    % First we check that all markers are within reasonable delays.
    % The acceptable threshold is quite conservative (delays should be
    % within one screen refresh, 16.66ms). Useful to spot potential errors
    % or differences across markers. For instance, some markers might have
    % a higher delay due to the way they are coded.
    [latency_info, ~] = trigger_photo_latency(EEG, markers_to_align, ...
        'photoTrigger', photo_trigger_name, ...
        'photoChannel', 64, ...
        'normalisePhotoData', true, ...
        'peakHeightThresh', min_peak_height, ...
        'missedTrigTresh', delay_tolerance, ...
        'modifyOriginal', false);

    for marker = 1:length(markers_to_align)
        if latency_info{marker, 4} > delay_tolerance
            error('Average delay for marker %s is too high: %i', latency_info{marker, 1}, latency_info{marker, 4});
        end
    end
    % latency_infos is a cell array. Each row reflects one marker type.
    % Columns reflect:
    %     - Marker Name
    %     - Marker idx in modified EEG.event structure (New EEG structure is
    %       the second output, we produce this later)
    %     - Array of delays (ms) for each marker
    %     - Average delay (ms)

    %% Realign markers
    % This function adds new markers. These markers are named according
    % to the photo_trigger_name variable. They reflect the onset of the luminance
    % change detected by the photosensor at stimulus onset.
    [~, EEG] = trigger_photo_latency(EEG, markers_to_align, ...
        'photoTrigger', photo_trigger_name, ...
        'photoChannel', 64, ...
        'normalisePhotoData', true, ...
        'peakHeightThresh', min_peak_height, ...
        'missedTrigTresh', delay_tolerance, ...
        'modifyOriginal', true);

    % Remove marker channel
    % We delete this channel since it's not an electrode.
    EEG = pop_select(EEG, 'nochannel', {'photosensor'});
    phIdx = find(strcmpi({EEG.chaninfo.removedchans.labels}, 'photosensor'));
    EEG.chaninfo.removedchans(phIdx) = [];

    % Remove events added by the photosensor
    EEG = pop_selectevent( EEG, 'omittype', {photo_trigger_name}, 'deleteevents', 'on');
    EEG = eeg_checkset(EEG);
end