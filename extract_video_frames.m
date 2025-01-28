function vidNamS = extract_video_frames(cutted_video_dir, outputDir, takeEvery)
    % extract_video_frames - Extracts frames from a video file at specified time intervals
    % and saves them as images in a specified folder.
    %
    % Syntax: vidNamS = extract_video_frames(cutted_video_dir, outputDir, takeEvery)
    %
    % Parameters:
    %    cutted_video_dir - Full path to the input video file (e.g., 'C:\path\to\video\video_name.MOV')
    %    outputDir        - Folder where the extracted frames will be saved (e.g., 'C:\path\to\output')
    %    takeEvery        - Frame extraction interval in seconds (e.g., 1 for extracting a frame every second)
    %
    % Output:
    %    vidNamS          - The base name of the video file (without extension)
    %
    % This function extracts frames from a video file and saves them as JPEG images
    % at specified time intervals defined by the `takeEvery` parameter.
    
    % Create VideoReader object to access video properties
    vidObj = VideoReader(cutted_video_dir);
    
    % Get the total duration and frame rate of the video
    duration = vidObj.Duration;  % Duration in seconds
    frameRate = vidObj.FrameRate; % Frames per second
    
    % Define the time points at which frames will be extracted (e.g., 0s, 1s, 2s, etc.)
    time2read = 0:takeEvery:floor(duration);  % Extract a frame every 'takeEvery' seconds

    % Get the base name of the video file (without extension)
    [~, vidNamS, ~] = fileparts(cutted_video_dir);
    % Loop through each time point and extract/save frames
    for k = 1:length(time2read)
        try
            % Set the current time of the video to extract the frame
            vidObj.CurrentTime = time2read(k);
            
            % Read the frame at the specified time point
            I0 = readFrame(vidObj);
            
            % Generate the frame file name with leading zeros (e.g., 'video_00001.jpg')
            id = sprintf('%05d', k-1);  % Format the time point with leading zeros for consistency
            
            % Save the extracted frame as a JPEG image in the output directory
            outputFileName = fullfile(outputDir, sprintf('%s_p%s.jpg', vidNamS, id));
            imwrite(I0, outputFileName);
            
            % Display a confirmation message indicating the frame has been saved
            disp(['Saved: ', outputFileName]);
        catch ME
            % Handle any errors that occur during frame extraction
            warning('Error processing time point %.2f: %s', time2read(k), ME.message);
        end
    end
end
