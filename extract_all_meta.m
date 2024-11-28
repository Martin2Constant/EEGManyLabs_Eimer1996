filepath = fileparts(mfilename('fullpath'));
addpath([filepath filesep 'Meta_analysis']);
pipelines = ["Original", "Resample", "ICA", "ICA+Resample"];
pull_amplitudes(filepath, pipelines)
pull_each_amplitude(filepath, pipelines)
pull_effect_size(filepath, pipelines)
create_output_table(filepath, pipelines)