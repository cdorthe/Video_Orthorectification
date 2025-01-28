function rectified_first_frame = rectify_frame(ortdir, ortname, framedir, framename, savedir, clbFldr, clbdata)
    % rectify_frame - This function performs image rectification by finding homologous points 
    % between an orthophoto and a video frame, then estimating a projective transformation to 
    % rectify the frame and evaluate registration accuracy.
    %
    % Syntax: rectify_frame(ortdir, ortname, framedir, framename, savedir, clbFldr, clbdata)
    %
    % Parameters:
    %    ortdir      - Directory containing the orthophoto (reference image)
    %    ortname     - Name of the orthophoto file
    %    framedir    - Directory containing the video frame
    %    framename   - Name of the video frame file
    %    savedir     - Directory to save the rectified frame and results
    %    clbFldr     - Directory containing calibration data
    %    clbdata     - Calibration data file (e.g., camera calibration parameters)
    %
    % This function performs the following:
    % 1. Reads input images (orthophoto and video frame).
    % 2. Undistorts the frame if calibration data is available.
    % 3. Finds homologous points between the frame and orthophoto.
    % 4. Estimates the projective transformation using the matched points.
    % 5. Computes registration error (RMSE).
    % 6. Exports the rectified frame and saves the transformation matrix.

    % 00 -- Read Parameters
    disp('---')
    disp('00 Read parameters')

    % Read the orthophoto and the frame
    ortho = imread(fullfile(ortdir, ortname));   % Orthophoto (reference image)
    frame = imread(fullfile(framedir, framename));  % Video frame to rectify

    % Check if calibration data exists and load it if available
    if isfile(fullfile(clbFldr, clbdata))  % Check if calibration data exists
        frame_undist = frame;  % Save the original frame for later reference
        load(fullfile(clbFldr, clbdata));  % Load camera calibration data
        frame = undistortImage(frame, cameraParams);  % Undistort the frame using the calibration data
        disp('-- Frame undistorted with camera calibration parameters --')
        clearvars frame_undist  % Clear the undistorted frame variable after processing
    else
        disp('-- Camera calibration parameters missing --')
    end

    % 10 -- Find Homologous Points
    disp('---')
    disp('10 Find homologous points')
    % If the image has 4 channels (RGBA), remove the alpha channel
    if size(ortho, 3) == 4
        ortho = ortho(:, :, 1:3);  % Keep only the RGB channels
    end
    % If previous points are available, use them to speed up cpselect
    if exist('framePoints', 'var') && exist('orthoPoints', 'var')
        [framePoints, orthoPoints] = cpselect(frame, ortho, framePoints, orthoPoints, 'Wait', true);  % Use pre-selected points if available
    else
        [framePoints, orthoPoints] = cpselect(frame, ortho, 'Wait', true);  % Manually select points if no previous points exist
    end

    % Convert points to cornerPoints objects for easier handling
    framePointsObj = cornerPoints(framePoints);
    orthoPointsObj = cornerPoints(orthoPoints);

    % 20 -- Estimate Projective Transformation
    disp('---')
    disp('20 Estimate projective transformation')

    % Define a reference for the orthophoto's transformation
    ortho_ref = imref2d(size(ortho));  % Create an image reference object for the orthophoto

    % Estimate the projective transformation using the matched points
    [tform, frameInlierPoints, orthoInlierPoints] = estimateGeometricTransform(...
        framePointsObj, orthoPointsObj, 'projective', 'MaxNumTrials', 10000, ...
        'Confidence', 99, 'MaxDistance', 16);

    fprintf('\n...%d points have been rejected \n', length(orthoPointsObj) - length(orthoInlierPoints))

    % Apply the transformation to rectify the frame
    frameRect = imwarp(frame, tform, 'FillValues', 0, 'OutputView', ortho_ref);  % Warp the frame to match the orthophoto

    % Show the result of the registration (blended view of rectified frame and orthophoto)
    FigWarp = figure;
    imshowpair(frameRect, ortho, 'blend'); hold on;
    plot(orthoInlierPoints.Location(:, 1), orthoInlierPoints.Location(:, 2), 'ro')  % Plot inlier points

    % 30 -- Registration Error Estimation
    disp('---')
    disp('30 Registration error estimation')

    % Calculate the RMSE for the registered points
    [xOrt_hat, yOrt_hat] = transformPointsForward(tform, ...
        frameInlierPoints.Location(:, 1), frameInlierPoints.Location(:, 2));  % Apply the transformation to the frame points
    
    % Calculate residuals (differences between transformed points and the orthophoto points)
    xRes = xOrt_hat - orthoInlierPoints.Location(:, 1);
    yRes = yOrt_hat - orthoInlierPoints.Location(:, 2);
    N = length(orthoInlierPoints);

    % Compute RMSE for the x and y coordinates and the global RMSE
    xRMSE = sqrt(sum((orthoInlierPoints.Location(:, 1) - xOrt_hat).^2) / N);
    yRMSE = sqrt(sum((orthoInlierPoints.Location(:, 2) - yOrt_hat).^2) / N);
    globRMSE = sqrt(sum(([orthoInlierPoints.Location(:, 1); orthoInlierPoints.Location(:, 2)] - ...
        [xOrt_hat; yOrt_hat]).^2) / (2 * N));

    % Display the RMSE results
    fprintf('...x RMSE: %.2f \n...y RMSE: %.2f\n...Global RMSE: %.2f\n', xRMSE, yRMSE, globRMSE);

    % 40 -- Export Rectified Frame
    disp('---')
    disp('40 Export rectified frame')

    % Create the output directory if it doesn't exist
    if ~exist(savedir, 'dir')
        mkdir(savedir);  % Create the output directory if it doesn't exist
    end

    % Save the rectified frame as a JPEG image
    rectified_first_frame = fullfile(savedir, [framename(1:end-4), '_rect.jpg']);
    imwrite(frameRect, fullfile(savedir, [framename(1:end-4), '_rect.jpg']));
    
    % Save the result of the registration (blended image with inlier points)
    print(FigWarp, fullfile(savedir, ['mtch_', framename(1:end-4), '.png']), '-dpng', '-r300');
    
    % Save the transformation matrix for later use
    save(fullfile(savedir, 'homographyTrn.mat'), 'tform');

    % Close all figures and display completion message
    close all;
    disp('Done');
end
