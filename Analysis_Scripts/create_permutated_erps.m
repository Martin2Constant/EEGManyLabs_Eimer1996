function create_permutated_erps(filepath, team)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    rng("shuffle");
    alpha = 0.02;
    do_plots = true;
    participants = [1:3];
    n_permutations = 1e4;
    time_window = [100; 400];
    permuted_letters = zeros(1, n_permutations, 'double');
    permuted_colors = zeros(1, n_permutations, 'double');

    lch = 1;
    rch = 2;

    % Load 1st dataset to extract sampling rate and time indices
    id = participants(1);
    epoched = sprintf('%s_participant%i_epoched_small.set', team, id);
    EEG = pop_loadset(epoched, [filepath filesep team filesep 'EEG']);
    time_idx = dsearchn(EEG.times', time_window)';
    Ts = 1/EEG.srate;

    observed_letters_cipsi = zeros(length(participants), length(time_idx(1):time_idx(2)), 'double');
    observed_colors_cipsi = zeros(length(participants), length(time_idx(1):time_idx(2)), 'double');

    % Load each dataset and split for side and condition
    for id = participants
        epoched = sprintf('%s_participant%i_epoched_small.set', team, id);
        EEG = pop_loadset(epoched, [filepath filesep team filesep 'EEG']);
        EEG_letters_left = pop_selectevent( EEG, ...
            'bini', [1 4], ...
            'deleteevents','off', ...
            'deleteepochs','on', ...
            'invertepochs','off');
        EEG_letters_right = pop_selectevent( EEG, ...
            'bini', [2 5], ...
            'deleteevents','off', ...
            'deleteepochs','on', ...
            'invertepochs','off');
        all_eegs_letters_left(id) = EEG_letters_left;
        all_eegs_letters_right(id) = EEG_letters_right;

        EEG_colors_left = pop_selectevent( EEG, ...
            'bini', [7 10], ...
            'deleteevents','off', ...
            'deleteepochs','on', ...
            'invertepochs','off');
        EEG_colors_right = pop_selectevent( EEG, ...
            'bini', [8 11], ...
            'deleteevents','off', ...
            'deleteepochs','on', ...
            'invertepochs','off');

        all_eegs_colors_left(id) = EEG_colors_left;
        all_eegs_colors_right(id) = EEG_colors_right;

        ERP_letters_contra = mean(EEG_letters_left.data(rch, time_idx(1):time_idx(2), :), 3)*0.5 + mean(EEG_letters_right.data(lch,time_idx(1):time_idx(2),:), 3)*0.5;
        ERP_letters_ipsi = mean(EEG_letters_left.data(lch, time_idx(1):time_idx(2), :), 3)*0.5 + mean(EEG_letters_right.data(rch,time_idx(1):time_idx(2),:), 3)*0.5;

        ERP_colors_contra = mean(EEG_colors_left.data(rch, time_idx(1):time_idx(2), :), 3)*0.5 + mean(EEG_colors_right.data(lch,time_idx(1):time_idx(2),:), 3)*0.5;
        ERP_colors_ipsi = mean(EEG_colors_left.data(lch, time_idx(1):time_idx(2), :), 3)*0.5 + mean(EEG_colors_right.data(rch,time_idx(1):time_idx(2),:), 3)*0.5;

        observed_letters_cipsi(id, :) = ERP_letters_contra - ERP_letters_ipsi;
        observed_colors_cipsi(id, :) = ERP_colors_contra - ERP_colors_ipsi;
    end
    GA_letters = mean(observed_letters_cipsi, 1);
    GA_colors = mean(observed_colors_cipsi, 1);
    observed_AUC_letters = compute_AUC(GA_letters, Ts, "neg");
    observed_AUC_colors = compute_AUC(GA_colors, Ts, "neg");
    fprintf("\nStarting permutations\n")

    parfor perm = 1:n_permutations
        permuted_letters_cipsi = zeros(length(participants), length(time_idx(1):time_idx(2)), 'double');
        permuted_colors_cipsi = zeros(length(participants), length(time_idx(1):time_idx(2)), 'double');
        for id = participants
            EEG_letters_left = shuffle(all_eegs_letters_left(id).data, 1);
            EEG_letters_right = shuffle(all_eegs_letters_right(id).data, 1);

            EEG_colors_left = shuffle(all_eegs_colors_left(id).data, 1);
            EEG_colors_right = shuffle(all_eegs_colors_right(id).data, 1);

            ERP_letters_contra = mean(EEG_letters_left(rch, time_idx(1):time_idx(2), :), 3)*0.5 + mean(EEG_letters_right(lch,time_idx(1):time_idx(2),:), 3)*0.5;
            ERP_letters_ipsi = mean(EEG_letters_left(lch, time_idx(1):time_idx(2), :), 3)*0.5 + mean(EEG_letters_right(rch,time_idx(1):time_idx(2),:), 3)*0.5;

            ERP_colors_contra = mean(EEG_colors_left(rch, time_idx(1):time_idx(2), :), 3)*0.5 + mean(EEG_colors_right(lch,time_idx(1):time_idx(2),:), 3)*0.5;
            ERP_colors_ipsi = mean(EEG_colors_left(lch, time_idx(1):time_idx(2), :), 3)*0.5 + mean(EEG_colors_right(rch,time_idx(1):time_idx(2),:), 3)*0.5;


            permuted_letters_cipsi(id, :) = ERP_letters_contra - ERP_letters_ipsi;
            permuted_colors_cipsi(id, :) = ERP_colors_contra - ERP_colors_ipsi;
        end
        GA_letters = mean(permuted_letters_cipsi, 1);
        GA_colors = mean(permuted_colors_cipsi, 1);
        % AUC
        permuted_letters(perm) = compute_AUC(GA_letters, Ts, "neg");
        permuted_colors(perm) = compute_AUC(GA_colors, Ts, "neg");
    end


    pval_letters = 1 - (sum(observed_AUC_letters > permuted_letters)/n_permutations)
    pval_colors = 1 - (sum(observed_AUC_colors > permuted_colors)/n_permutations)

    % Two kinds of plots
    if do_plots
        figure;
        title("Letters")
        histogram(permuted_letters, 100)
        xline(permuted_letters(n_permutations*(1-alpha)))
        xline(observed_AUC_letters, "r")
        
        sorted_letters = sort(permuted_letters);
        figure;
        title("Letters")
        plot(sorted_letters)
        yline(observed_AUC_letters, "r")
        yline(sorted_letters(n_permutations*(1-alpha)), "--")
        xline(n_permutations*(1-alpha), "--")
        xline(sum(observed_AUC_letters > sorted_letters))
        xticks(sort([0:1000:9000, n_permutations*(1-alpha), sum(observed_AUC_letters > sorted_letters)]))

        figure;
        title("Colors")
        histogram(permuted_colors, 100)
        xline(permuted_colors(n_permutations*(1-alpha)))
        xline(observed_AUC_colors, "r")
        
        sorted_colors = sort(permuted_colors);
        figure;
        title("Colors")
        plot(sorted_colors)
        yline(observed_AUC_colors, "r")
        yline(sorted_colors(n_permutations*(1-alpha)), "--")
        xline(n_permutations*(1-alpha), "--")
        xline(sum(observed_AUC_colors > sorted_colors))
        xticks(sort([0:1000:9000, n_permutations*(1-alpha), sum(observed_AUC_colors > sorted_colors)]))
    end
    
end
