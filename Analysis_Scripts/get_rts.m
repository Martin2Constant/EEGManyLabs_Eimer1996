function mean_rts = get_rts(ERP, mean_rts, row)
    % Author: Martin Constant (martin.constant@unige.ch)
    % Extract RTs from the behavior data file.
    behavior = ERP.behavior;

    % Only keep RTs for correct responses
    behavior = behavior(behavior.correct == 1, :);
    % Only keep RTs for trials which weren't rejected
    behavior = behavior(~ERP.rejected_trials, :);
    % Only keep RTs for trials which contained only one target.
    behavior = behavior(behavior.distractor_array == 1, :);

    % Split between forms (named "letters" in the experiment) and colors
    forms = behavior(strcmp(behavior.target_condition, 'letters'), :);
    colors = behavior(strcmp(behavior.target_condition, 'colors'), :);

    % Split between congruent and incongruent
    forms_congruent = forms(forms.congruent_response == 1, :);
    forms_incongruent = forms(forms.congruent_response == 0, :);
    colors_congruent = colors(colors.congruent_response == 1, :);
    colors_incongruent = colors(colors.congruent_response == 0, :);


    mean_rts.ID(row) = str2double(extractBetween(ERP.erpname, "participant", "_"));
    mean_rts.RT_forms(row) = mean(forms.response_time);
    mean_rts.RT_colors(row) = mean(colors.response_time);
    mean_rts.RT_congruent_forms(row) = mean(forms_congruent.response_time);
    mean_rts.RT_incongruent_forms(row) = mean(forms_incongruent.response_time);
    mean_rts.RT_congruent_colors(row) = mean(colors_congruent.response_time);
    mean_rts.RT_incongruent_colors(row) = mean(colors_incongruent.response_time);
end
