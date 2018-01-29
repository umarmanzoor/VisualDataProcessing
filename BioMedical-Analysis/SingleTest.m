colors=['b' 'g' 'r' 'c' 'm' 'y'];

originalImage = imread('Images/autoSegments/train/MGF1-Cross-0009.tif');
%imshow(originalImage);
%hold on;

%Convert to grayscale 
if size(originalImage,3) == 3
    originalImage = rgb2gray(originalImage);
end

[BW, cellMask] = segmentImage(originalImage);
%imshow(BW);

% Remove small pixels
BWfiltered = bwareaopen(BW, 200);
imshow(BWfiltered);
hold on;
%imshowpair(BW,BWfiltered,'montage')

%Generate Rectangles
[B,L] = bwboundaries(BWfiltered);
segmentedRectanglesCount = 1;
for j = 1:length(B)               
   objectBoundary = B{j};
    x = objectBoundary(:,2);
    y = objectBoundary(:,1);
    minX = min(x);
    maxX = max(x);
    minY = min(y);
    maxY = max(y);
    width = maxX - minX;
    height = maxY - minY;
    segmentedRectangles{segmentedRectanglesCount} = [minX minY width height];
    segmentedRectanglesCount = segmentedRectanglesCount + 1;
    %rectangle('Position',[minX minY width height], 'EdgeColor','y')
    
%    objectMask = poly2mask(x(b),y(b), row, col);                    
%    objectMask = poly2mask(objectBoundary(:, 2),objectBoundary(:, 1), row, col);
   cidx = mod(j,length(colors))+1;
   plot(objectBoundary(:,2), objectBoundary(:,1),colors(cidx),'LineWidth',2);
end
disp('Removing Overlapping Rectangles'); 
for i = 1:length(segmentedRectangles)
    for j = 1:length(segmentedRectangles)
        if(i ~= j)
            R1 = segmentedRectangles{i};
            rectangle('Position',R1, 'EdgeColor','y')
            R2 = segmentedRectangles{j};
            rectangle('Position',R2, 'EdgeColor','y')
            overlapRatio = calculateOverlap(R1,R2);
            if(overlapRatio > 0.80)
                rectangle('Position',R1, 'EdgeColor','y')
                %rectangle('Position',R2, 'EdgeColor','y')
                disp('Here');
            end
        end
    end
end

function [overlapRatio] = calculateOverlap(bb1, bb2)
    areaIntersection = rectint(bb1,bb2);
    bb1Xmin = bb1(1);
    bb1Xmax = bb1(1) + bb1(3);
    bb1Ymin = bb1(2);
    bb1Ymax = bb1(2) + bb1(4);
    
    bb2Xmin = bb2(1);
    bb2Xmax = bb2(1) + bb2(3);
    bb2Ymin = bb2(2);
    bb2Ymax = bb2(2) + bb2(4);
    if(bb1Xmin < bb2Xmin)
        Xmin = bb1Xmin;
    else
        Xmin = bb2Xmin;
    end
    
    if(bb1Xmax < bb2Xmax)
        Xmax = bb1Xmax;
    else
        Xmax = bb2Xmax;
    end

    if(bb1Ymin < bb2Ymin)
        Ymin = bb1Ymin;
    else
        Ymin = bb2Ymin;
    end
    
    if(bb1Ymax < bb2Ymax)
        Ymax = bb1Ymax;
    else
        Ymax = bb2Ymax;
    end
    
    X_width = Xmax - Xmin;
    X_height = Ymax - Ymin;
    
    areaUnion = X_width * X_height;
    overlapRatio = areaIntersection / areaUnion;
end