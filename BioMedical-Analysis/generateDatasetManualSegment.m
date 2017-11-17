function [axons, myelin, schwann] = generateDatasetManualSegment(folderPath, showImage) 
    MyFolderInfo = dir(folderPath);
    MyFolderInfo=MyFolderInfo(~ismember({MyFolderInfo.name},{'.','..'}));    
    axonsCount = 1;
    myelinCount = 1;
    schwannCount = 1;
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
                               maskedRgbImage = bsxfun(@times, originalImage, cast(mask, 'like', originalImage));
                               axons{axonsCount, 1} = MyFolderInfo(k).name;
                               axons{axonsCount, 2} = ImageInfo(i).name;
                               axons{axonsCount, 3} = maskedRgbImage;
                               axonsCount = axonsCount + 1;
                               if(showImage)
                                   %imshow(maskedRgbImage);
                                   [B,~,~,~] = bwboundaries(mask);
                                   boundary = B{1};
                                   plot(boundary(:,2), boundary(:,1),'Color', 'b','LineWidth',2);                               
                                   
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
                               % Convert ImageJ ROI to a mask.                           
                               mask = poly2mask(sROI.mnCoordinates(:,1),sROI.mnCoordinates(:,2), row, col);
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
            hold off;
            closeFigures();
           end
       end
    end
end

function closeFigures()
    delete(findall(0,'Type','figure'))
    bdclose('all')
    allPlots = findall(0, 'Type', 'figure', 'FileName', []);
    delete(allPlots);
end