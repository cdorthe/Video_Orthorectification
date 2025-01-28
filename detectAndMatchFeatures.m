function [matchedPoints00, matchedPoints01, tform01, inlierPoints01] = detectAndMatchFeatures(I01, f00, vpts00, ftrDtct)
    % detectAndMatchFeatures - Detects and matches feature points between 
    % two images using specified feature detectors (SURF or KAZE).
    %
    % Syntax: [matchedPoints00, matchedPoints01, tform01, inlierPoints01] = detectAndMatchFeatures(I01, f00, vpts00, ftrDtct)
    %
    % Inputs:
    %    I01 - The first input image in which to detect and match features.
    %    f00 - Feature descriptors of the reference image (before transformation).
    %    vpts00 - Viewpoints (or points) corresponding to f00 (for matching).
    %    ftrDtct - A string indicating the feature detector to use ('SURF' or 'KAZE').
    %
    % Outputs:
    %    matchedPoints00 - The matched points from the reference image (vpts00).
    %    matchedPoints01 - The matched points from the input image (vpts01).
    %    tform01 - The geometric transformation matrix that aligns matched points.
    %    inlierPoints01 - The inlier points from the second image (after transformation estimation).

    % Convert the input image to grayscale for feature detection
    grayImage = rgb2gray(I01);
    
    % Detect feature points using the selected feature detector ('SURF' or 'KAZE')
    if strcmpi(ftrDtct, 'SURF')
        % Use SURF feature detector if 'SURF' is chosen
        points01 = detectSURFFeatures(grayImage);
    else
        % Use KAZE feature detector if 'KAZE' is chosen
        points01 = detectKAZEFeatures(grayImage);
    end
    
    % Extract feature descriptors and viewpoints for the detected points
    [f01, vpts01] = extractFeatures(grayImage, points01);
    
    % Match features between the reference image (f00) and the current image (f01)
    indexPairs = matchFeatures(f00, f01, 'MatchThreshold', 1, 'MaxRatio', 0.3, 'Unique', true, 'Method', 'Approximate');
    
    % Retrieve the matched points from the reference and input images
    matchedPoints00 = vpts00(indexPairs(:, 1));
    matchedPoints01 = vpts01(indexPairs(:, 2));
    
    % Estimate the geometric transformation (projective) between the matched points
    [tform01, ~, inlierPoints01] = estimateGeometricTransform(matchedPoints00, matchedPoints01, ...
        'projective', 'MaxNumTrials', 10000, 'Confidence', 99, 'MaxDistance', 32);
end
