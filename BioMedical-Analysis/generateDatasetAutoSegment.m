function [schwann] = generateDatasetAutoSegment(folderPath) 
%     %% Images
%     imageDir = fullfile(folderPath);
%     % Collection of images
%     imgSet = imageSet(imageDir);
%     methods(imgSet);
    I = imread('Images/autoSegments/train/95-17 Myelinated fiber-0002.tif');
    imshow(I); 
    eI = edge(I);
    imshow(eI);
%    hold on;
    [BW, cellMask] = segmentImage(I);
    imshow(BW)
    
    %imshowpair(BW,BW2,'montage')
    schwann = 1;
end