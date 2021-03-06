function generateDatasetManualSegment(folderPath, showImage) 
    MyFolderInfo = dir(folderPath);
    MyFolderInfo=MyFolderInfo(~ismember({MyFolderInfo.name},{'.','..'}));    
    axonsCount = 1;
    myelinCount = 1;
    schwannCount = 1;
    outputfile = 'Output/regionsInfoGridTest.txt';
    outputfid = fopen(outputfile,'w');
    cellSize = 100;
    global gridLabels;
    global gridOverlapScore;    
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
                       originalImage = rgb2gray(originalImage);                      
                   end
                   if(showImage)
                       imshow(originalImage);
                       hold on;
                   end
                   [xboxes, yboxes] = generateGrid(rows, columns, cellSize);                   
                   gridLabels = zeros(xboxes*yboxes, 1 , 'uint32');
                   gridOverlapScore = zeros(xboxes*yboxes, 1);
               else
                   [row, col] = size(originalImage);
                   % Reading Axons masks
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
                               % Convert ImageJ ROI to a mask.
                               mask = poly2mask(sROI.mnCoordinates(:,1),sROI.mnCoordinates(:,2), row, col);
                               plot(sROI.mnCoordinates(:,1),sROI.mnCoordinates(:,2), 'Color', 'b', 'LineWidth', 1);
                               [Y, X] = find(mask);
                               % Generate Labels
                               generateLabels(X, Y, xboxes, yboxes, cellSize, "axon");
                               %rectDim = generateRect(sROI.mnCoordinates(:,1),sROI.mnCoordinates(:,2));
                               %fprintf(outputfid,'%s~%s~%s~%d~%d~%d~%d~%d~%d\r\n',fileName, AxonInfo(a).name, 'Axon', rectDim(1), rectDim(2), rectDim(3), rectDim(4), rows, columns);                               
                               maskedRgbImage = bsxfun(@times, originalImage, cast(mask, 'like', originalImage));
                               axons{axonsCount, 1} = MyFolderInfo(k).name;
                               axons{axonsCount, 2} = ImageInfo(i).name;
                               axons{axonsCount, 3} = maskedRgbImage;
                               axonsCount = axonsCount + 1;
                               if(showImage)
                                   %imshow(maskedRgbImage);
                                   [B,~,~,~] = bwboundaries(mask);
                                   boundary = B{1};
                                   plot(boundary(:,2), boundary(:,1),'Color', 'b','LineWidth',1);                                                                  
                               end
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
                                   myelinPairFirstFile = strcat(MyelinInfo(a).folder, "/");
                                   myelinPairFirstFile = strcat(myelinPairFirstFile, MyelinInfo(a).name);
                                   sROIFirst = ReadImageJROI(char(myelinPairFirstFile));

                                   secondFileName = strrep(MyelinInfo(a).name,'iM','oM');
                                   myelinPairSecondFile = strcat(MyelinInfo(a).folder, "/");
                                   myelinPairSecondFile = strcat(myelinPairSecondFile, secondFileName);
                                   sROISecond = ReadImageJROI(char(myelinPairSecondFile));
                                   % Convert ImageJ ROI to a mask.                           
                                   innerMask = poly2mask(sROIFirst.mnCoordinates(:,1),sROIFirst.mnCoordinates(:,2), row, col);%                                  
                                   outerMask = poly2mask(sROISecond.mnCoordinates(:,1),sROISecond.mnCoordinates(:,2), row, col);
                                   plot(sROISecond.mnCoordinates(:,1),sROISecond.mnCoordinates(:,2), 'Color', 'b', 'LineWidth', 1);
                                   [Y, X] = find(outerMask);
                                   
                                   % Generate Labels
                                   generateLabels(X, Y, xboxes, yboxes, cellSize, "myelin");

                                   %rectDim = generateRect(sROISecond.mnCoordinates(:,1),sROISecond.mnCoordinates(:,2));
                                   %fprintf(outputfid,'%s~%s~%s~%d~%d~%d~%d~%d~%d\r\n',fileName, MyelinInfo(a).name, 'Myelin', rectDim(1), rectDim(2), rectDim(3), rectDim(4), rows, columns);
                                   innerArea = imsubtract(outerMask,innerMask);
                                   maskedRgbImage = bsxfun(@times, originalImage, cast(innerArea, 'like', originalImage));                                   
                                   %imshow(maskedRgbImage);
                                   myelin{myelinCount, 1} = MyFolderInfo(k).name;
                                   myelin{myelinCount, 2} = ImageInfo(i).name;
                                   myelin{myelinCount, 3} = maskedRgbImage;
                                   myelinCount = myelinCount + 1;
                                   if(showImage)
                                       [B1,~,~,~] = bwboundaries(innerMask);
                                       boundary1 = B1{1};
                                       plot(boundary1(:,2), boundary1(:,1),'Color', 'g','LineWidth',2);                         
                                       [B2,~,~,~] = bwboundaries(outerMask);
                                       boundary2 = B2{1};
                                       plot(boundary2(:,2), boundary2(:,1),'Color', 'g','LineWidth',2);                         
                                       %imshow(mask);
                                   end
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
                               mask = poly2mask(sROI.mnCoordinates(:,1),sROI.mnCoordinates(:,2), row, col);
                               plot(sROI.mnCoordinates(:,1),sROI.mnCoordinates(:,2), 'Color', 'b', 'LineWidth', 1);
                               [Y, X] = find(mask);
                               % Generate Labels
                               generateLabels(X, Y, xboxes, yboxes, cellSize, "schwann");
                               % Convert ImageJ ROI to a mask.  
                               %rectDim = generateRect(sROI.mnCoordinates(:,1),sROI.mnCoordinates(:,2));
                               %fprintf(outputfid,'%s~%s~%s~%d~%d~%d~%d~%d~%d\r\n',fileName, SchwannInfo(a).name, 'Schwann', rectDim(1), rectDim(2), rectDim(3), rectDim(4), rows, columns);
                               
                               maskedRgbImage = bsxfun(@times, originalImage, cast(mask, 'like', originalImage));
                               %imshow(maskedRgbImage);
                               schwann{schwannCount, 1} = MyFolderInfo(k).name;
                               schwann{schwannCount, 2} = ImageInfo(i).name;
                               schwann{schwannCount, 3} = maskedRgbImage;
                               schwannCount = schwannCount + 1;
                               if(showImage)
                                   [B,~,~,~] = bwboundaries(mask);
                                   boundary = B{1};
                                   plot(boundary(:,2), boundary(:,1),'Color', 'r','LineWidth',2);                                                          
                               end
                           end
                       end
                   end
               end            
           end           
           if(showImage)
              gridSize = yboxes * xboxes;
              xCount = 0;
              row = 1;
              yPos = cellSize / 2;
              xPos = cellSize / 2;
               rectX = 1;
               rectY = 1;
              for x= 1: gridSize
                  if(xCount==xboxes)
                      row = row + 1;
                      xPos = ((row-1) * cellSize) + (cellSize / 2);
                      yPos = cellSize / 2;
                      xCount = 0;
                       rectY = 1; 
                       rectX = rectX + cellSize;
                  end
                  label = gridLabels(x);
                  if(label==0)
                     l = 'N';
                  elseif(label==1)
                     l = 'A';
                  elseif(label==2)
                     l = 'M';
                  else
                     l = 'S';
                  end                 
                   text(xPos, yPos,l, 'Color','red');
                   yPos = yPos + cellSize;
                   rectangle('Position',[rectX, rectY, cellSize, cellSize], 'EdgeColor','b')
                   fprintf(outputfid,'%s~%s~%d~%d~%d~%d~%d~%d\r\n', fileName, l, rectX, rectY, cellSize, cellSize, rows, columns);
                   xCount = xCount + 1;
                   rectY = rectY + cellSize;
              end
               saveFigures(fileName);
               hold off;
               closeFigures();
           end
       end
    end
   fclose(outputfid);
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
    savingPath = 'Images/highlightedSegments/';
    savingPath = strcat(savingPath, fileName);
    imwrite(im, savingPath)
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

function [Xboxes, Yboxes] = generateGrid(width, height, cellSize)
    Xboxes = round(width / cellSize);
    Yboxes = round(height / cellSize);
    row = 1;
    for i = 1 : Xboxes
      line([1, height], [row, row]);
      row = row + cellSize;
    end
    column = 1;
    for i = 1 : Yboxes
      line([column , column ], [1, width]);
      column = column + cellSize;
    end
end

function generateLabels(objectX, objectY, xBoxes, yBoxes, cellSize,cellLabel)
    %plot(objectX(:), objectY(:), 'Color', 'r', 'LineWidth', 1);
    gridSize = xBoxes * yBoxes;
    BoxCount = zeros(gridSize, 1);
    Points{gridSize} = [0, 0];
    global gridLabels;
    global gridOverlapScore;
    for i = 1 : length(objectX)
        xBoxNumber = fix(objectX(i) / cellSize) + 1;
        yBoxNumber = fix(objectY(i) / cellSize) + 1;
        BoxLocation = ((xBoxNumber-1) * xBoxes) + yBoxNumber;
        if(BoxLocation <= gridSize)
            BoxCount(BoxLocation) = BoxCount(BoxLocation) + 1; 
            Points{BoxLocation} = [Points{BoxLocation}; [objectX(i), objectY(i)]];            
        end
    end
    Values = find(BoxCount);
    for i = 1 : length(Values)
        boxPoints = Points{Values(i)};
        boxX = boxPoints(:, 1);
        boxY = boxPoints(:, 2);
        minX = min(boxX);
        maxX = max(boxX);
        minY = min(boxY);
        maxY = max(boxY);
        width = maxX - minX;
        height = maxY - minY;
        actualObj = [minX, minY, width, height];
        outerObj = [fix(minX/cellSize)*cellSize, fix(minY/cellSize)*cellSize, cellSize, cellSize];
        %rectangle('Position',actualObj, 'EdgeColor','y')        
        %rectangle('Position',outerObj, 'EdgeColor','b')
        overlapRatio = calculateOverlap(outerObj, actualObj, cellSize);
        if(overlapRatio > 0.20)
            numericLabel = getNumericLabel(cellLabel);
            if(gridLabels(Values(i))==0)
                gridLabels(Values(i)) = numericLabel;
                gridOverlapScore(Values(i)) = overlapRatio;
            else
                preOverlapScore = gridOverlapScore(Values(i));
                if(preOverlapScore < overlapRatio)
                    gridLabels(Values(i)) = numericLabel;
                    gridOverlapScore(Values(i)) = overlapRatio;                    
                end
            end
        end
    end
end

function [numericLabel] = getNumericLabel(label)
    if(label=="axon")
        numericLabel = 1;
    elseif(label=="myelin")
        numericLabel = 2;
    else
        numericLabel = 3;
    end
end

function [overlapRatio] = calculateOverlap(bb1, bb2, cellSize)
    areaIntersection = rectint(bb1,bb2);
    areaUnion = cellSize * cellSize;
    overlapRatio = areaIntersection / areaUnion;
end