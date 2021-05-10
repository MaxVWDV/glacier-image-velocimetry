function [out]= SobelFilter(A,Wsize)
%This function creates the Sobel filter of an image (edge emphasizing).
%
%Inputs: 1-Image to be filtered
%        2-Size of Sobel filter (integer)
%
%Outputs: Sobel filtered image
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    %% GLACIER IMAGE VELOCIMETRY (GIV) %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Code written by Max Van Wyk de Vries @ University of Minnesota
% %Credit to Ben Popken and Andrew Wickert for portions of the toolbox.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Portions of this toolbox are based on a number of codes written by
% %previous authors, including matPIV, IMGRAFT, PIVLAB, M_Map and more.
% %Credit and thanks are due to the authors of these toolboxes, and for
% %sharing their codes online. See the user manual for a full list of third 
% %party codes used here. Accordingly, you are free to share, edit and
% %add to this GIV code. Please give us credit if you do, and share your code 
% %with the same conditions as this.
% 
% % Read the associated paper here: 
% % doi.org/10.5194/tc-15-2115-2021
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         %Version 1.0, Spring-Summer 2021%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   %Feel free to contact me at vanwy048@umn.edu%


for i=1:Wsize
    Sx(i)=factorial((Wsize-1))/((factorial((Wsize-1)-(i-1)))*(factorial(i-1)));
    Dx(i)=Pasc(i-1,Wsize-2)-Pasc(i-2,Wsize-2);
end

Sy=Sx';
Mx=Sy(:)*Dx;
My=Mx';
Ey=imfilter(double(A),My,'symmetric');
Ex=imfilter(double(A),Mx,'symmetric');
out=sqrt(Ex.^2+Ey.^2);

function P=Pasc(k,n)
    if (k>=0)&&(k<=n)
        P=factorial(n)/(factorial(n-k)*factorial(k));
    else
        P=0;
    end