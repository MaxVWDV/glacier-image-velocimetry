function [V,fd] = xytoV(du, dv, mean_resolution, dt)
%input two direction files (x component of velocity, y component of
%velocity), output a flow direction and a velocity magnitude

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

    %% Calculate velocity
    
    
    V= abs((du-dv*1i)*mean_resolution/dt); %Using imaginary values to indicate direction (for convenience).

    
    %% Calculate flow direction
    
    dir_du = du;

    dir_dv = dv;

    ws = NaN*ones(size(dir_du));
    fd = NaN*ones(size(dir_du));
    e = find(~isnan(dir_du) & ~isnan(dir_dv));
    ws(e) = sqrt(dir_du(e).*dir_du(e) + dir_dv(e).*dir_dv(e));
    fd(e) = (180/pi)*atan2(dir_dv(e),dir_du(e));
    aaaa=fd;
    aaaa(fd>0) = 0;
    aaaa = abs(aaaa);
    aaaa(aaaa==0)=-90;
    aaaa=aaaa+90;
    bbbb = fd;
    bbbb(fd<0) = 0;
    bbbb=360-bbbb;
    bbbb(bbbb==360)=0;
    bbbb=bbbb+90;
    bbbb(bbbb==90)=0;
    cccc=bbbb;
    cccc(cccc<360)=0;
    cccc=cccc-360;
    cccc(cccc==-360)=0;
    bbbb(bbbb>360)=0;
    
    fd = aaaa+bbbb+cccc;