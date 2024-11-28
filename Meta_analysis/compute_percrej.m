function compute_percrej(filepath, pipelines)
    teams = ["Auckland", "Essex", "GenevaKerzel", "GenevaKliegel", "Gent", "ZJU", "Hildesheim", "ItierLab", "KHas", "Krakow", "LSU", "Magdeburg", "Malaga", "Munich", "NCC_UGR", "Neuruppin", "Onera", "TrierCogPsy", "TrierKamp", "UNIMORE", "UniversityofVienna", "Verona"];
    N_OK = 0;
    N_bad = 0;
    for pipeline = pipelines
        percent_reject_colors = [];
        percent_reject_forms = [];
        for team = teams
            exclusions = readtable(sprintf('%s/Rejection/%s_%s_rejections.csv', filepath, team, pipeline));
            % exclusions = exclusions(exclusions.Condition ~= "letters", :);
            for id = unique(exclusions.ID)'
                idforms_row = find(exclusions.ID == id & exclusions.Condition == "forms");
                idcolors_row = find(exclusions.ID == id & exclusions.Condition == "colors");

                if ~(any(exclusions([idforms_row, idcolors_row], :).N_remaining < 100) || any(exclusions([idforms_row, idcolors_row], :).ERP_excluded == 1))
                    if ~exist(sprintf('%s/%s/ERP/%s/%s_participant%02i_%s.erp', filepath, team, pipeline, team, id, pipeline), "file")
                        disp(team)
                        disp(id)
                    end
                    N_OK = N_OK + 1;
                    percent_reject_colors = [percent_reject_colors; exclusions(idcolors_row, :).N_remaining / 264];
                    percent_reject_forms = [percent_reject_forms; exclusions(idforms_row, :).N_remaining / 264];
                else
                    N_bad = N_bad + 1; 
                end
            end
        end
        disp(N_OK);
        disp(N_bad);
        perc_rej_col = mean(1-percent_reject_colors)*100;
        perc_rej_forms = mean(1-percent_reject_forms)*100;
        fprintf('Pipeline: %s, Forms: %.2f, Colors: %.2f\n\n', ...
            pipeline, perc_rej_col, perc_rej_forms);
    end
end