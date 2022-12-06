function [eye_ics, labels] = extract_iclabel(EEG)
    % Author: Martin Constant (martin.constant@uni-bremen.de)

    % ICLabel performs better on strongly high-passed data. 
    EEG = pop_eegfiltnew(EEG, 'locutoff', 2);
    EEG = iclabel(EEG, 'default');

    % If probability eye component > 80% then flag for rejection.
    eye_ics = find(EEG.etc.ic_classification.ICLabel.classifications(:,3) >= 0.80);
    labels = EEG.etc.ic_classification;
end
