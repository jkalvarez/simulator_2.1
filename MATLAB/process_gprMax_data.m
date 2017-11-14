%% Process output of gprMax output
function [ processed ] = process_gprMax_data(data)
%% Resample data from 1060 (5ns) down to 125 (pixel size)
processed = resample(data, 125, 1061);

%% Subtract average trace to remove source signal contamination
processed = processed - mean(processed,2);

%% Normalize - final step after resampling to ensure that the smoothing of resampling is unaffected
% All the type casting
processed = uint8(round(mat2gray(processed)*255));

end