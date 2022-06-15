function ICA(participant_nr, filepath)
    %% Initialize and load
    id = participant_nr;
    filename = sprintf('participant%i_preICA.set', id);
    post_ica = sprintf('participant%i_postICA.set', id);

    EEG = pop_loadset(filename, [filepath filesep 'EEG']);

    
    %% Pre-process for ICA
    EEG_forICA = EEG;
    EEG_forICA = pop_firws(EEG_forICA, 'fcutoff', 1, 'ftype', 'highpass', 'wtype', 'blackman', 'forder', 2750, 'minphase', 0, 'usefftfilt', 0, 'plotfresp', 0, 'causal', 0);
    EEG_forICA = eeg_checkset( EEG_forICA );
    EEG_forICA  = pop_erplabDeleteTimeSegments( EEG_forICA , 'displayEEG', 0, 'endEventcodeBufferMS',  1000, 'ignoreUseType', 'ignore', 'startEventcodeBufferMS',...
        1000, 'timeThresholdMS',  5000 );
    EEG_forICA = eeg_checkset( EEG_forICA );  
    % Resample to 100Hz for stationarity
    EEG_forICA = pop_resample( EEG_forICA, 100);

    EEG_forICA = eeg_checkset( EEG_forICA );
    dataRank = sum(eig(cov(double(EEG_forICA.data'))) > 1E-6);
    %% Run ICA
    try
        %% 100Hz CUDA ICA
        % Infomax ICA (extended) using CUDA (Requires NVIDIA GPU with CUDA)
        % https://github.com/yhz-1995/cudaica_win or https://github.com/fraimondo/cudaica
        % Needs more installation but is much faster
        if dataRank < length(EEG_forICA.data(:,1))
            EEG_forICA = pop_runica(EEG_forICA, 'icatype', 'cudaica', 'extended', 1, 'maxsteps', 16000,'pca',dataRank);
        else
            EEG_forICA = pop_runica(EEG_forICA, 'icatype', 'cudaica', 'extended', 1, 'maxsteps', 16000);
        end
%             [W,S] = beamica(EEG_forICA.data,[],[],[],[],16000,[],[],0);
%             EEG_forICA.icaweights = W;
%             EEG_forICA.icasphere = S;
            EEG_forICA = eeg_checkset( EEG_forICA );
%             EEG_forICA = pop_runica(EEG_forICA, 'icatype', 'cudaica', 'extended', 1, 'maxsteps', 16000);
%         end
    catch
        %% 100Hz BINARY ICA
        warning('Data too big for CUDA or CUDA not installed')
        try
            % Run extended Infomax ICA using C binary file (is faster but requires additional setup)
            % https://sccn.ucsd.edu/wiki/Binica
            % Download the files for your platform from the above link
            % and place them in the <eeglabroot>/functions/supportfiles folder
            if EEG_forICA.dataRank < length(EEG_forICA.data(:,1))
                EEG_forICA = pop_runica(EEG_forICA, 'icatype', 'binica', 'extended', 1,'maxsteps', 16000,'pca',EEG_forICA.dataRank);
            else
                EEG_forICA = pop_runica(EEG_forICA, 'icatype', 'binica', 'extended', 1,'maxsteps', 16000);
            end
        catch
            %% 100Hz RUNICA ICA
            warning('BINICA not installed')
            % Run extended Infomax ICA (compatible with every eeglab install)
            if EEG_forICA.dataRank < length(EEG_forICA.data(:,1))
                EEG_forICA = pop_runica(EEG_forICA, 'icatype', 'runica', 'extended', 1,'maxsteps', 16000,'pca',EEG_forICA.dataRank);
            else
                EEG_forICA = pop_runica(EEG_forICA, 'icatype', 'runica', 'extended', 1,'maxsteps', 16000);
            end
        end
    end
    
    %% Post ICA
    % Give ICA weights to original data
    EEG.icaweights = EEG_forICA.icaweights;
    EEG.icasphere  = EEG_forICA.icasphere;
    EEG = eeg_checkset( EEG );
    EEG = eeg_checkset( EEG, 'ica' );

    EEG = pop_saveset(EEG, 'filename', post_ica, 'filepath', [filepath filesep 'EEG']);
    clear EEG_forICA
    
    % Removing files created by ICA
    delete([pwd filesep 'binica*']);
    delete([pwd filesep 'cudaica*']);
end