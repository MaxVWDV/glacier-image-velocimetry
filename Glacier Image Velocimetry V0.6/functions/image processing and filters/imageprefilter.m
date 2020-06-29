function  out = imageprefilter (in, inputs)
%This function takes an initial image and filters it according to user
%inputted parameters to improve its potential for cross correlation.

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

%Note this funtion is partially based on the matlab 'PIVlab' toolbox. 
%Credit to the original authors.

if size(in,3)>1
    temp = zeros(size(in,1),size(in,2));
    for i = 1:size(in,3)
    temp = temp + double(in(:,:,i));
    end
    
    in = temp;

end

%this function preprocesses the images

    x=1;
    y=1;
    width=size(in,2)-1;
    height=size(in,1)-1;
%roi (x,y,width,height)
in_roi=(in(y:y+height,x:x+width));

% % % if inputs{28,2} == 1
% % %     %Intensity Capping: a simple method to improve cross-correlation PIV results
% % %     %Uri Shavit Æ Ryan J. Lowe Æ Jonah V. Steinbuck
% % %     n = 2; 
% % %     up_lim_im_1 = median(double(in_roi(:))) + n*std2(in_roi); % upper limit for image 1
% % %     brightspots_im_1 = find(in_roi > up_lim_im_1); % bright spots in image 1
% % %     capped_im_1 = in_roi; capped_im_1(brightspots_im_1) = up_lim_im_1; % capped image 1
% % %     in_roi=capped_im_1;
% % % end
% % % if inputs{24,2} == 1
% % %     numberoftiles1=round(size(in_roi,1)/inputs{25,2});
% % %     numberoftiles2=round(size(in_roi,2)/inputs{25,2});
% % %     if numberoftiles1 < 2
% % %     numberoftiles1=2;
% % %     end
% % %     if numberoftiles2 < 2
% % %     numberoftiles2=2;
% % %     end
% % %     in_roi=adapthisteq(in_roi, 'NumTiles',[numberoftiles1 numberoftiles2], 'ClipLimit', 0.01, 'NBins', 256, 'Range', 'full', 'Distribution', 'uniform');
% % % end
% % % 
% % % if inputs{26,2} == 1
% % %     h = fspecial('gaussian',inputs{27,2},inputs{27,2});
% % %     in_roi=double(in_roi-(imfilter(in_roi,h,'replicate')));
% % %     in_roi=in_roi/max(max(in_roi))*255;
% % % end

out=in;
out(y:y+height,x:x+width)=in_roi;
out=double(out);


if inputs{47,2} == 1
%Add orientation filter (see Filch et al., 2002:
%http://www.bmva.org/bmvc/2002/papers/95/full_95.pdf)

% filter_1 = [0 -1 0 ;-1 4 -1;0 -1 0]; % This one is anisotropic, but loses
% too much info

% filter_1 = [-1 -1 -1 ;-1 8 -1;-1 -1 -1];


filter_1 = [-1 2 -1];
filter_2 = [-1; 2; -1];

filter_3 = [-1 0 0;0 2 0; 0 0 -1];
filter_4 = [0 0 -1;0 2 0; -1 0 0]; %this combo is also anisotropic (i.e. centred on feature), but preserves info

% filter_1 = [-1 0 -1;0 4 0; -1 0 -1];
% filter_2 = [0 -1 0 ;-1 2 -1;  0 -1 0];


% filter_1 = [1; 0 ;-1];
% % % filter_2 = [1 0 -1];
% % % filter_3 = [1 0;0 -1];
% % % filter_4 = [0 1;-1 0];


out = real(exp(1i*atan2(imfilter(out,filter_1,'replicate'),imfilter(out,rot90(filter_1),'replicate'))))...
    +real(exp(1i*atan2(imfilter(out,filter_2,'replicate'),imfilter(out,rot90(filter_2),'replicate'))))...
    +real(exp(1i*atan2(imfilter(out,filter_2,'replicate'),imfilter(out,rot90(filter_2),'replicate'))))...
    +real(exp(1i*atan2(imfilter(out,filter_4,'replicate'),imfilter(out,rot90(filter_3),'replicate'))));
end


in = out;

if inputs{28,2} == 1
    %Intensity Capping: a simple method to improve cross-correlation PIV results
    %Uri Shavit Æ Ryan J. Lowe Æ Jonah V. Steinbuck
    n = 2; 
    up_lim_im_1 = median(double(in(:))) + n*std2(in); % upper limit for image 1
    brightspots_im_1 = find(in > up_lim_im_1); % bright spots in image 1
    capped_im_1 = in; capped_im_1(brightspots_im_1) = up_lim_im_1; % capped image 1
    in=capped_im_1;
end
if inputs{24,2} == 1
    numberoftiles1=round(size(in,1)/inputs{25,2});
    numberoftiles2=round(size(in,2)/inputs{25,2});
    if numberoftiles1 < 2
    numberoftiles1=2;
    end
    if numberoftiles2 < 2
    numberoftiles2=2;
    end
    in=adapthisteq(in, 'NumTiles',[numberoftiles1 numberoftiles2], 'ClipLimit', 0.01, 'NBins', 256, 'Range', 'full', 'Distribution', 'uniform');
end

if inputs{26,2} == 1
    h = fspecial('gaussian',inputs{27,2},inputs{27,2});
    in=double(in-(imfilter(in,h,'replicate')));
    in=in/max(max(in))*255;
end

if inputs{48,2} == 1
 in = SobelFilter(in,3);
end

if inputs{49,2} == 1
 in = LaplaceFilter(in,4);
end

out = in;