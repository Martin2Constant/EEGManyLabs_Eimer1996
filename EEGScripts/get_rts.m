function mean_rts = get_rts(ERP, mean_rts, row)
    behavior = ERP.behavior;
    behavior = behavior(behavior.correct == 1, :);
    behavior = behavior(ERP.rejected_trials, :);
    behavior = behavior(behavior.distractor_array == 1, :);
    letters = behavior(strcmp(behavior.target_condition, 'letters'), :);
    colors = behavior(strcmp(behavior.target_condition, 'squares'), :);
    mean_rts.RT_letters(row) = mean(letters.response_time);
    mean_rts.RT_colors(row) = mean(colors.response_time);
end
