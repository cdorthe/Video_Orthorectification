function [Xmax, Ymax] = process_Frames(outputDir_extracted_frames, cameraParams, cmrPrms, ftrDtct, f00, vpts00, I00, outputDir)
    % processFrames - Processes a series of frames from extracted image files, 
    % applies camera corrections, detects and matches features, transforms 
    % images, and stores the transformed coordinates for further analysis.
    %
    % Syntax: [Xmax, Ymax] = processFrames(outputDir_extracted_frames, cameraParams, ftrDtct, f00, vpts00, I00, outputDir)
    %
    % Inputs:
    %    outputDir_extracted_frames - Directory containing the extracted frames.
    %    cameraParams - Camera calibration parameters for correcting the images.
    %    ftrDtct - Feature detection method to use (e.g., 'SURF' or 'KAZE').
    %    f00 - Feature descriptors from the reference image.
    %    vpts00 - Viewpoints (feature points) corresponding to f00.
    %    I00 - The reference image used for matching features.
    %    outputDir - Directory where the results will be saved.
    %
    % Outputs:
    %    Xmax - A cell array storing the transformed X coordinates of feature points for each frame.
    %    Ymax - A cell array storing the transformed Y coordinates of feature points for each frame.
    % Limit parallel pool size
    if isempty(gcp('nocreate'))
        parpool('local', 4); % Use 4 workers to balance memory
    end

    % Retrieve a list of all image files (JPEG format) in the extracted frames directory.
    imageFiles = dir(fullfile(outputDir_extracted_frames, '*.jpg'));
    % Count the number of frames (images) to process.
    numFrames = numel(imageFiles);
    % Preallocate cell arrays to store results (transformed coordinates).
    Xmax = cell(1, numFrames);
    Ymax = cell(1, numFrames);

    % Use a parallel for loop to process each frame independently.
    parfor k = 1:numFrames
        try
            % Load the current frame, apply camera corrections using cameraParams.
            imagePath = fullfile(outputDir_extracted_frames, imageFiles(k).name);
            %disp('...processing frame:', imagePath);
            I01 = preprocessImage(imagePath, cameraParams, cmrPrms, "frame");
            fprintf('Preprocessing frame %d: done.\n',k)
            % Detect and match features between the current frame and the reference frame.
            [~, matchedPoints01, tform01, ~] = detectAndMatchFeatures(I01, f00, vpts00, ftrDtct);
            fprintf('Feature matching frame %d: done.\n',k)

            % Transform and warp the current image based on the computed transformation.
            % The function also returns the transformed coordinates (xyk) and boundary points (xtmp, ytmp).
            [~, ~, xtmp, ytmp] = transformAndWarp(I01, tform01, matchedPoints01, imref2d(size(I00)));
            fprintf('Transformation frame %d: done.\n',k)


            % Store the transformed X and Y coordinates along with the current frame index.
            Xmax{k} = [xtmp, double(k)];  % X coordinates with frame index.
            Ymax{k} = [ytmp, double(k)];  % Y coordinates with frame index.
        catch ME
            % Catch and display any errors encountered during frame processing.
            warning('Error processing frame %d: %s', k, ME.message);
        end
    end

    % Save the results (Xmax and Ymax) to a .mat file in the output directory.
    save(fullfile(outputDir, 'results.mat'), 'Xmax', 'Ymax');
    disp('Saving done.')
end
