function [x0,y0]=GIVtrackmultipeak(x1,y1,R,Rxm1,Rxp1,Rym1,Ryp1,method,N)
%
% INTPEAK - sub-pixel peak finder
%
% function [x0,y0]=GIVtrackmultipeak(x1,x2,x3,y1,y2,y3,method,N)
% METHOD = 
% 1 for centroid fit, 
% 2 for gaussian fit, 
% 3 for parabolic fit
% x1 and y1 are maximal values in respective directions.
% N is interrogation window size. N is either 1x1 or 1x2
%

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
% doi.org/10.5194/tc-15-2115-2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %Version 1.0, Spring-Summer 2021%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  %Feel free to contact me at vanwy048@umn.edu%

if length(N)==2
    M=N(1); N=N(2);
else
    M=N;
end

if any(find(([R Rxm1 Rxp1 Rym1 Ryp1])==0))
    % to avoid Log of Zero warnings
    method=1;
end

if method==1  
    x01=(((x1-1)*Rxm1)+(x1*R)+((x1+1)*Rxp1)) / (Rxm1+ R+Rxp1);
    y01=(((y1-1)*Rym1)+(y1*R)+((y1+1)*Ryp1)) / (Rym1+ R+Ryp1);
    x0=x01-(M);
    y0=y01-(N);
elseif method==2  
    x01=x1 + ( (log(Rxm1)-log(Rxp1))/( (2*log(Rxm1))-(4*log(R))+(2*log(Rxp1))) );
    y01=y1 + ( (log(Rym1)-log(Ryp1))/( (2*log(Rym1))-(4*log(R))+(2*log(Ryp1))) );  
    x0=x01-(M);
    y0=y01-(N);  
elseif method==3
    x01=x1 + ( (Rxm1-Rxp1)/( (2*Rxm1)-(4*R)+(2*Rxp1)) );
    y01=y1 + ( (Rym1-Ryp1)/( (2*Rym1)-(4*R)+(2*Ryp1)) ); 
    x0=x01-(M);
    y0=y01-(N);
    
    
else
    
    disp(['Please include your desired peakfitting function; 1 for',...
	  ' 3-point fit, 2 for gaussian fit, 3 for parabolic fit'])
    
end

x0=real(x0);
y0=real(y0);
