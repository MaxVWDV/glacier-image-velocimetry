function [images,inputs]=cropmask(images,inputs)
%%Crop images to a mask
%
%This function takes the original satellite images, crops them to a user
%determined mask and filters then according to the inputs. Possible image
%filters include an orientation mask, lowpass filters, contrast limited
%histogram equalization, intensity capping, Sobel filter and Laplacian
%filter. See user manual for details and recommended default settings.
%
%
%This mask should be a .png image with perfect white in all areas to be
%considered and any other color elsewhere.
%This can easly be made by opening one of the images from the timeseries in
%Paint or another image editor and simply drawing a white polygon over the
%area of interest.
%
%This should be named mask (.png) and saved in the same folder as the rest
%of the timeseries.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   %% GLACIER IMAGE VELOCIMETRY (GIV) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Toolbox written by Max Van Wyk de Vries @ University of Minnesota
%Credit to Andrew Wickert and Ben Popken for advice and portions of the code.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Portions of this toolbox are based on a number of codes written by
%previous authors, including matPIV, IMGRAFT, PIVLAB, M_Map and more.
%Credit and thanks are due to the authors of these toolboxes, and for
%sharing their codes online. See the user manual for a full list of third 
%party codes used here. Accordingly, you are free to share, edit and
%add to this GIV code. Please also give credit if you do, and share your code 
%with the same conditions as this.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %Version 0.6, Summer 2020%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  %Feel free to contact me at vanwy048@umn.edu%
                  
                  
if exist(fullfile(inputs{1,2},'mask.png'))  > 0  
    
cdata = imread(fullfile(inputs{1,2},'mask.png'));

elseif exist(fullfile(inputs{1,2},'mask.jpg')) >0
    
cdata = imread(fullfile(inputs{1,2},'mask.jpg'));

end



cdata = double(cdata);

cdata = double(cdata(:,:,1))+double(cdata(:,:,2))+double(cdata(:,:,3));

cdata(cdata==765) = NaN;

cdata(cdata>0)= 0;

cdata(isnan(cdata))= 1;

mask_0_1 = cdata;

inputs{52,1} = 'Cropping mask';

inputs{52,2} = mask_0_1;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DIMENSION CHECK. IF IMAGES and MASK are different sizes, make them the
%same size.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


size_matrix = zeros(size(images,1),2);

size_matrix(1,1) = size(mask_0_1,1);
size_matrix(1,2) = size(mask_0_1,2);


for i = 2:size(images,1)
    size_matrix(i,1) = size(images{i,3},1);
    size_matrix(i,2) = size(images{i,3},2);
    
end

for i = 2:size(images,1)
    if size(images{i,3},3)>1
    temp = zeros(size(images{i,3},1),size(images{i,3},2));
    for ii = 1:size(images{i,3},3)
    temp = temp + double(images{i,3}(:,:,ii));
    end
    images{i,3} = temp;
    end
end

if min(size_matrix(:,1)) ~= max(size_matrix(:,1)) || min(size_matrix(:,2)) ~= max(size_matrix(:,2))
    rightsizey = min(size_matrix(:,1));
    rightsizex = min(size_matrix(:,2));
    
    if size(mask_0_1,1) ~= rightsizey || size(mask_0_1,2) ~=rightsizex
       mask_0_1 = interp2(mask_0_1, linspace(1, size(mask_0_1,2), rightsizex).', linspace(1, size(mask_0_1,1), rightsizey));
    end

    
    for i = 2:size(images,1)
        if size(images{i,3},1) ~= rightsizey || size(images{i,3},2) ~=rightsizex 
            images{i,3} = interp2(images{i,3}, (linspace(1, size(images{i,3},2), rightsizex).'), linspace(1, size(images{i,3},1), rightsizey));
        end
    end
end
                      
                  
                  
                  
                  
                  
                  
if strcmpi(inputs{30,2}, 'Yes')
    

newcol = {};

parfor l = 2:size(images,1)
    a1 = double(imageprefilter(images{l,3}, inputs)); 
%     a1(mask_0_1 == 0) = NaN;
    newcol{l,3} = flipud(a1);
end

for i=2:size(images,1)
    images{i,3}=newcol{i,3};
end


elseif strcmpi(inputs{30,2}, 'No') 




for l = 2:size(images,1)
    a1 = double(imageprefilter(images{l,3}, inputs)); 
%     a1(mask_0_1 == 0) = NaN;
    images{l,3} = flipud(a1);
    l=l+1;
end

end


