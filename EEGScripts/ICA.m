function ICA(participant_nr, filepath, team)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    % We are computing ICA weights, but at least for the pure replication,
    % this step is useless since we're not using it.

    filename = sprintf('%s_participant%i_filtered.set', team, participant_nr);
    EEG = pop_loadset(filename, [filepath filesep team filesep 'EEG']);

    %% Pre-process for ICA
    EEG_forICA = EEG;

    % Apply stronger high-pass filter (2 Hz passband edge) to help ICA
    % decomposition
    EEG_forICA = pop_eegfiltnew(EEG_forICA, 'locutoff', 2);
    EEG_forICA = eeg_checkset( EEG_forICA );

    % Remove data segments with no markers for 5 seconds or more (usually
    % breaks or CRAP data)
    EEG_forICA  = pop_erplabDeleteTimeSegments( EEG_forICA , 'afterEventcodeBufferMS',  1000, 'beforeEventcodeBufferMS',  1000, 'displayEEG', 0, 'ignoreBoundary',...
        0, 'ignoreUseType', 'ignore', 'timeThresholdMS',  5000 );

    EEG_forICA = eeg_checkset( EEG_forICA );
    % Resample to 100 Hz to speed things up
    EEG_forICA = pop_resample( EEG_forICA, 100);

    EEG_forICA = eeg_checkset( EEG_forICA );
    % Check that data rank is still okay, in case there's a discrepancy,
    % keep the lowest of the two.
    dataRank = min(EEG_forICA.dataRank, sum(eig(cov(double(EEG_forICA.data'))) > 1E-6));
    %% Extended Infomax ICA, with PCA reduction if dataRank < N_channels
    try
        %% 100 Hz CUDA ICA
        % Infomax ICA (extended) using CUDA (Requires NVIDIA GPU with CUDA)
        % https://github.com/yhz-1995/cudaica_win (Windows)
        % https://github.com/fraimondo/cudaica (Linux)
        % Needs more installation but is much faster
        if dataRank < length(EEG_forICA.data(:,1))
            EEG_forICA = pop_runica(EEG_forICA, 'icatype', 'cudaica', 'extended', 1, 'maxsteps', 16000, 'pca', dataRank);
        else
            EEG_forICA = pop_runica(EEG_forICA, 'icatype', 'cudaica', 'extended', 1, 'maxsteps', 16000);
        end
        EEG_forICA = eeg_checkset( EEG_forICA );
    catch
        %% 100 Hz BINARY ICA
        warning('Data too big for CUDA or CUDA not installed')
        try
            % Run extended Infomax ICA using C binary file (is faster but
            % requires additional setup)
            % Though I don't know where to download these binaries from
            % anymore (old link has been deprecated)
            if dataRank < length(EEG_forICA.data(:,1))
                EEG_forICA = pop_runica(EEG_forICA, 'icatype', 'binica', 'extended', 1,'maxsteps', 16000, 'pca', dataRank);
            else
                EEG_forICA = pop_runica(EEG_forICA, 'icatype', 'binica', 'extended', 1,'maxsteps', 16000);
            end
        catch
            %% 100 Hz RUNICA ICA
            warning('BINICA not installed')
            % Runica is compatible with every eeglab install
            if dataRank < length(EEG_forICA.data(:,1))
                EEG_forICA = pop_runica(EEG_forICA, 'icatype', 'runica', 'extended', 1, 'maxsteps', 16000, 'pca', dataRank);
            else
                EEG_forICA = pop_runica(EEG_forICA, 'icatype', 'runica', 'extended', 1, 'maxsteps', 16000);
            end
        end
    end

    %% Post ICA
    % Transfer ICA weights and sphere to original data
    EEG.icaweights = EEG_forICA.icaweights;
    EEG.icasphere  = EEG_forICA.icasphere;
    EEG.icachansind = EEG_forICA.icachansind;
    EEG = eeg_checkset( EEG );
    EEG = eeg_checkset( EEG, 'ica' );

    EEG = pop_saveset(EEG, 'filename', filename, 'filepath', [filepath filesep team filesep 'EEG']);
    clear EEG_forICA

    % Removing files created by ICA
    delete([pwd filesep 'binica*']);
    delete([pwd filesep 'cudaica*']);
end
