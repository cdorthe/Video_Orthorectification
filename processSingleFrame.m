function [I01t, matchedPoints01, inlierPoints01, tform01, xk, yk] = processSingleFrame(I00, I01, f0, vpts0, maskBW, cmrPrms, k)
    % Preprocess the frame (undistort, feature detection, etc.)
    if isa(cmrPrms, 'cameraParameters') || isa(cmrPrms, 'cameraIntrinsics')
        I01 = undistortImage(I01, cmrPrms);
    else
        error('cmrPrms must be a cameraParameters or cameraIntrinsics object.');
    end

    % Apply adaptive histogram equalization
    for i = 1:3
        I01(:,:,i) = adapthisteq(I01(:,:,i), 'clipLimit', 0.02, 'Distribution', 'rayleigh');
    end

    % Feature detection and matching
    points01 = detectKAZEFeatures(rgb2gray(I01));
    [f01, vpts01] = extractFeatures(rgb2gray(I01), points01);

    % Use the 'Location' property of KAZEPoints for indexing
    indexPairs = matchFeatures(f0, f01, 'MatchThreshold', 1, 'MaxRatio', 0.3, 'Unique', true, 'Method', 'Approximate');
    matchedPoints00 = vpts0(indexPairs(:, 1)).Location; % Extract locations
    matchedPoints01 = vpts01(indexPairs(:, 2)).Location; % Extract locations

    % Estimate geometric transform
    [tform01, inlierIdx, ~] = estimateGeometricTransform(matchedPoints00, matchedPoints01, ...
                                                         'similarity', 'MaxNumTrials', 2000, 'Confidence', 99.9);

    % Handle cases where no inliers are found
    if isempty(inlierIdx)
        warning('No inliers found for frame %d.', k);
        I01t = [];
        inlierPoints01 = [];
        xk = [];
        yk = [];
        return;
    end

    inlierPoints01 = matchedPoints01(inlierIdx, :); % Use valid inlier indices

    % Transform the frame
    RA = imref2d(size(I00));
    I01t = imwarp(I01, tform01, 'OutputView', RA);

    % Extract mask points based on the transformed mask
    [x, y] = find(maskBW); % Get logical indices of the mask
    points = [x, y, ones(length(x), 1)]'; % Homogeneous coordinates
    T = tform01.T; % Transformation matrix

    % Transform points
    transformedPoints = T * points;
    xk = transformedPoints(1, :) ./ transformedPoints(3, :); % Normalize x
    yk = transformedPoints(2, :) ./ transformedPoints(3, :); % Normalize y
end
