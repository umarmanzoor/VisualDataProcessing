% Generate the boundary of the object
% Created by Umar Manzoor

function objBoundary = boundaryLocator(image, objMask)
    blackImage = 0 * image;
    obj = im2bw(blackImage);
    obj(~objMask)=255;
    boundaries = bwboundaries(obj);
    objBoundary = boundaries{1};
end
