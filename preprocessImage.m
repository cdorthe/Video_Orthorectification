function I = preprocessImage(imagePath, cameraParams, cmrPrms, image_type)
    % preprocessImage - Reads an image from the specified path and applies 
    % adaptive histogram equalization to each color channel.
    %
    % Syntax: I = preprocessImage(imagePath)
    %
    % Inputs:
    %    imagePath - A string containing the full path to the image file.
    %
    % Outputs:
    %    I - The processed image after applying adaptive histogram equalization.
    %
    % The function performs the following steps:
    % 1. Reads the image from the specified path.
    % 2. Applies adaptive histogram equalization to each of the three color channels 
    %    (Red, Green, and Blue) of the image using the 'adapthisteq' function.
    % 3. The parameters of 'adapthisteq' are set to clip the histogram at 2% of the 
    %    total range, and use a Rayleigh distribution for contrast enhancement.

    % Read the image from the provided file path
 
    I = imread(imagePath);
    if image_type == "frame"
        if cmrPrms == 1
            I = undistortImage(I, cameraParams);
        end
    end 
    % Loop through each color channel (Red, Green, and Blue)
    for i = 1:3
        % Apply adaptive histogram equalization to the current color channel
        I(:,:,i) = adapthisteq(I(:,:,i), 'clipLimit', 0.02, 'Distribution', 'rayleigh');
    end
end


