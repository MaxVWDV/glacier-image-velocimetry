function [V,fd] = xytoV(du, dv, dx, dy, dt)
%input two direction files (x component of velocity, y component of
%velocity), output a flow direction and a velocity magnitude

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

%% Calculate velocity
V= abs(((du.*dx)-(dv.*dy)*1i)/dt); %Using imaginary values to indicate direction (for convenience).

%% Calculate flow direction
dir_du = (du.*dx);
dir_dv = dv.*dy;
% ws = NaN*ones(size(dir_du));
fd = NaN*ones(size(dir_du));
e = find(~isnan(dir_du) & ~isnan(dir_dv));
% ws(e) = sqrt(dir_du(e).*dir_du(e) + dir_dv(e).*dir_dv(e));
fd(e) = (180/pi)*atan2(dir_dv(e),dir_du(e));
temp1=fd;
temp1(fd>0) = 0;
temp1 = abs(temp1);
temp1(temp1==0)=-90;
temp1=temp1+90;
temp2 = fd;
temp2(fd<0) = 0;
temp2=360-temp2;
temp2(temp2==360)=0;
temp2=temp2+90;
temp2(temp2==90)=0;
temp3=temp2;
temp3(temp3<360)=0;
temp3=temp3-360;
temp3(temp3==-360)=0;
temp2(temp2>360)=0;
fd = temp1+temp2+temp3;