function mean_correct = get_correct(ERP, mean_correct, row)
    % Author: Martin Constant (martin.constant@unige.ch)
    % Extract RTs from the behavior data file.
    behavior = ERP.behavior;

    % Only keep RTs for trials which contained only one target.
    behavior = behavior(behavior.distractor_array == 1, :);

    % Split between forms (named "letters" in the experiment) and colors
    forms = behavior(strcmp(behavior.target_condition, 'letters'), :);
    colors = behavior(strcmp(behavior.target_condition, 'colors'), :);

    mean_correct.ID(row) = unique(behavior.subject_nr);
    mean_correct.forms_correct(row) = mean(forms.correct);
    mean_correct.colors_correct(row) = mean(colors.correct);
end
