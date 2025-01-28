function cmrPrms = loadCalibrationData(clbFldr, clbdata)
    % Load calibration data if available
    if isfile([clbFldr, filesep, clbdata])
        load([clbFldr, filesep, clbdata]);
        disp('-- Calibration data loaded --');
    else
        disp('-- No calibration data loaded, please check --');
    end
end
