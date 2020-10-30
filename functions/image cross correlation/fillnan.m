function [u,v]=fillnan(u,v,varargin)
% function [u,v]=naninterp(u,v,method,mask,x,y)
%
% Interpolates NaN's in a vectorfield. Used by GLOBFILT, MEDIANFILT and
% VALIDATE. Sorts all spurious vectors based on the number of spurous
% neighbors to a point.  Uses FILLMISS.M to replace NaN's
% [u,v]=NANINTERP(u,v) Will replace all NaN's in u and v
% [u,v]=NANINTERP(u,v,[idxw idyw],x,y) Will replace NaN's but leave out
% areas that have been masked out (using MASK.M) Using the MASK option
% requires the x and y matrices input along with the u and v.  METHOD
% should be 'linear' or 'weighted' and defaults to 'linear'.

%This function is based upon a multipass solver written by Kristian Sveen
%as part of the matPIV toolbox. It has been adapted for use as part of GIV.
%It is distributed under the terms of the Gnu General Public License
%manager.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   %% GLACIER IMAGE VELOCIMETRY (GIV) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Code written by Max Van Wyk de Vries @ University of Minnesota
%Credit to Ben Popken and Andrew Wickert for portions of the toolbox.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Portions of this toolbox are based on a number of codes written by
%previous authors, including matPIV, IMGRAFT, PIVLAB, M_Map and more.
%Credit and thanks are due to the authors of these toolboxes, and for
%sharing their codes online. See the user manual for a full list of third 
%party codes used here. Accordingly, you are free to share, edit and
%add to this GIV code. Please give us credit if you do, and share your code 
%with the same conditions as this.

% Read the associated paper here: 
% https://doi.org/10.5194/tc-2020-204
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %Version 0.7, Autumn 2020%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  %Feel free to contact me at vanwy048@umn.edu%

usr=1;
if ~any(strcmp(varargin,'linear')) & ~any(strcmp(varargin,'weighted'))
    met='linear';
else
    tm=cellfun('isclass',varargin,'char');
    if sum(tm)==3
        disp('Wrong input to naninterp!'); return
    end
    met=varargin(tm(1));
end

%%%%%%%%%%%%%%%%%%%%%
if strcmp(met,'weighted')==1 & ~strcmp(met,'linear')==1
    
    if length(varargin)==4
        maske=varargin{2}; if ischar(maske) & ~isempty(maske), maske=load(maske); maske=maske.maske; end  
        if isempty(maske)
            [u,v]=fillnan2(u,v); usr=any(isnan(u(:)));
        else      
            xx=varargin{3}; yy=varargin{4};
            while usr~=0
                in2=zeros(size(xx));
                for i=1:length(maske)
                    in=inpolygon(xx,yy,maske(i).idxw,maske(i).idyw);
                    in2=in2+double(in);                    
                end
                in2=logical(in2);
                % interpolate NaN's using FILLMISS.M
                u(in2)=0; v(in2)=0;
                u=fillmiss(u); v=fillmiss(v);
                usr=any(isnan(u(:)));
                u(in2)=nan; v(in2)=nan;
            end
            u(in2)=NaN; v(in2)=NaN;
            numm=size(in2,1)*size(in2,2);
        end
    else
        while usr~=0
            numm=sum(isnan(u(:)));
            % interpolate NaN's using FILLMISS.M
            u=fillmiss(u); v=fillmiss(v);
            usr=any(isnan(u(:)));
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
elseif strcmp(met,'linear')==1 & ~strcmp(met,'weighted')==1
    
    if length(varargin)==4
        maske=varargin{2}; if ischar(maske) & ~isempty(maske),maske=load(maske);maske=maske.maske; end  
        if isempty(maske)
            [u,v]=fillnan2(u,v); usr=any(isnan(u(:)));
        else
            xx=varargin{3}; yy=varargin{4};
            maske=rmfield(maske,'msk'); % this is done to avoid the large matrix 
            %being copied into the next function.
            [u,v]=fillnan2(u,v,maske,xx,yy);
        end
    else
        while usr~=0
            % interpolate NaN's using fillnan2.M
            [u,v]=fillnan2(u,v); usr=any(isnan(u(:)));
        end
    end
else
    disp('Something is EXTREMELY wrong with your input'); return  
end

