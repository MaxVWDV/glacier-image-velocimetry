%% Predict a velocity based on ice thickness and slope data and compare to observed v field
%Experimental, needs work. Calculate ice thickness from velocity, or
%portion of velocity accounted for by sliding vs deformation.

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

%% Variables and equation

load ./thickness/slope.mat;
load ./thickness/thickness_carrivick.mat; %Carrivick et al 2016
load ./thickness/thickness_smoothed.mat; %Carrivick et al 2016

% surface velocity U_s - calculated fron iceV
% basal velocity U_b - difference
% creep constant A_c - 3.24e-24 Pa-3 s-1 (Cuffey and Paterson 2010)
A_c = 5*10^(-24);
% Glenn's flow exponent n_G - we take to be 3
n_G = 3;
% basal stress tau_b - calculate
% ratio driving to shear stresses f_r - 0.9  (Haeberli and Hoelzle, 1995)
f_r = 0.9;
% density of ice rho_i - 917 kg/m3
rho_i = 917;
% gravity g - 9.8 m/s2
g = 9.8;
% slope alpha - derivative of rescaled SRTM
alpha = slope;
% alpha = (slp + slope)/2;
% ice thickness H
H = (thickness_smoothed);
%Equation from (Cuffey and Paterson, 2010) and (Gantayat and Srinivasan, 
% 2014)

% U_s = U_b + (2*A_c)/(n_G + 1)*tau_b^n*H
%
% with tau_b = f_r * rho_i * g * H * sin(alpha);

% import mask if not already done

cdata = imread(fullfile(myFolder,'mask.png'));

cdata = double(cdata);

cdata = cdata(:,:,1)+cdata(:,:,2)+cdata(:,:,3);

cdata(cdata==765) = NaN;

cdata(cdata>0)= 0;

cdata(isnan(cdata))= 1;

mask_0_1 = cdata;

mask_0_1 = flipud(mask_0_1);

mask0 = (interp2(mask_0_1, linspace(1,size(mask_0_1,2),size(v_mean,2)).', linspace(1,size(mask_0_1,1),size(v_mean,1))));

% smooth H and alpha to reduce any extreme values


    %for H
    nanX    = isnan(H);
    H(nanX) = 0;
    mask    = [1 1 1 1 1; 1 1 1 1 1; 1 1 0 1 1; 1 1 1 1 1; 1 1 1 1 1];
    means   = conv2(H,     mask, 'same') ./ ...
          conv2(~nanX, mask, 'same');
    H(nanX) = means(nanX);
    
    %for H
        nanX    = isnan(H);
    H(nanX) = nansum(H,'all')/ nnz(~isnan(H));
    mask    = [1 1 1; 1 1 1; 1 1 1];
    H   = conv2(H,     mask, 'same') ./ ...
          conv2(~nanX, mask, 'same');  

      H(mask0 == 0)=NaN;
      
%%%

    %for alpha
    nanX    = isnan(alpha);
    alpha(nanX) = 0;
    mask    = [1 1 1 1 1; 1 1 1 1 1; 1 1 0 1 1; 1 1 1 1 1; 1 1 1 1 1];
    means   = conv2(alpha,     mask, 'same') ./ ...
          conv2(~nanX, mask, 'same');
    alpha(nanX) = means(nanX);
    
    %for alpha
        nanX    = isnan(alpha);
    alpha(nanX) = nansum(alpha,'all')/ nnz(~isnan(alpha));
    mask    = [1 1 1; 1 1 1; 1 1 1];
    alpha   = conv2(alpha,     mask, 'same') ./ ...
          conv2(~nanX, mask, 'same');  

      alpha(mask0 == 0)=NaN;
      
      %alpha in radians
%       alpha(alpha>0) = 3; % all 3
      alpha = deg2rad(alpha);
      
%%%

% Calculate tau_b

tau_b = f_r * rho_i * g * H .* sin(alpha);

% Calculate predicted U_s with no basal flow

U_s =  (2*A_c)/(n_G + 1)*(tau_b.^n_G).*H; %m/s
U_s = U_s * 60*60*24*365; %m/yr
% U_s =  (1.5*H.^4)./(A_c*(f_r * rho_i * g * sin(alpha)).^3);

%compare to v_mean1
percent_basal = U_s;
% percent_basal(percent_basal > v_mean) = v_mean;
percent_basal1 = 1-(percent_basal ./ v_mean1);
percent_basal1(percent_basal1 < 0) = 0;

%%%

    %for percent_basal1
    nanX    = isnan(percent_basal1);
    percent_basal1(nanX) = 0;
    mask    = [1 1 1 1 1; 1 1 1 1 1; 1 1 0 1 1; 1 1 1 1 1; 1 1 1 1 1];
    means   = conv2(percent_basal1,     mask, 'same') ./ ...
          conv2(~nanX, mask, 'same');
    percent_basal1(nanX) = means(nanX);
    
    %for percent_basal1
        nanX    = isnan(percent_basal1);
    percent_basal1(nanX) = nansum(percent_basal1,'all')/ nnz(~isnan(percent_basal1));
    mask    = [1 1 1; 1 1 1; 1 1 1];
    percent_basal1   = conv2(percent_basal1,     mask, 'same') ./ ...
          conv2(~nanX, mask, 'same');  

      percent_basal1(mask0 == 0)=NaN;
      

%%%

%compare to v_mean2
percent_basal = U_s;
% percent_basal(percent_basal > v_mean) = v_mean;
percent_basal2 = 1-(percent_basal ./ v_mean2);
percent_basal2(percent_basal2 < 0) = 0;

%%%

    %for percent_basal2
    nanX    = isnan(percent_basal2);
    percent_basal2(nanX) = 0;
    mask    = [1 1 1 1 1; 1 1 1 1 1; 1 1 0 1 1; 1 1 1 1 1; 1 1 1 1 1];
    means   = conv2(percent_basal2,     mask, 'same') ./ ...
          conv2(~nanX, mask, 'same');
    percent_basal2(nanX) = means(nanX);
    
    %for percent_basal2
        nanX    = isnan(percent_basal2);
    percent_basal2(nanX) = nansum(percent_basal2,'all')/ nnz(~isnan(percent_basal2));
    mask    = [1 1 1; 1 1 1; 1 1 1];
    percent_basal2   = conv2(percent_basal2,     mask, 'same') ./ ...
          conv2(~nanX, mask, 'same');  

      percent_basal2(mask0 == 0)=NaN;
      

%%%

percent_basal_diff = percent_basal1-percent_basal2;

%%%

    %for percent_basal_diff
    nanX    = isnan(percent_basal_diff);
    percent_basal_diff(nanX) = 0;
    mask    = [1 1 1 1 1; 1 1 1 1 1; 1 1 0 1 1; 1 1 1 1 1; 1 1 1 1 1];
    means   = conv2(percent_basal_diff,     mask, 'same') ./ ...
          conv2(~nanX, mask, 'same');
    percent_basal_diff(nanX) = means(nanX);
    
    %for percent_basal_diff
        nanX    = isnan(percent_basal_diff);
    percent_basal_diff(nanX) = nansum(percent_basal_diff,'all')/ nnz(~isnan(percent_basal_diff));
    mask    = [1 1 1; 1 1 1; 1 1 1];
    percent_basal_diff   = conv2(percent_basal_diff,     mask, 'same') ./ ...
          conv2(~nanX, mask, 'same');  

      percent_basal_diff(mask0 == 0)=NaN;
      

%%%
percent_basal_diff(percent_basal_diff == inf) = NaN;
percent_basal_diff(percent_basal_diff == -inf) = NaN;

baslim_min = prctile(percent_basal_diff,0.001,'all');
baslim_max = prctile(percent_basal_diff,99.999,'all');
percent_basal_diff(percent_basal_diff < baslim_min) = NaN;
percent_basal_diff(percent_basal_diff > baslim_max) = NaN;

%how much is above zero
basratio = baslim_max/(baslim_max+abs(baslim_min));




%% plot

%georef
% given points.
latmin = -50.9640;
latmax = -50.8920;
longmin= -73.7460;
longmax = -73.4730;

    figure;
    
    m_proj('lambert','lon',[longmin longmax],'lat',[latmin latmax]); 
        m_image([longmin longmax],[latmin latmax],flipud(images{2,3}));
%     hold on
    m_image([longmin longmax],[latmin latmax],double(percent_basal1));

    m_grid('xtick',5,'ytick',5,'box','fancy','tickdir','in')
    
        title(strcat('Percent ice velocity change ',mindate,' - ',maxdate,' and ',mindate2,' - ',maxdate2),'FontSize',7);

    colormap([ flipud(cbrewer('seq', 'Blues', (1-basratio)*100));cbrewer('seq', 'Reds', basratio*100);]);
    hold off
caxis([baslim_min baslim_max]);
% caxis([0 1]);
% brighten(.1);
colorbar;





% % % figure ;
% % % surf(U_s)

