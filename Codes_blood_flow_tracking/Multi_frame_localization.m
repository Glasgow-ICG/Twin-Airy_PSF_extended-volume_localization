% This script performs the 3D localization of each tracer bead frame by
% frame, using CALIB.mat as calibration. It generates and saves the
% localization results in "LocsList.mat" which has four columns: x y z and
% frame number. Note that x and y are in pixels while z is in microns, this
% will be taken into account in the "Flow_tracking.m" script.

clear all;close all;
%% ----get in focus PSFs----
PSF=im2double(imread(fullfile('..', 'Raw_data_PSF_stack','psf (91).tif')));Size=size(PSF);
%imshow(PSF,[])
% ----get rid of background----
bkgrd=mean(mean(PSF(end/2-100:end/2+100,end/2:end/2+200)));
PSF=PSF-ones(Size(1),Size(2)).*bkgrd;
% ----get infocus PSFs----
P_row=924;P_col=848;N_row=1091;N_col=848;psfSize=100;imgSize_row=924;imgSize_col=1140;
PSFP=zeros(imgSize_row,imgSize_col);PSFN=PSFP;
PSFP(floor(imgSize_row/2)-psfSize:floor(imgSize_row/2)+psfSize,floor(imgSize_col/2)-psfSize:floor(imgSize_col/2)+psfSize)...
    =PSF(P_row-psfSize:P_row+psfSize,P_col-psfSize:P_col+psfSize);
PSFN(floor(imgSize_row/2)-psfSize:floor(imgSize_row/2)+psfSize,floor(imgSize_col/2)-psfSize:floor(imgSize_col/2)+psfSize)...
    =PSF(N_row-psfSize:N_row+psfSize,N_col-psfSize:N_col+psfSize);
PSFP=PSFP./sum(PSFP(:));
PSFN=PSFN./sum(PSFN(:));
%imshow(PSFP,[])
%% ----load calibration data before localizaion frame by frame----
load('CALIB.mat');
LocsList=[];
for t=11:5000
     %% ----load a frame, get rid of background----
    img=im2double(imread(fullfile('..','Raw_data_blood_flow',strcat('t',num2str(t),'.tif'))));
    bg=im2double(imread(fullfile('..','Raw_data_blood_flow',strcat('t',num2str(t-10),'.tif'))));
    img=img-bg;
    img(img<0)=0;
    %imshow(img,[])
    
    %% ----recover with Positive and Negative kernal----
    RECP=IMREC(img,PSFP);
    RECN=IMREC(img,PSFN);
    %figure;imshow(RECP,[])
    %% ----find centroids in both recoverd images----
    centsp=Centro(RECP,0.3,3);
    centsn=Centro(RECN,0.3,3);
%     imshow(RECN,[]);hold on
%     plot(centsn(:,2),centsn(:,4),'r*');
%     hold off
    %% ----match centroids between recp and recn----
    [matchedP, matchedN]=MatchCentroids(centsp,centsn);
    %figure;imshowpair(RECP,RECN);hold on
    %plot(matchedP(:,2),matchedP(:,4),'r*');
    %plot(matchedN(:,2),matchedN(:,4),'g*');
    %hold off
    %% ----localized by interpolation of the calibration----
    deltaY=matchedN(:,4)-matchedP(:,4);
    CoorZ=interp1(CALIB(:,1),CALIB(:,2),deltaY);
    CoorX=(matchedP(:,2)+matchedN(:,2))./2+interp1(CALIB(:,1),CALIB(:,3),deltaY);
    CoorY=(matchedP(:,4)+matchedN(:,4))./2;
    Locstemp=[CoorX CoorY CoorZ];
    %imshowpair(RECP,RECN);hold on
    %plot(CoorX,CoorY,'r*');
    %hold off
    %% ----add this frame to the locations List----
    LocsList=[LocsList;[Locstemp ones(size(matchedP,1),1).*t]];
    t        
end
save('LocsList.mat','LocsList');
   
