% [eventLatenciesInfo, EEG] = trigger_photo_latency(EEG, eventNames, varargin)
%
%         Align the recorded triggers to the onset times recorded by
%         Brainproducts' photosensor. Conversion follows the procedure:
%         1. Extract data from photosensor
%         2. Find onset of spikes - spikes reflect changes in contrast
%         3. Add found onsets to EEG.event structure in chronological order
%         4. For eah trigger, find closest spike (within defined tolerance)
%         5. Convert the original onset time of each trigger to its
%            assciated spike onset time
%
% In:
%    EEG        - An EEGLAB data structure
%    eventNames - Cell array of strings represenitng the names of the
%                 triggers to align
%
% Optional:
%    photoTrigger       - Name to provide to the triggers representing the
%                         photosensor event onsets. Default: 'photo'
%    photoChannel       - Channel number (int) or channel name (string) of 
%                         the channel containing the photosensor data
%    normalisePhotoData - Logical (true|false). Whether to normalise the 
%                         photosensor data prior to find the peaks. If true, 
%                         data is normalised in range [0,1]. Default: true
%
%    peakHeightThresh   - Minimum peak height for a photosensor spike to be
%                         considered an event. This value is empirical and
%                         it depends on multiple factors (eg. colour of the
%                         photosensor stimulus). Can be useful to evoid 
%                         considering events changes in diplay contrast not
%                         associated with the experiment (eg. experiment 
%                         window opening). Deafult: 0
%    missedTrigTresh    - Maximum acceptable lag (in ms) between recorded 
%                         trigger and photosensor spike. If the lag is
%                         higher than thism a warning is produced. This
%                         often occurs if you try to align a trigger that
%                         does not have an associated photosensor.
%    modifyOriginal     - Logical (true|false). Whether to return a modified
%                         copy of the EEG structure containin the
%                         re-aligned events. Default: true
%
% Out:
%    eventLatenciesInfo - Cell array containing delays information for each
%                         trigger included in eventNames. Each row
%                         represents a different trigger. Columns
%                         represent: 
%                         1. Trigger name
%                         2. Trigger idx in modified EEG.event structure
%                         3. Array of delays (ms) for each trigger
%                         4. Average delay (ms) for each trigger
%    EEG                - Modified copy of the EEG structure where the 
%                         EEG.event structure now contains:
%                         1. Photosensor events as triggers
%                         2. Onset of triggers alligned with the
%                            photosensor events

% Author: Daniele Scanzi
%
%     Copyright (C) <2022>  <Daniele Scanzi>
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details (https://www.gnu.org/licenses).

function [eventLatenciesInfo, EEG] = trigger_photo_latency(EEG, eventNames, varargin)
    
    % INPUTS
    p = inputParser;
    
    % Mandatory
    addRequired(p, 'EEG', @isstruct);      % EEG structure with EEG data
    addRequired(p, 'eventNames', @iscellstr); % Signal matrix
    
    % Optional
    addParameter(p, 'photoTrigger', 'photo', @ischar);       % Name of the trigger to add
    addParameter(p, 'photoChannel', 64);                     % Channel containing the photosensor data
    addParameter(p, 'normalisePhotoData', true, @islogical); % Whether to normalise the data or not
    addParameter(p, 'peakHeightThresh', 0, @isnumeric);      % Minimum height to consider something a peak
    addParameter(p, 'missedTrigTresh', 16, @isnumeric);      % Max delay (in ms) acceptable
    addParameter(p, 'modifyOriginal', true, @islogical);     % Whether to modify the original EEG structure or not
    
    parse(p, EEG, eventNames, varargin{:});
    
    EEG                = p.Results.EEG;
    eventNames         = p.Results.eventNames;
    photoTrigger       = p.Results.photoTrigger;
    photoChannel       = p.Results.photoChannel;
    normalisePhotoData = p.Results.normalisePhotoData;
    peakHeightThresh   = p.Results.peakHeightThresh;
    missedTrigTresh    = p.Results.missedTrigTresh;
    modifyOriginal     = p.Results.modifyOriginal;

    %% MAIN FUNCTION

    % Check that event structure is in EEG structure
    if ~isfield(EEG, "event")
        error("Cannot find event structure. Is EEG an EEGLAB structure?")
    end

    % Check that provided events exist
    for iEvent = 1:length(eventNames)
        if ~any(strcmp({EEG.event.type}, eventNames{iEvent}))
            error("Cannot find %s in EEG.event structure", eventNames{iEvent})
        end
    end

    % Check that data contains the channel requested
    if isinteger(photoChannel)
        if ~size(EEG.data, 1) < photoChannel
            error("Channel %i out of bound of data size %i", photoChannel, size(EEG.data, 1))
        end
    elseif ischar(photoChannel) || isstring(photoChannel)
        if ~any(strcmp({EEG.chanlocs.labels}, photoChannel))
            error("Channel %s not found", photoChannel)
        else
            % find channel number and overwrite string
            photoChannel = find(strcmp({EEG.chanlocs.labels}, photoChannel));
        end
    end

    % The function should run even with epoched data, but this has not been
    % tested yet. There are no many reasons for using this function with
    % epoched data anyway
    if ndims(EEG.data) > 2
        warning("Function not tested with epoched data (or data with more " + ...
            "than two dimensions in general" )
    end

    % Extract photsensor data (account for possibility of data being
    % epoched). Correct peaks so to find photosensor onset
    photoData = EEG.data(photoChannel, :, :);
    photoData = diff(photoData);
    
    if normalisePhotoData
        photoData = normalize(photoData, 'range');
    end

    % Find peaKs
    [~, peaksLocs] = findpeaks(photoData, 'MinPeakHeight', peakHeightThresh);

    % Add peaks to the event structure data
    fprintf("Adding photosensor events to EEG.event structure")
    % Add peaks to chanloc values
    for iPeak = 1:length(peaksLocs)
        EEG.event(end+1).latency = peaksLocs(iPeak);
        EEG.event(end).type = photoTrigger;
    end

    % Reorder events by latency
    EEG = eeg_checkset(EEG,'eventconsistency');

    % First find triggers indices
    eventLatenciesInfo = {length(eventNames), 4};
    for iEvent = 1:length(eventNames)
        eventLatenciesInfo{iEvent, 1} = eventNames{iEvent};
        eventLatenciesInfo{iEvent, 2} = find(strcmp({EEG.event.type}, eventNames{iEvent}));
    end
    
    % Compute event latencies finding the nearest photosensor event
    for iEvent = 1:size(eventLatenciesInfo, 1)
        % create arry to store latencies
        currentLatencies = nan(length(eventLatenciesInfo{iEvent, 2}), 1);
        for iTrig = 1:length(eventLatenciesInfo{iEvent, 2})

            % Check previous event
            previousTrigger = EEG.event(eventLatenciesInfo{iEvent, 2}(iTrig)-1);
            nextTrigger     = EEG.event(eventLatenciesInfo{iEvent, 2}(iTrig)+1);
            if strcmp({previousTrigger.type}, photoTrigger)
                previousLatencyDiff = EEG.event(eventLatenciesInfo{iEvent, 2}(iTrig)).latency - EEG.event(eventLatenciesInfo{iEvent, 2}(iTrig)-1).latency;
            else
                % if there is no photosensor trigger before, set this diff
                % tp -Inf
                previousLatencyDiff = nan;
            end

            % Check next event
            if strcmp({nextTrigger.type}, photoTrigger)
                nextLatencyDiff = EEG.event(eventLatenciesInfo{iEvent, 2}(iTrig)+1).latency - EEG.event(eventLatenciesInfo{iEvent, 2}(iTrig)).latency;
            else
                % if there is no photosensor trigger before, set this diff
                % tp -Inf
                nextLatencyDiff = nan;
            end

            % Find minimum between the two
            [currentMin, minIdx] = min([previousLatencyDiff nextLatencyDiff]);
            if  currentMin > missedTrigTresh
                warning("Possible missing triggers around trigger number %i. Event not included in latency calculation \n", eventLatenciesInfo{iEvent, 2}(iTrig));
                currentLatencies(iTrig) = nan;
            else
                currentLatencies(iTrig) = currentMin;
            end
            
            % Modify the original dataset event structure if requested
            if modifyOriginal
                if minIdx == 1
                    EEG.event(eventLatenciesInfo{iEvent, 2}(iTrig)).latency = previousTrigger.latency;
                elseif minIdx == 2
                    EEG.event(eventLatenciesInfo{iEvent, 2}(iTrig)).latency = nextTrigger.latency;
                end
            end

        end

        % Compute average latency excluding missing triggers
        currentLatencies = currentLatencies(~isnan(currentLatencies));
        eventLatenciesInfo{iEvent, 3} = currentLatencies;
        eventLatenciesInfo{iEvent, 4} = mean(currentLatencies);
    end
    EEG = eeg_checkset(EEG);
end



% Helper
function isText(myVar)
    isstring(myVar) || ischar(myVar);
end