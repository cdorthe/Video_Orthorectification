function createVideo(outputVideoFile, fps, outputDir_extracted_frames, cutted_video_name, I00, bptsm00x, bptsm00y, tkEv, kInterrupt, fld2sav, vidName, cameraParams, cmrPrms, kini)
    % createVideo - Handles video creation by transforming frames and saving to a video file
    %
    % Syntax: createVideo(outputVideoFile, fps, outputDir_extracted_frames, cutted_video_name, I00, bptsm00x, bptsm00y, tkEv, kInterrupt, fld2sav, vidName, cameraParams, cmrPrms, kini)
    %
    % Inputs:
    %    outputVideoFile - Path to save the output video
    %    fps - Frames per second for the video
    %    outputDir_extracted_frames - Directory containing extracted frames
    %    cutted_video_name - Subdirectory for specific video
    %    I00 - Reference image for transformations
    %    bptsm00x, bptsm00y - Smoothed bounding points for each frame
    %    tkEv - Time event scaling factor for index alignment
    %    kInterrupt - Frame limit for saving fused images
    %    fld2sav, vidName - Save folder and name components for output images
    %    cameraParams, cmrPrms - Camera parameters for image undistortion
    %    kini - Starting frame index

    % Load image files
    imageFiles = dir(fullfile(outputDir_extracted_frames, '*.jpg'));
    numFrames = numel(imageFiles);
    frames_dir = fullfile(outputDir_extracted_frames, cutted_video_name);

    % Initialize video writer with MPEG-4 compression
    v = VideoWriter(outputVideoFile, 'MPEG-4');
    v.FrameRate = fps;
    v.Quality = 75; % Adjust quality for size vs. fidelity tradeoff
    open(v);


    % % Initialize video writer
    % v = VideoWriter(outputVideoFile, 'Uncompressed AVI');
    % v.FrameRate = fps;
    % open(v);

    disp('--Video creation is running, please wait ... --');

    % Iterate over all frames
    for k = 1:numFrames
        kk = k - 1 + 100000; % Adjust frame index
        id = num2str(kk);    % Padded frame identifier
        fprintf('%4.0f ... ', kk);

        try
            % Load the current frame
            I01 = loadFrame(frames_dir, id, cmrPrms, cameraParams);
            fprintf('Frame %d loaded successfully. Size: [%d x %d x %d]\n', k, size(I01, 1), size(I01, 2), size(I01, 3));

            % Perform geometric transformation
            RA = imref2d(size(I00), 1, 1);
            boundpoints01 = single([[0, 0, size(I01, 2), size(I01, 2)]', [0, size(I01, 1), size(I01, 1), 0]']);
            boundpoints00 = single([bptsm00x((k - kini + 100000) / tkEv + 1, :)', bptsm00y((k - kini + 100000) / tkEv + 1, :)']);

            [tform09, ~, ~] = estimateGeometricTransform( ...
                boundpoints00, boundpoints01, 'projective', ...
                'MaxNumTrials', 10000, 'Confidence', 99, 'MaxDistance', 1.5);

            % Apply the transformation
            I09t = imwarp(I01, invert(tform09), 'FillValues', 0, 'OutputView', RA);

            % Validate the transformed frame
            if isempty(I09t) || all(I09t(:) == 0)
                error('Transformed frame %d is empty or all zeros.', k);
            end

            % Normalize and resize the frame
            I09t = imresize(I09t, [size(I00, 1), size(I00, 2)]);
            if size(I09t, 3) ~= 3
                I09t = repmat(I09t, 1, 1, 3); % Convert grayscale to RGB
            end
            if ~isa(I09t, 'uint8')
                I09t = im2uint8(mat2gray(I09t));
            end

            % Save fused image for debugging
            if k <= kInterrupt
                saveFusedImage(I00, I09t, fld2sav, vidName, id);
            end

            % Save a debug copy of the transformed frame
            %imwrite(I09t, fullfile(fld2sav, sprintf('debug_frame_%d.jpg', k))); % Debugging step

            % Write the transformed frame to the video
            writeVideo(v, I09t);
            fprintf('Frame %d written successfully.\n', k);

        catch ME
            % Catch and display errors for individual frames
            warning('Error processing frame %d: %s', k, ME.message);
        end
    end

    % Close the video writer
    close(v);
    disp('Video creation completed successfully.');
end

function I01 = loadFrame(frames_dir, id, cmrPrms, cameraParams)
    % Load and preprocess the frame
    framePath = fullfile([frames_dir '_p', id(2:end), '.jpg']);
    if ~exist(framePath, 'file')
        error('Frame file does not exist: %s', framePath);
    end
    I01 = imread(framePath);
    if isempty(I01)
        error('Failed to load frame: %s', framePath);
    end
    if cmrPrms == 1
        I01 = undistortImage(I01, cameraParams);
    end
end

function saveFusedImage(I00, I09t, fld2sav, vidName, id)
    % Save a fused image of the original and transformed frames
    figXZ = figure('Visible', 'off');
    warning('off');
    imshow(imfuse(I00, I09t, 'blend'), 'Border', 'tight');
    savePath = fullfile(fld2sav, [vidName(1:end-4), '_processing'], ['002mtch_', vidName(1:end-4), '_p', id(2:end), '.jpg']);
    print(figXZ, savePath, '-djpeg', '-r100');
    close(figXZ);
end

% function createVideo(outputVideoFile, fps, outputDir_extracted_frames,cutted_video_name, I00, bptsm00x, bptsm00y, tkEv, kInterrupt, fld2sav, vidName, cameraParams, cmrPrms, kini)
%     % createVideo - Handles video creation by transforming frames and saving to a video file
%     %
%     % Syntax: createVideo(outputVideoFile, fps, numFrames, vidNamS, I00, bptsm00x, bptsm00y, tkEv, kInterrupt, fld2sav, vidName, cameraParams, cmrPrms, kini)
%     %
%     % Inputs:
%     %    outputVideoFile - Path to save the output video
%     %    fps - Frames per second for the video
%     %    numFrames - Number of frames to process
%     %    vidNamS - Directory containing the input frames
%     %    I00 - Reference image for transformations
%     %    bptsm00x, bptsm00y - Smoothed bounding points for each frame
%     %    tkEv - Time event scaling factor for index alignment
%     %    kInterrupt - Frame limit for saving fused images
%     %    fld2sav, vidName - Save folder and name components for output images
%     %    cameraParams, cmrPrms - Camera parameters for image undistortion
%     %    kini - Starting frame index
%     imageFiles = dir(fullfile(outputDir_extracted_frames, '*.jpg'));
%     numFrames = numel(imageFiles);
%     frames_dir = fullfile(outputDir_extracted_frames, cutted_video_name);
%     % Initialize video writer
%     v = VideoWriter(outputVideoFile, 'Uncompressed AVI');
%     v.FrameRate = fps;
%     open(v);
% 
%     disp('--Video creation is running, please wait ... --');
% 
%     % Iterate over all frames
%     for k = 1:numFrames
%         % Generate the padded frame identifier
%         kk = k-1 + 100000;
%         id = num2str(kk);
%         fprintf('%4.0f ... ', kk);
% 
%         % Print progress every 10 frames
%         if mod(kk, 10) == 0
%             fprintf('\n');
%         end
% 
%         % Load and preprocess the frame
%         I01 = loadFrame(frames_dir, id, cmrPrms, cameraParams);
% 
%         % Perform geometric transformation
%         RA = imref2d(size(I00), 1, 1);
%         boundpoints01 = single([[0, 0, size(I01, 2), size(I01, 2)]', [0, size(I01, 1), size(I01, 1), 0]']);
%         boundpoints00 = single([bptsm00x((k - kini + 100000) / tkEv + 1, :)', bptsm00y((k - kini + 100000) / tkEv + 1, :)']);
% 
%         [tform09, ~, ~] = estimateGeometricTransform( ...
%             boundpoints00, boundpoints01, 'projective', ...
%             'MaxNumTrials', 10000, 'Confidence', 99, 'MaxDistance', 1.5);
% 
%         % Transform the image
%         I09t = imwarp(I01, invert(tform09), 'FillValues', 0, 'OutputView', RA);
% 
%         % Save fused image for debugging (only if within the interrupt range)
%         if k <= kInterrupt
%             saveFusedImage(I00, I09t, fld2sav, vidName, id);
%         end
% 
%         % Write the transformed frame to the video
%         writeVideo(v, I09t);
%     end
% 
%     % Close the video writer
%     close(v);
%     disp('Video creation completed successfully.');
% end
% 
% function I01 = loadFrame(frames_dir, id, cmrPrms, cameraParams)
%     % Load and preprocess the frame
%     framePath = fullfile([frames_dir '_p', id(2:end), '.jpg']);
%     I01 = imread(framePath);
%     if cmrPrms == 1
%         I01 = undistortImage(I01, cameraParams);
%     end
% end
% 
% function saveFusedImage(I00, I09t, fld2sav, vidName, id)
%     % Save a fused image of the original and transformed frames
%     figXZ = figure('Visible', 'off');
%     warning('off');
%     imshow(imfuse(I00, I09t, 'blend'), 'Border', 'tight');
%     savePath = fullfile(fld2sav, [vidName(1:end-4), '_processing'], ['002mtch_', vidName(1:end-4), '_p', id(2:end), '.jpg']);
%     print(figXZ, savePath, '-djpeg', '-r100');
%     close(figXZ);
% end
