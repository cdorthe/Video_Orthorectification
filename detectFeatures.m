function [f, vpts, linID0, linIDx] = detectFeatures(I00, maskBW, ftrDtct)
    % Detect features using specified method (SURF or KAZE)
    disp('Detecting features...')
    if contains(ftrDtct, 'SURF')
        points = detectSURFFeatures(rgb2gray(I00));
    else
        points = detectKAZEFeatures(rgb2gray(I00));
    end
    [f, vpts] = extractFeatures(rgb2gray(I00), points);
    
    % Filter features using the mask
    subRow = round(vpts.Location(:, 2));
    subCol = round(vpts.Location(:, 1));
    linID0 = sub2ind([size(I00, 1), size(I00, 2)], subRow, subCol);
    linID1 = find(maskBW);
    linIDx = intersect(linID0, linID1);
end
