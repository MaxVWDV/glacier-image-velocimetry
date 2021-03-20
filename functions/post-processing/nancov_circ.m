% NANCOV.M
% Program to compute a covariance matrix ignoring NaNs
%
% Usage: C = nancov(A,B)
%
% NANCOV calculates the matrix product A*B ignoring NaNs by replacing them
% with zeros, and then normalizing each element C(i,j) by the number of 
% non-NaN values in the vector product A(i,:)*B(:,j).
%
% A - left hand matrix to be multiplied
% B - right hand matrix to be multiplied
% C - resultant covariance matrix
% Example: A = [1 NaN 1] , B = [1
%                               1
%                               1]
% then nancov(A,B) is 2/2 = 1
%
%
%Based on code by:
%http://pordlabs.ucsd.edu/matlab/nan.htm ;
%
%Modified by M. Van Wyk de Vries for GIV toolbox.
%

function [save_stats]=nancov_circ(A,B,dim)

if dim == 2
    save_stats = NaN(size(A,1),1);
    axis = size(A,1);
elseif dim == 1
    save_stats = NaN(1,size(A,2));
    axis = size(A,2);
else
        disp('Maximum 2 dimensions allowed.')
end

for loop = 1:axis
    
    %Crop out one column
    if dim == 2
        A1 = A(loop,:);
        B1 = B(loop,:);
    elseif dim == 1
        A1 = A(:,loop);
        B1 = B(:,loop);
    end
    
    %Check if all NaN, do not do calculations if so to save time
    if any(~isnan(A1))&&any(~isnan(B1))
        NmatA=~isnan(A1); % Counter matrix
        NmatB=~isnan(B1);

        A1(isnan(A1))=0; % Replace NaNs in A,B, and counter matrices
        B1(isnan(B1))=0; % with zeros
        
        if dim == 2
        Npts=NmatA*NmatB';
        C=(A1*B1')./Npts;
        elseif dim == 1
        Npts=NmatA'*NmatB;   
        C=(A1'*B1)./Npts; 
        end
        
    else
        C = NaN;
    end
    
    if dim == 2
        save_stats(loop,1) = C;
    elseif dim == 1
        save_stats(1,loop) = C;
    end
    
end
