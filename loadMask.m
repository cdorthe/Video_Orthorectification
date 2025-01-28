function maskBW = loadMask(maskFldr, maskName, I00)
    % loadMask - This function loads a mask from a specified folder if available, 
    % or creates an empty mask if no mask is found.
    %
    % Syntax: maskBW = loadMask(maskFldr, maskName, I00)
    %
    % Parameters:
    %    maskFldr - Directory where the mask is stored (e.g., 'C:\path\to\masks')
    %    maskName - Name of the mask file (e.g., 'image_mask.jpg')
    %    I00      - Reference image (used to create an empty mask if no mask is found)
    %
    % Returns:
    %    maskBW   - A binary mask (logical array). If a mask is loaded, it is inverted. 
    %              If no mask is found, an empty mask (all zeros) of the same size as I00 is created.
    %
    % This function attempts to load a mask from a .mat file. If the mask is found, it is inverted 
    % and returned. If no mask is found, an empty mask (zeros of the same size as I00) is created.

    % Define the full file path for the mask file
    maskFile = [maskFldr, filesep, maskName(1:end-4), '_CW.mat'];  % Remove file extension and append '_CW.mat'

    % Check if the mask file exists
    if isfile(maskFile)  % If the file exists
        load(maskFile);  % Load the mask from the file
        disp('-- Mask loaded --');
        
        % Invert the loaded mask (assuming the mask is stored in a variable called 'maskBW')
        maskBW = ~maskBW;  % Invert the mask, turning black pixels into white and vice versa
    else  % If the file does not exist
        % Create an empty mask of the same size as I00 (all zeros, same dimensions)
        maskBW = ~zeros(size(I00, 1), size(I00, 2));  % Invert the empty mask, resulting in all ones (logical 1)
        disp('-- No mask loaded, please check --');
    end
end
