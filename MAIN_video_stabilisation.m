clc; clear; close all;
%% --- 10.00 Parameters Setup ---
disp('--- 10.00 Parameters ---');

% INPUT: Define file paths and names
%orthophoto
ortFldr = 'D:\MA_EMME_HS2024\LSPIV\02_Orthophoto'; 
ortName = 'Emme_ELJ03_15.01.25.tif'; 
%video
vidFldr = 'D:\MA_EMME_HS2024\LSPIV\01_Videos';
vidName = '150125_Emme_ELJ03.MP4';
[~, vidName_no_ext, ~] = fileparts(vidName);
%camera calibration
clbFldr = 'D:\MA_EMME_HS2024\LSPIV\03_Camera_calibration';
clbdata = 'DJI_calibration_27.11.mat';

vidPath = [vidFldr, filesep, vidName];
vidObj              = VideoReader([vidFldr,filesep,vidName]);
%%

% OUTPUT: Define file paths and names
outputFolder = 'D:\MA_EMME_HS2024\LSPIV\05_150125_ELJ03_fps_20\00_Video_Orthorectification';
outputDir_extracted_frames = 'D:\MA_EMME_HS2024\LSPIV\04_extracted_frames_fps_20_150125';
fld2sav = outputFolder;
nam2sav = [ortName(1:end-4),'_','000'];
outputDir_frame_processing = [fld2sav, filesep, vidName(1:end-4),'_processing']; % Ensure folder for intermediate results exists


% Ensure folders exist
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

if ~isfolder(outputDir_extracted_frames)
    mkdir(outputDir_extracted_frames);
end

if ~isfolder(fld2sav)
    mkdir(fld2sav);
end

if ~isfolder(outputDir_frame_processing)
    mkdir(outputDir_frame_processing);
end

%% --- Parameters
frame_extraction_rate = 20; % Rate of frame extraction = takes x frames per sec
startT= '00:05'; %start time in 'MM:SS' where to start cutting the video
finalT = '02:15'; %final time in 'MM:SS' where to stop cutting the video

% Feature detection method
ftrDtct = 'KAZE';
pic02ID = '_001';

% Image sequence parameters
kini = 100001;
tkEv = 000001;
kfin = 101348;
kInterrupt = 1500;
fps                 = vidObj.Framerate/tkEv;
% Scaling factor
xtf = 1.0;

toc
%% Pre-processing 
takeEvery = 1/frame_extraction_rate; 
%% cut video segment 
disp("cutting video segment...")
cutted_video_dir = extract_video_segment(vidPath, startT, finalT, outputFolder);

%% extract frames
disp("extracting frames...")
nameFrames = extract_video_frames(cutted_video_dir, outputDir_extracted_frames, takeEvery);

%% frame rectification 
disp("rectifying frames...") 
% reprendre ici: il faut crop les photos camera calib au format du frame
% 0000 puis refaire le process de camera calib et recommencer
% cette étape. 
framename = [nameFrames '_p00000.jpg'];
rectified_first_frame = rectify_frame(ortFldr, ortName, outputDir_extracted_frames, framename, outputFolder, clbFldr, clbdata);

%% create mask 
[~, framename, ~] = fileparts(framename);
framename_rect    	= [framename '_rect.jpg'];
create_mask(outputFolder, framename_rect, outputFolder)

%% load calibration data 
%load camera calibration data
if isfile(fullfile(clbFldr, clbdata))
    load(fullfile(clbFldr, clbdata), 'cameraParams');
    cmrPrms = 1;
    disp('-- Calibration data loaded --');
else
    cmrPrms = 0;
    disp('-- No calibration data loaded. Please check. --');
end

%% --- 20.00 Load Orthophoto ---
disp('--- 20.00 Load & Handle Orthophoto ---');

% Load and preprocess rectified first frame
I00 = preprocessImage(rectified_first_frame, cameraParams, cmrPrms, "ortho");

% Load mask if available
maskBW = loadMask(outputFolder, framename_rect, I00);

% Detect features in the orthophoto
[f0, vpts0, linID0, linIDx] = detectFeatures(I00, maskBW, ftrDtct);


%% --- 50.00 Frame processing  ---
disp('--- 50.00 Frame processing ---');

save(fullfile(outputFolder, '50_workspace.mat'));
%%
% Frame processing function
[Xmax, Ymax] = process_Frames(outputDir_extracted_frames, cameraParams, cmrPrms, ftrDtct, f0, vpts0, I00, outputDir_frame_processing);

% --- 60.00 Interplay ---

[bptsm00x, bptsm00y] = processInterplay(Xmax, Ymax, xtf, fps, I00, outputFolder);
%% --- 70.00 Video creation

disp('---');
disp('70.00 Video creation');
ntskini             = num2str(kini);
ntskfin             = num2str(kfin);
[~,cutted_video_name,~]=fileparts(cutted_video_dir); 
% Initialize video writer and process frames
outputVideoFile = [fld2sav, filesep, vidName_no_ext , '_frms', ntskini(2:end), 'to', ntskfin(2:end), '_', num2str(frame_extraction_rate, '%3.3f'), '.avi'];
createVideo(outputVideoFile, frame_extraction_rate, outputDir_extracted_frames, cutted_video_name , I00, bptsm00x, bptsm00y, tkEv, kInterrupt, fld2sav, vidName, cameraParams, cmrPrms, kini);

fprintf('\n');

