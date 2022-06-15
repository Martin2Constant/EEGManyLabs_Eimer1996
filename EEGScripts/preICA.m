function preICA(participant_nr, filepath)
    %% Initialize and load
    ALLEEG = [];
    id = participant_nr;
    % Create filenames
    filename = sprintf('participant%i_RT.set', id);
    savename = sprintf('participant%i_preICA.set', id);
    EEG = pop_loadset(filename, [filepath filesep 'EEG']);

        %% Ghost markers removal
        % Convert our markers from strings to integers (e.g. 'S101' to 101)
        EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );

        EEG = pop_chanedit(EEG, 'changefield',{5,'labels','LO1'}, 'changefield',{27,'labels','LO2'}, 'changefield',{64,'labels','IO2'}, 'changefield',{65,'labels','Fcz'},'append',65,'changefield',{66,'labels','Fpz'},'lookup','standard_1005.elc','setref',{'1:66','Fcz'});

        EEG = pop_chanedit(EEG, 'changefield',{5,'Z','-39.9051'},'changefield',{5,'Y','50.2186'},'changefield',{5,'X','55.7734'},'changefield',{27,'X','55.7734'},'changefield',{27,'Y','-50.2186'},'changefield',{27,'Z','-39.9051'},'changefield',{64,'X','62.0389'},'changefield',{64,'Y','-31.6104'},'changefield',{64,'Z','-48.754'}');
        EEG = pop_chanedit(EEG, 'convert',{'cart2all'});
        EEG = pop_chanedit(EEG, 'eval','chans = pop_chancenter( chans, [],[]);');
        EEG = pop_chanedit(EEG, 'convert',{'cart2all'});

        %% Downsampling
        EEG = eeg_checkset( EEG );
        %% High-pass filter
        %       Onepass-zerophase, order 6876, blackman-windowed sinc FIR
        %       Cutoff (-6 dB) 0.1 Hz
        %       Transition width 0.2 Hz, stopband 0-0.0 Hz, passband 0.2-125 Hz
        %       Max. passband deviation 0.0002 (0.02%), stopband attenuation -74 dB
        EEG = pop_firws(EEG, 'fcutoff', 0.1, 'ftype', 'highpass', 'wtype', 'blackman', 'forder', 27500, 'minphase', 0, 'usefftfilt', 0, 'plotfresp', 0, 'causal', 0);
        
        %% Low-pass filter
        %       Lowpass filtering data: onepass-zerophase, order 550, blackman-windowed sinc FIR
        %       Cutoff (-6 dB) 45 Hz
        %       Transition width 10.0 Hz, passband 0-40.0 Hz, stopband 50.0-125 Hz
        %       Max. passband deviation 0.0002 (0.02%), stopband attenuation -74 dB
        EEG = pop_firws(EEG, 'fcutoff', 44.5, 'ftype', 'lowpass', 'wtype', 'blackman', 'forder', 550, 'minphase', 0, 'usefftfilt', 0, 'plotfresp', 0, 'causal', 0);

    %% Rereference
    % Rereference to average of mastoids and add previous Ref (Fcz) as a data channel
    EEG = pop_reref( EEG, {'A1' 'A2'} ,'refloc',struct('labels',{'Fcz'},'type',{''},'theta',{-0.77507},'radius',{0.14877},'X',{44.048},'Y',{0.5959},'Z',{87.2868},'sph_theta',{0.77507},'sph_phi',{63.2207},'sph_radius',{97.773},'urchan',{65},'ref',{'Fcz'},'datachan',{0},'sph_theta_besa',{-26.7793},'sph_phi_besa',{-89.2249}));
    EEG = eeg_checkset( EEG );
    
    %% Final steps
    % ICA needs independent sources. If we remove channels and then
    % interpolate from the other channels, the interpolated are not
    % independent anymore. So we need to tell that to the ICA.

    EEG.dataRank = sum(eig(cov(double(EEG.data'))) > 1E-6);

    % Finally we save the file.
    EEG = eeg_checkset( EEG );

    EEG = pop_saveset(EEG, 'filename', savename, 'filepath', [filepath filesep 'EEG']);
end