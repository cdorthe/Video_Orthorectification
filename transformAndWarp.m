function [I01t, xyk, xtmp, ytmp] = transformAndWarp(I01, tform01, matchedPoints01, RA)
    % transformAndWarp - Applies a geometric transformation to an image and 
    % transforms feature points, returning the transformed image, feature 
    % points, and boundary points.
    %
    % Syntax: [I01t, xyk, xtmp, ytmp] = transformAndWarp(I01, tform01, matchedPoints01, RA)
    %
    % Inputs:
    %    I01 - The input image to be transformed.
    %    tform01 - The transformation object that describes the geometric 
    %              transformation to be applied to the image.
    %    matchedPoints01 - The matched feature points in the image.
    %    RA - The reference spatial reference object (for the output image view).
    %
    % Outputs:
    %    I01t - The transformed image after applying the geometric transformation.
    %    xyk - The transformed coordinates of the matched feature points.
    %    xtmp - The x-coordinates of the transformed boundary points.
    %    ytmp - The y-coordinates of the transformed boundary points.
    
    % Apply the inverse of the transformation to the image to warp it into a new view
    I01t = imwarp(I01, invert(tform01), 'FillValues', 0, 'OutputView', RA);
    
    % Transform the coordinates of the matched feature points using the inverse transformation
    [xk, yk] = transformPointsForward(invert(tform01), matchedPoints01.Location(:, 1), matchedPoints01.Location(:, 2));
    
    % Combine the transformed x and y coordinates into a single matrix
    xyk = [xk, yk];
    
    % Remove any rows where the transformed coordinates are NaN (invalid transformations)
    xyk(any(isnan(xyk), 2), :) = [];
    
    % Define the boundary points of the image for transformation
    boundaryPoints = single([[0 0 size(I01, 2) size(I01, 2)]', [0 size(I01, 1) size(I01, 1) 0]']);
    
    % Transform the boundary points using the inverse of the transformation
    [xtmp, ytmp] = transformPointsForward(invert(tform01), boundaryPoints(:, 1)', boundaryPoints(:, 2)');
end
