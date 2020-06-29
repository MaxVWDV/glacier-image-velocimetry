function [x,y,u,v,snr,Pkh]=GIVtrackmulti(AA,BB,winsize,overlap)
%
%
% PIV in multiple passes to eliminate the displacement bias.
% Utilizes the increase in S/N by  halving the size of the 
% interrogation windows after the first pass.
%

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


%This function is based upon a multipass solver written by Kristian Sveen
%as part of the matPIV toolbox. It has been adapted for use as part of GIV.
%It is distributed under the terms of the Gnu General Public License
%manager.

%%%%%%%%% First pass to estimate displacement in integer values:
[x,y,datax,datay]=GIVtrackmultifirst(AA,BB,winsize,overlap);

datax1 = datax;
datay1 = datay;
[datax1,datay1]=neighbourfilter(x,y,datax1,datay1,'median',3,3);
[datax1,datay1]=fillnan(datax1,datay1,'linear',x,y);
% datax1 = nanfillsm(datax1,inputs,4,3);
% datay1 = nanfillsm(datay1,inputs,4,3);

clear datax datay x y
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% expand the velocity data to twice the original size
% This is because we want to use half the interrogation
% window size from now on.
winsize=winsize/2;
[sy,sx]=size(AA);
X=(1:((1-overlap)*2*winsize):sx-2*winsize+1)+(2*winsize)/2;
Y=(1:((1-overlap)*2*winsize):sy-2*winsize+1)+(2*winsize)/2;
XI=(1:((1-overlap)*winsize):sx-winsize+1)+(winsize)/2;
YI=(1:((1-overlap)*winsize):sy-winsize+1)+(winsize)/2; 
datax1(:,size(X,2)+1:end)=[];
datax1(size(Y,2)+1:end,:)=[];
datay1(:,size(X,2)+1:end)=[];
datay1(size(Y,2)+1:end,:)=[];
datax=interp2(X,Y',datax1,XI,YI');
datay=interp2(X,Y',datay1,XI,YI');
[datax,datay]=fillnan(datax,datay,'linear',...
    repmat(XI,size(datax,1),1),repmat(YI',1,size(datax,2)));
datax=floor(datax); datay=floor(datay);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Second pass to estimate displacement in integer values:
% now using smaller interrogation windows 
% to utilize the smaller S/N introduced with window offset.
[x,y,datax2,datay2]=GIVtrackmultifirst(AA,BB,winsize,overlap,datax,datay);
[datax2,datay2]=neighbourfilter(x,y,datax2,datay2,'median',3,3);
[datax2,datay2]=fillnan(datax2,datay2,'linear',x,y);
% datax2 = nanfillsm(datax2,inputs,4,3);
% datay2 = nanfillsm(datay2,inputs,4,3);
clear x y

% expand the velocity data to twice the original size
% This is because we want to use half the interrogation
% window size from now on.
winsize=winsize/2;
[sy,sx]=size(AA);
X=(1:((1-overlap)*2*winsize):sx-4*winsize+1)+(4*winsize)/2;
Y=(1:((1-overlap)*2*winsize):sy-4*winsize+1)+(4*winsize)/2;
XI=(1:((1-overlap)*winsize):sx-winsize+1)+(winsize)/2;
YI=(1:((1-overlap)*winsize):sy-winsize+1)+(winsize)/2; 
datax2(:,size(X,2)+1:end)=[];
datax2(size(Y,2)+1:end,:)=[];
datay2(:,size(X,2)+1:end)=[];
datay2(size(Y,2)+1:end,:)=[];
datax1=interp2(X,Y',datax2,XI,YI');
datay1=interp2(X,Y',datay2,XI,YI');
[datax1,datay1]=fillnan(datax1,datay1,'linear',...
    repmat(XI,size(datax1,1),1),repmat(YI',1,size(datax1,2)));
datax1=floor(datax1); datay1=floor(datay1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Final pass. Gives displacement to subpixel accuracy.
 [x,y,u,v,snr,Pkh]=GIVtrackmultifinal(AA,BB,winsize,overlap,round(datax1),...
			    round(datay1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
