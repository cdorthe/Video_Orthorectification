function [bptsm00x, bptsm00y] = processInterplay(Xmax, Ymax, xtf, fps, I00, nam2sav)
    % Main function to handle the interplay of Xmax and Ymax data.
    % This function processes the raw data, smooths it, plots the results,
    % and saves the processed data and figures.
    %
    % Parameters:
    %   Xmax, Ymax - Raw data for interplay analysis.
    %   xtf - Smoothing factor for robust LOESS.
    %   fps - Frames per second, used for scaling smoothing parameters.
    %   I00 - Unused parameter 
    %   nam2sav - Base name for saved files.

    % Display status
    disp('---');
    disp('60.00 interplay');
    
    % Clean and process data
    [Xmax, Ymax] = cleanAndConvertData(Xmax, Ymax);

    % Smooth the data
    bptsm00x = smoothData(Xmax, xtf, fps);
    bptsm00y = smoothData(Ymax, xtf, fps);

    % Plot results
    plotInterplayResults(Xmax, Ymax, bptsm00x, bptsm00y, I00);

    % Save results
    saveResults(nam2sav, Xmax, Ymax, bptsm00x, bptsm00y);
end

function [Xmax, Ymax] = cleanAndConvertData(Xmax, Ymax)
    % Converts raw cell array data to matrices and removes invalid rows.
    %
    % This function ensures that the data is in matrix form and removes
    % any rows with NaN in the first column, which may indicate invalid
    % or missing values.
    %
    % Parameters:
    %   Xmax, Ymax - Cell arrays containing raw data.
    %
    % Returns:
    %   Xmax, Ymax - Cleaned matrices with NaN rows removed.
    Xmax = cell2mat(Xmax');
    Ymax = cell2mat(Ymax');

    % Remove rows with NaN in the first column
    Xmax(isnan(Xmax(:,1)), :) = [];
    Ymax(isnan(Ymax(:,1)), :) = [];
end

function smoothedData = smoothData(data, xtf, fps)
    % Smooths data columns using a moving average and robust LOESS.
    %
    % Parameters:
    %   data - Matrix containing data to be smoothed.
    %   xtf - Smoothing factor for robust LOESS.
    %   fps - Frames per second, used for scaling smoothing parameters.
    %
    % Returns:
    %   smoothedData - Smoothed matrix of the same size as input `data`.
    numRows = size(data, 1);

    % Calculate span
    span = xtf * fps / numRows;

    % Ensure span is positive
    if span <= 0
        error('Calculated span must be positive. Check values of xtf, fps, and numRows.');
    end
    
    disp(data)
    % Apply robust LOESS smoothing
    smoothedData = [
        smooth(1:numRows, data(:,1), span, 'rloess'), ...
        smooth(1:numRows, data(:,2), span, 'rloess'), ...
        smooth(1:numRows, data(:,3), span, 'rloess'), ...
        smooth(1:numRows, data(:,4), span, 'rloess')
    ];
end


function plotInterplayResults(Xmax, Ymax, bptsm00x, bptsm00y, ~)
    % Generates a plot comparing raw and smoothed data for Xmax and Ymax.
    %
    % This function overlays raw and smoothed data on the same plot
    % to visualize the effect of smoothing and highlight trends.
    %
    % Parameters:
    %   Xmax, Ymax - Raw data matrices.
    %   bptsm00x, bptsm00y - Smoothed data matrices.
    %   I00 - Unused parameter (kept for potential future customization).
    %
    % Notes:
    %   - The function assumes that the figure will be saved externally.
    figure;
    hold on;

    % Plot raw data
    plot(Xmax(:,1:4), Ymax(:,1:4), '.');

    % Plot smoothed data
    plot(bptsm00x - 0 * bptsm00x(1,:), bptsm00y - 0 * bptsm00y(1,:));

    % Customize axes
    axis on;
    hold off;
end

function saveResults(nam2sav, Xmax, Ymax, bptsm00x, bptsm00y)
     % Saves the processed data and a JPEG figure to disk.
    %
    % This function writes the raw and smoothed data to a .mat file
    % and saves the current figure as a JPEG image in the specified folder.
    %
    % Parameters:
    
    %   nam2sav - Base name for the saved files.
    %   Xmax, Ymax - Raw data matrices.
    %   bptsm00x, bptsm00y - Smoothed data matrices.
    %
    % Outputs:
    %   - .mat file with raw and smoothed data.
    %   - JPEG image of the plotted results.

    % Save data to .mat file
    save(fullfile([nam2sav, '_Interplay00.mat']), ...
        'Xmax', 'Ymax', 'bptsm00x', 'bptsm00y');

    % Save the figure as a JPEG image
    figFile = fullfile([nam2sav, '_Interplay00.jpg']);
    print(gcf, figFile, '-djpeg', '-r100');
    disp(['Results saved to ', figFile]);
end
