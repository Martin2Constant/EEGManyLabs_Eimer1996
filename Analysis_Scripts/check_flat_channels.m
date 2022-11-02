function check_flat_channels(EEG, channels)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    % Check for flat channels.
    % First, create a high-passed copy of the dataset.
    % Onepass-zerophase Hamming-windowed sinc FIR
    % Cutoff (-6 dB) 0.25 Hz
    % Transition width 0.5 Hz, stopband 0-0.0 Hz, passband 0.5 Hz - Nyquist
    % Max. passband deviation 0.0022 (0.22%), stopband attenuation -53 dB
    %
    % Then remove time segments with no markers for more than 5 seconds.
    % Then checks whether M1, M2, PO7 or PO8 are flat for more than 30 seconds.
    % Deviates from original study.
    arguments
        EEG struct;
        channels cell = {'PO7', 'PO8', 'M1', 'M2'};
    end
    EEG = pop_eegfiltnew(EEG, 'locutoff', 0.5, 'usefftfilt', 1);
    EEG  = pop_erplabDeleteTimeSegments( EEG , ...
        'afterEventcodeBufferMS',  1000, ...
        'beforeEventcodeBufferMS',  1000, ...
        'displayEEG', 0, 'ignoreBoundary', 0, ...
        'ignoreUseType', 'ignore', ...
        'timeThresholdMS',  5000 );
    EEG = pop_clean_rawdata(EEG, ...
        'FlatlineCriterion', 30, ...
        'ChannelCriterion', 'off', ...
        'LineNoiseCriterion', 'off', ...
        'Highpass', 'off', ...
        'BurstCriterion', 'off', ...
        'WindowCriterion', 'off', ...
        'BurstRejection', 'off', ...
        'Distance', 'Euclidian', ...
        'channels', channels);
    if EEG.nbchan < length(channels)
        error("PO7, PO8, M1 or M2 of participant %02i is flat for more than 30 seconds.", participant_nr)
    end
end
