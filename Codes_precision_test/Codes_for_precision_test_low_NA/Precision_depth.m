% This script performs the precision test, i.e. the localization of 100
% frames throughout the whole depth range and estimate the standard
% deviation in the estimated x, y and z coordinates. The list of locations
% and the result of deconvolved images will be saved after running this
% script.
% -------------------------------------

clear all; close all;
% --load the in-focus image, in this image stack "psf 7.tif" was recored at
% the nominal in-focus position--
PSF=double(imread('..\Raw_data_PSF_stack\psf 7.tif'));PSF=PSF(28:end-27,1:end-60);
backgrd=PSF(1:10,1:10);%backgrd=imcrop(PSF,[]);
Size=size(PSF);
PSF=PSF-ones(Size(1),Size(2)).*mean(backgrd(:));
%imshow(PSF,[])

% --get infocus PSFs, place the main lobe in the center of the image--
% setting parameters: P_row and P_col are the coordinates of the brightest
% pixel in the TA-PSF upper half; N_row and N_col are the coordinates of the brightest
% pixel in the TA-PSF lower half; psfSize is the cropped size of the PSF halves 
P_row=123;P_col=100;N_row=303;N_col=100;psfSize=80;% these should be the same as in calib.m
PSFP=zeros(Size(1),Size(2));PSFN=PSFP;
PSFP(floor(Size(1)/2)-psfSize:floor(Size(1)/2)+psfSize,floor(Size(2)/2)-psfSize:floor(Size(2)/2)+psfSize)=PSF(P_row-psfSize:P_row+psfSize,P_col-psfSize:P_col+psfSize);
PSFN(floor(Size(1)/2)-psfSize:floor(Size(1)/2)+psfSize,floor(Size(2)/2)-psfSize:floor(Size(2)/2)+psfSize)=PSF(N_row-psfSize:N_row+psfSize,N_col-psfSize:N_col+psfSize);
%imshow(PSFP,[])

PSFP=PSFP./sum(PSFP(:));% normalize the PSF intensity
PSFN=PSFN./sum(PSFN(:));


locPXs=[];locPYs=[];locNXs=[];locNYs=[];SRP=[];SRN=[];SPSF=[];
for zz=1:12 %the PSF stack contains 12 images
% --loop to get the recoverd PSFs: RECP and RECN at different depths--
RECPS=zeros(424,350);RECNS=RECPS;PSFS=RECPS;RECPpara=[];RECNpara=[];

% --calculate the background level--
image=zeros(424,350);
for i=1:100
    img=double(imread(['..\Raw_data_precision_test\',num2str(zz),'\zt (',num2str(i),').tif']));
    image=image+img;
    i
end
image=image./100;
imageBG=image(1:10,1:10);%imageBG=imcrop(image,[]);
image=image-ones(Size(1),Size(2)).*mean(imageBG(:));
%imshow(image,[])

% --frame-by-frame estimation of the centroids in the recovered images--
for t=1:100
    % -- load a another image--
    img2=double(imread(['..\Raw_data_precision_test\',num2str(zz),'\zt (',num2str(t),').tif']));
    IMGBF=img2-ones(Size(1),Size(2)).*mean(imageBG(:));
    IMGBF(IMGBF<0)=0;
    %mesh(IMGBF)
    PSFS=PSFS+IMGBF;
    IMGBF=int16(IMGBF);
    % -- deconvolve with PSF--
    RECP=IMREC(IMGBF,PSFP);
    RECN=IMREC(IMGBF,PSFN);
    
   
    % -- find the centroid of deconvolved PSFs --
    P_row=123;P_col=100;N_row=303;N_col=100;psfSize=80;
    temp=zeros(Size(1),Size(2));
    temp(P_row-psfSize-15:P_row+psfSize,P_col-psfSize:P_col+psfSize+10)=RECP(P_row-psfSize-15:P_row+psfSize,P_col-psfSize:P_col+psfSize+10);
    RECP=temp;
    temp=zeros(Size(1),Size(2));
    temp(N_row-psfSize:N_row+psfSize+15,N_col-psfSize:N_col+psfSize+10)=RECN(N_row-psfSize:N_row+psfSize+15,N_col-psfSize:N_col+psfSize+10);
    RECN=temp;
    clear temp;
    RECP=RECP-ones(424,350).*10;
    RECP(RECP<0)=0;
    RECN=RECN-ones(424,350).*10;
    RECN(RECN<0)=0;
    [M,I]=max(RECP(:));
    [I_row, I_col] = ind2sub(size(RECP),I);
    RECPpara=[RECPpara;gaussFit(RECP,[I_col,I_row])];
    [M,I]=max(RECN(:));
    [I_row, I_col] = ind2sub(size(RECN),I);
    RECNpara=[RECNpara;gaussFit(RECN,[I_col,I_row])];
    
    
    RECPS=RECPS+RECP;
    RECNS=RECNS+RECN;
    t
end
% --average the 100 frames of recovered PSFs for a certain z--
RECPS=RECPS./100;
RECNS=RECNS./100;
PSFS=PSFS./100;
SRP=cat(3,SRP,RECPS);
SRN=cat(3,SRN,RECNS);
SPSF=cat(3,SPSF,PSFS);
figure;imshowpair(RECPS,RECNS);
locPXs=[locPXs RECPpara(:,2)];
locPYs=[locPYs RECPpara(:,4)];
locNXs=[locNXs RECNpara(:,2)];
locNYs=[locNYs RECNpara(:,4)];
display('zz')
zz
end
% --save the recovered upper-lobe images in 'SRP', lower-lobe images in
% 'SRN'--
save('SRN','SRN');save('SRP','SRP');save('SPSF','SPSF');

% --use the calibation data to localize in 3D--
load('CALIB');
Ys=(locNYs+locPYs)./2.*6500/20;
Xs=(locNXs+locPXs)./2;
DeltaYs=(locNYs-locPYs);
Zs=zeros(100,11);
for i=1:100
    for j=1:12
Zs(i,j)=interp1(CALIB(:,1),CALIB(:,2),DeltaYs(i,j));
Xs(i,j)=interp1(CALIB(:,1),CALIB(:,3),DeltaYs(i,j))+Xs(i,j);
    end
    i
    j
end
% --convert the xz units to microns--
Xs=Xs.*6500/20;
Zs=Zs.*1000;

% --save the localization results to Xs.mat, Ys.mat and Zs.mat--
save('Xs.mat','Xs');save('Ys.mat','Ys');save('Zs.mat','Zs');

% for zz=1:11
%     ppx=polyfit((1:1000)',Xs(:,zz),1);
%     shiftspx=polyval(ppx,(1:1000)');
%     Xs(:,zz)=Xs(:,zz)-shiftspx;
%     
%     ppy=polyfit((1:1000)',Ys(:,zz),1);
%     shiftspy=polyval(ppy,(1:1000)');
%     Ys(:,zz)=Ys(:,zz)-shiftspy;  
%     
%     ppz=polyfit((1:1000)',Zs(:,zz),1);
%     shiftspz=polyval(ppz,(1:1000)');
%     Zs(:,zz)=Zs(:,zz)-shiftspz;    
% 
%     zz
% end

