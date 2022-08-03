function mean_rts = get_rts(ERP, mean_rts, row)
    % Author: Martin Constant (martin.constant@uni-bremen.de)
    % Extract RTs from the behavior data file.
    behavior = ERP.behavior;

    % Only keep RTs for correct responses
    behavior = behavior(behavior.correct == 1, :);
    % Only keep RTs for trials which weren't rejected
    behavior = behavior(ERP.rejected_trials, :);
    % Only keep RTs for trials which contained only one target.
    behavior = behavior(behavior.distractor_array == 1, :);
    
    % Split between letters and colors
    letters = behavior(strcmp(behavior.target_condition, 'letters'), :);
    colors = behavior(strcmp(behavior.target_condition, 'colors'), :);
    
    % Split between congruent and incongruent
    letters_congruent = letters(letters.congruent_response == 1, :);
    letters_incongruent = letters(letters.congruent_response == 0, :);
    colors_congruent = colors(colors.congruent_response == 1, :);
    colors_incongruent = colors(colors.congruent_response == 0, :);

    mean_rts.RT_letters(row) = mean(letters.response_time);
    mean_rts.RT_colors(row) = mean(colors.response_time);
    mean_rts.RT_congruent_letters(row) = mean(letters_congruent.response_time);
    mean_rts.RT_incongruent_letters(row) = mean(letters_incongruent.response_time);
    mean_rts.RT_congruent_colors(row) = mean(colors_congruent.response_time);
    mean_rts.RT_incongruent_colors(row) = mean(colors_incongruent.response_time);
end
