function compute_rejections(filepath, pipelines)
    teams = ["Auckland", "Essex", "GenevaKerzel", "GenevaKliegel", "Gent", "ZJU", "Hildesheim", "ItierLab", "KHas", "Krakow", "LSU", "Magdeburg", "Malaga", "Munich", "NCC_UGR", "Neuruppin", "Onera", "TrierCogPsy", "TrierKamp", "UNIMORE", "UniversityofVienna", "Verona"];
    for pipeline = pipelines
        incorrect = 0;
        blinks = 0;
        eyemove = 0;
        po7 = 0;
        excluded = 0;
        ok = 0;
        n_colors = 0;
        n_forms = 0;
        for team = teams
            exclusions = readtable(sprintf('%s/Rejection/%s_%s_rejections.csv', filepath, team, pipeline));
            % exclusions = exclusions(exclusions.Condition ~= "letters", :);
            marked_ids = [];
            for id = unique(exclusions.ID)'
                for cond = ["colors", "forms"]
                    idcond_row = find(exclusions.ID == id & exclusions.Condition == cond);
                    idrow = find(exclusions.ID == id);
                    
                    if exclusions(idcond_row, :).N_remaining >= 100
                        continue
                    elseif ~ismember(id, marked_ids)
                        excluded = excluded + 1;
                        marked_ids = [marked_ids, id];
                        sub_t = exclusions(idrow, :);
                        excl = [sum(sub_t.IncorrectResp), sum(sub_t.Blinks), sum(sub_t.EyeMovements), sum(sub_t.PO7_8)];
                        [~, idx] = max(excl);
                        switch idx
                            case 1
                                incorrect = incorrect + 1;
                            case 2
                                blinks = blinks + 1;
                            case 3
                                eyemove = eyemove + 1;
                            case 4
                                po7 = po7 + 1;
                        end
                    end
                end
            end
            for id = unique(exclusions.ID)'
                if ~ismember(id, marked_ids)
                    n_colors = n_colors + exclusions(exclusions.ID == id & exclusions.Condition == "colors", :).N_remaining;
                    n_forms = n_forms + exclusions(exclusions.ID == id & exclusions.Condition == "forms", :).N_remaining;
                end
            end
        end
        fprintf('Pipeline: %s\nIncorrect responses: %02i\nBlinks: %02i\nEye movements: %02i\nPO7/8 noise: %02i\n\n', ...
            pipeline, incorrect, blinks, eyemove, po7);
        total_rej = incorrect + blinks + eyemove + po7 + 2;
        fprintf('Pipeline: %s\nIncorrect responses: %.2f\nBlinks: %.2f\nEye movements: %.2f\nPO7/8 noise: %.2f\n\n', ...
            pipeline, incorrect/total_rej*100, blinks/total_rej*100, eyemove/total_rej*100, po7/total_rej*100);
        disp([n_colors, n_forms])
        disp([excluded, ok])
    end
end