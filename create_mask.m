function create_mask(datdir, jpgname, savdir)
    % This function performs the following tasks:
    % 1. Reads the input image.
    % 2. Allows the user to define a mask via ROI (Region of Interest).
    % 3. Applies morphological operations to clean the mask.
    % 4. Saves the mask and related data to the specified directory.

    % 00 -- Read Parameters
    disp('---')
    disp('00 Read parameters')

    % Ensure output directory exists
    if ~exist(savdir, 'dir')
        mkdir(savdir);
    end

    % Read the image
    I0 = imread(fullfile(datdir, jpgname));
    if isempty(I0)
        error('Failed to read the image file: %s', fullfile(datdir, jpgname));
    end

    % 10 -- Handle Data
    disp('---')
    disp('10 Handle data')

    % Display the image and let the user define a polygonal ROI
    figure; imshow(I0);
    [x0, y0] = getline(gcf);  % Get the points for the polygon
    maskBW = roipoly(I0, x0, y0);  % Create binary mask from ROI

    % Apply morphological opening to clean the mask
    maskBW = imopen(maskBW, strel('disk', 31));

    % Display the mask over the image
    figure; imshow(imadjust(rgb2gray(I0)) .* uint8(maskBW));

    % 90 -- Save Data
    disp('---')
    disp('90 Save data')

    % Save the mask data to .mat and .jpg files
    save(fullfile(savdir, [jpgname(1:end-4), '_CW.mat']), 'x0', 'y0', 'maskBW');
    imwrite(maskBW, fullfile(savdir, [jpgname(1:end-4), '_CW.jpg']));
    
    disp('Done');
end
