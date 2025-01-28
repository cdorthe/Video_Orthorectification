function MOVfil2 = extract_video_segment_optimized(MOVfile, startT, finalT, outputFolder)
    % Extracts a video segment between specified start and end times
    % Parameters:
    %   MOVfile: Path to the input video file
    %   startT: Start time in 'MM:SS' format
    %   finalT: End time in 'MM:SS' format
    %   outputFolder: Directory to save the output video segment

    % Validate input file
    if ~isfile(MOVfile)
        error('Input video file does not exist: %s', MOVfile);
    end

    % Ensure the output folder exists
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end

    % Prepare output file name
    [~, name, ~] = fileparts(MOVfile);
    MOVfil2 = fullfile(outputFolder, [name, '_extracted.mp4']);

    % Convert startT and finalT from 'MM:SS' to seconds
    startParts = sscanf(startT, '%d:%d');
    finalParts = sscanf(finalT, '%d:%d');
    startT_sec = startParts(1) * 60 + startParts(2);
    finalT_sec = finalParts(1) * 60 + finalParts(2);

    % Initialize VideoReader
    video = VideoReader(MOVfile);

    % Adjust Frame Rate for Faster Skipping
    frameRate = video.FrameRate;
    startFrame = round(startT_sec * frameRate);
    endFrame = round(finalT_sec * frameRate);

    % Pre-read frames to avoid repetitive computations
    video.CurrentTime = startT_sec;

    % Initialize VideoWriter
    writer = VideoWriter(MOVfil2, 'MPEG-4');
    writer.FrameRate = frameRate;
    open(writer);

    try
        % Extract and write the required frames
        while hasFrame(video)
            currentTime = video.CurrentTime;
            
            if currentTime > finalT_sec
                break; % Exit when we reach beyond the specified range
            end

            % Write the frame if it's within the time range
            if currentTime >= startT_sec && currentTime <= finalT_sec
                frame = readFrame(video);
                writeVideo(writer, frame);
            else
                % Skip reading frames outside the range
                readFrame(video);
            end
        end

        % Close the writer
        close(writer);

        % Check if frames were written successfully
        if writer.FrameCount == 0
            warning('No frames were written to the output video file. Check start and end times.');
        else
            fprintf('Video segment successfully saved to: %s\n', MOVfil2);
        end
    catch ME
        % Close the writer in case of errors
        close(writer);
        error('Error during video processing: %s', ME.message);
    end
end



% function MOVfil2 = extract_video_segment(MOVfile, startT, finalT, outputFolder)
%     % extract_video_segment - Extracts a segment of a video file using ffmpeg.
%     %
%     % Syntax: MOVfil2 = extract_video_segment(MOVfile, startT, finalT, outputFolder)
%     %
%     % Parameters:
%     %    MOVfile - Full path to the input video file (e.g., 'C:\path\to\video.MOV').
%     %    startT  - Start time of the segment to extract, in 'MM:SS' format (e.g., '00:45').
%     %    finalT  - End time of the segment to extract, in 'MM:SS' format (e.g., '01:30').
%     %    outputFolder - Path to the folder where the extracted video segment should be saved.
%     %
%     % Output:
%     %    MOVfil2 - Full path to the output video file that contains the extracted segment.
%     %
%     % This function uses the ffmpeg tool to extract a segment of a video between
%     % the specified start and end times, and saves the result in the specified output folder.
% 
%     % Check if the output folder exists. If it doesn't, create it.
%     if ~exist(outputFolder, 'dir')
%         mkdir(outputFolder);  % Create the folder if it doesn't exist
%         disp(['Created folder: ', outputFolder]);
%     end
% 
%     % Create the output file name by appending start and end times to the original file name
%     [~, name, ext] = fileparts(MOVfile);  % Extract file name and extension from MOVfile
%     MOVfil2 = fullfile(outputFolder, [name, '_', startT([1:2, 4:5]), '_', finalT([1:2, 4:5]), ext]);
%     % Example: if startT = '00:45' and finalT = '01:30', the output file might be 'video_0045_0130.MOV'
% 
%     % Construct the ffmpeg command to extract the video segment using the start and end times
%     str = ['ffmpeg.exe -i "', MOVfile, '" -ss ', startT, ' -to ', finalT, ' -c:v copy "', MOVfil2, '"'];
%     % -ss: Start time to begin extraction.
%     % -to: End time to stop extraction.
%     % -c:v copy: Use copy codec for video, meaning no re-encoding (faster).
% 
%     % Execute the system command to run ffmpeg and extract the video segment
%     s = system(str);
% 
%     % Check if the system command was successful (s == 0 means success)
%     if s == 0
%         disp(['Video segment saved to: ', MOVfil2]);
%     else
%         % If there was an error, display an error message
%         disp('Error in extracting video segment.');
%     end
% end

% function MOVfil2 = extract_video_segment(MOVfile, startT, finalT, outputFolder)
%     % Check if the input file exists
%     if ~isfile(MOVfile)
%         error('Input video file does not exist: %s', MOVfile);
%     end
% 
%     % Ensure the output folder exists
%     if ~exist(outputFolder, 'dir')
%         mkdir(outputFolder);
%         disp(['Created output folder: ', outputFolder]);
%     end
% 
%     % Replace invalid characters in the time stamps
%     [~, name, ~] = fileparts(MOVfile);
%     MOVfil2 = fullfile(outputFolder, [name, '_extracted.mp4']);
%     %disp(['Output file: ', MOVfil2]);
% 
%     % Convert startT and finalT from 'MM:SS' to seconds
%     startParts = sscanf(startT, '%d:%d');
%     finalParts = sscanf(finalT, '%d:%d');
%     startT_sec = startParts(1) * 60 + startParts(2);
%     finalT_sec = finalParts(1) * 60 + finalParts(2);
% 
%     % Open VideoReader
%     try
%         video = VideoReader(MOVfile);
%         %disp(['Opened video file: ', MOVfile]);
%         %disp(['Duration: ', num2str(video.Duration), ' seconds']);
%     catch ME
%         error('Failed to open input video file: %s', ME.message);
%     end
% 
%     % Create VideoWriter
%     try
%         writer = VideoWriter(MOVfil2, 'MPEG-4'); % Use 'Motion JPEG AVI' if necessary
%         writer.FrameRate = video.FrameRate;
%         open(writer);
%         %disp('VideoWriter opened successfully.');
%     catch ME
%         error('Failed to create VideoWriter: %s', ME.message);
%     end
% 
%     % Write frames to output video
%     try
%         while hasFrame(video)
%             currentTime = video.CurrentTime;
%             % disp(['Current time: ', num2str(currentTime)]);
%             % disp(['Start time (sec): ', num2str(startT_sec), ', End time (sec): ', num2str(finalT_sec)]);
%             % 
%             if currentTime >= startT_sec && currentTime <= finalT_sec
%                 frame = readFrame(video);
%                 writeVideo(writer, frame);
%             elseif currentTime > finalT_sec
%                 break;
%             else
%                 readFrame(video); % Skip frames
%             end
%         end
%         close(writer);
% 
%         % Check if frames were written
%         if writer.FrameCount == 0
%             warning('No frames were written to the output video file. Check start and end times.');
%         else
%             disp(['Video segment saved to: ', MOVfil2]);
%         end
%     catch ME
%         close(writer); % Ensure writer is closed even if an error occurs
%         error('Error during frame processing: %s', ME.message);
%     end
% end
