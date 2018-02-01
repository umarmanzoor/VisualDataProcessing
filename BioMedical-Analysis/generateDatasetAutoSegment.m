function generateDatasetAutoSegment(folderPath, showImage) 
    MyFolderInfo = dir(folderPath);
    MyFolderInfo=MyFolderInfo(~ismember({MyFolderInfo.name},{'.','..'}));    
    gtMyleinCount = 0;
    pMyleinCount = 0;
    gtSchwannCount = 0;
    pSchwannCount = 0;
    gtAxonCount = 0;
    pAxonCount = 0;
    global segmentedRectanglesCount;
    global segmentedRectangles;
    
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
                   [rows, cols, numberOfColorChannels] = size(originalImage);
                   if numberOfColorChannels > 1
                       grayImage = originalImage(:, :, 2); %rgb2gray(originalImage);
                   else
                       grayImage = originalImage;
                   end
                   sumOfAllGrayLevels = (sum(sum(grayImage)))/(rows*cols);
                   disp(fileName)
                   disp(sumOfAllGrayLevels);
                   if(showImage)
                      imshow(grayImage);
                      hold on;
                   end                 
                    [S1, S2] = segmentImage(grayImage);
                    % Remove small pixels
                    BWfiltered = bwareaopen(S1, 50);                                       
                    [B1] = bwboundaries(S1);
                    [B2] = bwboundaries(S2);
                    segmentedRectanglesCount = 1;
                    segmentedRectangles = zeros(4);
                    predictedSegments(B1);
                    predictedSegments(B2);
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
                   if(strcmp(ImageInfo(i).name, "axons")==1)
                       % Read all axons Masks
                       axonspath = strcat(ImageInfo(i).folder, "/");
                       axonspath = strcat(axonspath, ImageInfo(i).name);
                       AxonInfo = dir(char(axonspath));
                       for a = 1 : size(AxonInfo)
                           if(~AxonInfo(a).isdir)
                               D = ['Reading Axons ', AxonInfo(a).name];
                               disp(D);                                                      
                               axonFile = strcat(AxonInfo(a).folder, "/");
                               axonFile = strcat(axonFile, AxonInfo(a).name);
                               sROI = ReadImageJROI(char(axonFile));                             
                               gtRect = generateRect(sROI.mnCoordinates(:,1),sROI.mnCoordinates(:,2));
                               plot(sROI.mnCoordinates(:,1),sROI.mnCoordinates(:,2), 'Color', 'b', 'LineWidth', 1);
                               if(evaluateAutoSegmented(gtRect, segmentedRectangles))
                                   pAxonCount = pAxonCount + 1;
                               end
                               gtAxonCount = gtAxonCount + 1;                           
                           end
                       end
                   end
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
                                   plot(sROISecond.mnCoordinates(:,1),sROISecond.mnCoordinates(:,2), 'Color', 'g', 'LineWidth', 1);
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
                               plot(sROI.mnCoordinates(:,1),sROI.mnCoordinates(:,2), 'Color', 'r', 'LineWidth', 1);
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
    X = ['Total Myleim ', num2str(gtMyleinCount),' Matched ', num2str(pMyleinCount), 'Percentage ', num2str(pMyleinCount/gtMyleinCount)];
    disp(X);
    X = ['Total Schwann ', num2str(gtSchwannCount),' Matched ', num2str(pSchwannCount), 'Percentage ', num2str(pSchwannCount/gtSchwannCount)];
    disp(X);
    X = ['Total Axons ', num2str(gtAxonCount),' Matched ', num2str(pAxonCount), 'Percentage ', num2str(pAxonCount/gtAxonCount)];
    disp(X);
end

function predictedSegments(B)
    global segmentedRectangles;
    global segmentedRectanglesCount;
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
           %rectangle('Position',[minX minY width height], 'EdgeColor','b')
           segmentedRectangles(segmentedRectanglesCount, 1) = minX; 
           segmentedRectangles(segmentedRectanglesCount, 2) = minY;
           segmentedRectangles(segmentedRectanglesCount, 3) = width;
           segmentedRectangles(segmentedRectanglesCount, 4) = height;
           %segmentedRectangles(segmentedRectanglesCount, 5) = area;
           segmentedRectanglesCount = segmentedRectanglesCount + 1;                       
       end
    end
end



function [matched] = evaluateAutoSegmented(R1, segmentedRects)
    disp('Matching in Progress...')
    matched = 0;
    for i = 1:length(segmentedRects)
        R2 = [segmentedRects(i, 1) segmentedRects(i, 2) segmentedRects(i, 3) segmentedRects(i, 4)];
        if(calculateOverlap(R1, R2)> 0.60)
            rectangle('Position',R2, 'EdgeColor','y')
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
    savingPath = 'Images/pixelsize/20um/Output/Gray/';
    savingPath = strcat(savingPath, fileName);
    imwrite(im, savingPath)
end

function [overlapRatio] = calculateOverlap(bb1, bb2)
    areaIntersection = rectint(bb1,bb2);
    areabb1 = bb1(3)*bb1(4);
    areabb2 = bb2(3)*bb2(4);
    
    overlapRatio = areaIntersection / (areabb1 + areabb2 - areaIntersection);
end

function [rectDim] = generateRect(X, Y)
    minX = min(X);
    maxX = max(X);
    minY = min(Y);
    maxY = max(Y);
    width = maxX - minX;
    height = maxY - minY;
    rectDim = [minX minY width height];
    %rectangle('Position',rectDim, 'EdgeColor','y')
end