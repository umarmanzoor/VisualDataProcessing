function generateDatasetAutoSegment(folderPath, showImage) 
    MyFolderInfo = dir(folderPath);
    MyFolderInfo=MyFolderInfo(~ismember({MyFolderInfo.name},{'.','..'}));    
    gtMyleinCount = 0;
    pMyleinCount = 0;
    gtSchwannCount = 0;
    pSchwannCount = 0;
  
    % Iterating folder contents
    for k = 1 : size(MyFolderInfo)    
       if(MyFolderInfo(k).isdir)
           D = ['Reading Contents of', MyFolderInfo(k).name];
           disp(D);
           subfolder = strcat(MyFolderInfo(k).folder + "/");
           subfolder = strcat(subfolder, MyFolderInfo(k).name);
           ImageInfo = dir(char(subfolder));
           ImageInfo=ImageInfo(~ismember({ImageInfo.name},{'.','..'}));
           % Iterating subfolder contents
           for i = 1 : size(ImageInfo)
               if(~ImageInfo(i).isdir)
                   % Original Image
                   fileName = ImageInfo(i).name;
                   filepath = strcat(ImageInfo(i).folder, "/");
                   filepath = strcat(filepath, ImageInfo(i).name);
                   originalImage = imread(char(filepath));               
                   [rows, columns, numberOfColorChannels] = size(originalImage);
                   if numberOfColorChannels > 1
                       grayImage = rgb2gray(originalImage);
                   else
                       grayImage = originalImage;
                   end
                   if(showImage)
                       imshow(originalImage);
                       hold on;
                   end
                    [BW, cellMask] = segmentImage(grayImage);
                    % Remove small pixels
                    BWfiltered = bwareaopen(BW, 200);
                    %Generate Rectangles
                    [B,L] = bwboundaries(BWfiltered);
                    segmentedRectanglesCount = 1;
                    segmentedRectangles = zeros(4);
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
                       area = width * height;                       
                       if(area > 200 && area < 370000)
                           %rectangle('Position',[minX minY width height], 'EdgeColor','r')
                           segmentedRectangles(segmentedRectanglesCount, 1) = minX; 
                           segmentedRectangles(segmentedRectanglesCount, 2) = minY;
                           segmentedRectangles(segmentedRectanglesCount, 3) = width;
                           segmentedRectangles(segmentedRectanglesCount, 4) = height;
                           %segmentedRectangles(segmentedRectanglesCount, 5) = area;
                           segmentedRectanglesCount = segmentedRectanglesCount + 1;                       
                       end
                    end
%                     sortedSegmentedRectangles = sortrows(segmentedRectangles, 5);                    
%                     disp('Removing Overlapping Rectangles');
%                     s = length(sortedSegmentedRectangles);
%                     filteredSegmentedRectanglesCount = 1;
%                     filteredSegmentedRectangles{s} = [];
%                     for a = s:-1:1
%                             disp(a);
%                         for b = a-1:-1:1
%                             if(a ~= b)
%                                 R1 = [sortedSegmentedRectangles(a, 1) sortedSegmentedRectangles(a, 2) sortedSegmentedRectangles(a, 3) sortedSegmentedRectangles(a, 4)];
%                                 rectangle('Position',R1, 'EdgeColor','y')
%                                 R2 = [sortedSegmentedRectangles(b, 1) sortedSegmentedRectangles(b, 2) sortedSegmentedRectangles(b, 3) sortedSegmentedRectangles(b, 4)];
%                                 rectangle('Position',R2, 'EdgeColor','y')
%                                 overlapRatio = calculateOverlap(R1,R2);
%                                 if(overlapRatio > 0.80)
%                                     filteredSegmentedRectangles{filteredSegmentedRectanglesCount} = R1;
%                                     filteredSegmentedRectanglesCount = filteredSegmentedRectanglesCount + 1;
%                                 end
%                             end    
%                         end                        
%                         %[s, sortedSegmentedRect]=removeOverlappingRectangles(sortedSegmentedRect);
%                     end
%                     % Display filtered boundaries
%                     for a = 1:filteredSegmentedRectanglesCount
%                         rectDim = filteredSegmentedRectangles{a};
%                         rectangle('Position',rectDim, 'EdgeColor','y')                        
%                     end
               else
                   [row, col] = size(originalImage);
                   % Reading Myelin
                   if(strcmp(ImageInfo(i).name, "myelin")==1)
                       % Read all myelin Masks
                       myelinpath = strcat(ImageInfo(i).folder, "/");
                       myelinpath = strcat(myelinpath, ImageInfo(i).name);
                       MyelinInfo = dir(char(myelinpath));
                       for a = 1 : size(MyelinInfo)
                           if(~MyelinInfo(a).isdir)                           
                               found = contains(MyelinInfo(a).name,'iM');
                               if(found)
                                   D = ['Reading Myelin ', MyelinInfo(a).name];
                                   disp(D);                               
                                   secondFileName = strrep(MyelinInfo(a).name,'iM','oM');
                                   myelinPairSecondFile = strcat(MyelinInfo(a).folder, "/");
                                   myelinPairSecondFile = strcat(myelinPairSecondFile, secondFileName);
                                   sROISecond = ReadImageJROI(char(myelinPairSecondFile));
                                   gtRect = generateRect(sROISecond.mnCoordinates(:,1),sROISecond.mnCoordinates(:,2));
                                   if(evaluateAutoSegmented(gtRect, segmentedRectangles))
                                       pMyleinCount = pMyleinCount + 1;
                                   end
                                   gtMyleinCount = gtMyleinCount + 1;
                               end
                           end
                       end
                   end
                   % Reading Schwann Masks
                   if(strcmp(ImageInfo(i).name, "schwann")==1)
                       % Read all schwann Masks
                       schwannpath = strcat(ImageInfo(i).folder, "/");
                       schwannpath = strcat(schwannpath, ImageInfo(i).name);
                       SchwannInfo = dir(char(schwannpath));
                       for a = 1 : size(SchwannInfo)
                           if(~SchwannInfo(a).isdir)
                               D = ['Reading Schwann ', SchwannInfo(a).name];
                               disp(D);
                               schwannFile = strcat(SchwannInfo(a).folder, "/");
                               schwannFile = strcat(schwannFile, SchwannInfo(a).name);
                               sROI = ReadImageJROI(char(schwannFile));
                               gtRect = generateRect(sROI.mnCoordinates(:,1),sROI.mnCoordinates(:,2));
                               if(evaluateAutoSegmented(gtRect, segmentedRectangles))
                                   pSchwannCount = pSchwannCount + 1;
                               end
                               gtSchwannCount = gtSchwannCount + 1;                               
                           end
                       end
                   end
               end            
           end           
           if(showImage)
               saveFigures(fileName);
               hold off;
               closeFigures();
           end
       end
    end
    disp('Total Myleim');
    disp(gtMyleinCount);
    disp('Matched Myleim');
    disp(pMyleinCount);
    disp('Total Schwann');
    disp(gtSchwannCount);
    disp('Matched Schwann');
    disp(pSchwannCount);


end

function [matched] = evaluateAutoSegmented(R1, segmentedRects)
    disp('Matching in Progress...')
    matched = 0;
    for i = 1:length(segmentedRects)
        R2 = [segmentedRects(i, 1) segmentedRects(i, 2) segmentedRects(i, 3) segmentedRects(i, 4)];
        if(calculateOverlap(R1, R2)> 0.50)
            matched = 1;
        end
    end
    disp('Matching Completed...')
    if(matched)
        disp('Matched with Gt');
    else
        disp('Not Matched with Gt');
    end
end

function [reducedlist] = removeOverlappingRectangles(a, R1, sortedSegmentedRect)
    indexs = [];
    indexs = [indexs, a];
    for b = 1:length(segmentedRectangles)
        disp(b);
        if(a ~= b)
            %rectangle('Position',R1, 'EdgeColor','y')
            R2 = segmentedRectangles{b};
            R2 = [R2(1) R2(2) R2(3) R2(4)];
            %rectangle('Position',R2, 'EdgeColor','y')
            overlapRatio = calculateOverlap(R1,R2);
            if(overlapRatio > 0.80)
                indexs = [indexs, b];
            end
        end    
    end
    reducedlist = sortedSegmentedRect;
    disp(length(reducedlist));
end

function closeFigures()
    delete(findall(0,'Type','figure'))
    bdclose('all')
    allPlots = findall(0, 'Type', 'figure', 'FileName', []);
    delete(allPlots);
end

function saveFigures(fileName)
    frame = getframe(1);
    im = frame2im(frame);
    imshow(im);
    savingPath = 'Images/autoSegmented/';
    savingPath = strcat(savingPath, fileName);
    imwrite(im, savingPath)
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

function [rectDim] = generateRect(X, Y)
    minX = min(X);
    maxX = max(X);
    minY = min(Y);
    maxY = max(Y);
    width = maxX - minX;
    height = maxY - minY;
    rectDim = [minX minY width height];
    rectangle('Position',rectDim, 'EdgeColor','y')
end