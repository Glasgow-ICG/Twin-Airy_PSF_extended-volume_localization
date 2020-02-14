% This script performs the calibration of xyz using the pre-recorded PSF
% stack. It generates the calibration file "CALIB.mat" which will be used
% for following data analysis.
% -------------------------------------

clear all; close all;
% --load the in-focus image--
% the PSF stack contains 11 images recorded with 1um step in z direction,
% "psf5_X1.tif" corresponds to the in-focus plane.
PSF=double(imread('../Raw_data_PSF_stack/psf5_X1.tif'));PSF=imrotate(PSF,-90);
backgrd=PSF(1:10,1:10);%backgrd=imcrop(PSF,[]);
Size=size(PSF);
PSF=PSF-ones(Size(1),Size(2)).*mean(backgrd(:));
%imshow(PSF,[]);

% --get infocus PSFs as deconvolution kernel, i.e. PSFP(upper) and PSFN(lower)--
% setting parameters: P_row and P_col are the coordinates of the brightest
% pixel in the TA-PSF upper half; N_row and N_col are the coordinates of the brightest
% pixel in the TA-PSF lower half; psfSize is the cropped size of the PSF halves 
P_row=43;P_col=21;N_row=98;N_col=21;psfSize=20; 
% putting the main lobe in the center of the image
PSFP=zeros(Size(1),Size(2));PSFN=PSFP;
PSFP(floor(Size(1)/2)-psfSize:floor(Size(1)/2)+psfSize,floor(Size(2)/2)-psfSize:floor(Size(2)/2)+psfSize)=PSF(P_row-psfSize:P_row+psfSize,P_col-psfSize:P_col+psfSize);
PSFN(floor(Size(1)/2)-psfSize:floor(Size(1)/2)+psfSize,floor(Size(2)/2)-psfSize:floor(Size(2)/2)+psfSize)=PSF(N_row-psfSize:N_row+psfSize,N_col-psfSize:N_col+psfSize);
%imshow(PSFP,[]);

PSFP=PSFP./sum(PSFP(:));% normalize the PSF intensity
PSFN=PSFN./sum(PSFN(:));

%imshow(PSF,[]);
% --loop to get the recoverd PSFs: RECP and RECN at different depths--
RECPS=zeros(138,84);RECNS=RECPS;RECPpara=[];RECNpara=[];
for z=1:11
    % --load image recorded at z-th axial position--
    img1=double(imread(['..\Raw_data_PSF_stack/psf',num2str(z),'_X1.tif']));img1=imrotate(img1,-90);
    img1=img1-ones(Size(1),Size(2)).*mean(backgrd(:));
    % -- deconvolve with the in-focus PSFs--
    RECP=IMREC(img1,PSFP);
    RECN=IMREC(img1,PSFN);
    %imshow(RECP,[])
    % --discard the unsuccessfully recovered PSF halves-- 
    temp=zeros(Size(1),Size(2));
    temp(P_row-psfSize:P_row+psfSize,P_col-psfSize:P_col+psfSize)=RECP(P_row-psfSize:P_row+psfSize,P_col-psfSize:P_col+psfSize);
    RECP=temp;
    temp=zeros(Size(1),Size(2));
    temp(N_row-psfSize:N_row+psfSize,N_col-psfSize:N_col+psfSize)=RECN(N_row-psfSize:N_row+psfSize,N_col-psfSize:N_col+psfSize);
    RECN=temp;
    clear temp;
    %imshow(RECP,[]);
    % -- find the centroids of deconvolved PSFs--
    [M,I]=max(RECP(:));
    [I_rowp, I_colp] = ind2sub(size(RECP),I);
    RECPpara=[RECPpara;gaussFit(RECP,[I_colp,I_rowp])];
    [M,I]=max(RECN(:));
    [I_row, I_col] = ind2sub(size(RECN),I);
    RECNpara=[RECNpara;gaussFit(RECN,[I_col,I_row])];
    RECPS=RECPS+RECP;
    RECPS(floor((P_row+N_row)/2):end,:)=0;
    RECNS=RECNS+RECN;
    RECNS(1:floor((P_row+N_row)/2),:)=0;
    disp(['depths: ',num2str(z),' / 11.'])
end
RECPS=RECPS./11;
RECNS=RECNS./11;

% --display the sum of the recovered PSFs over the depth range--
figure;imshowpair(RECPS,RECNS);title({'recovered PSFs superimposed', 'for different depths'})

% --generate and save calibration file--
CALIB=[RECNpara(:,4)-RECPpara(:,4) ((-5:1:5).*1)' (RECNpara(:,2)+RECPpara(:,2))./2-(RECNpara(11,2)+RECPpara(11,2))./2];

% --increase sampling rate of the calibration--
p2 = polyfit(CALIB(:,1),CALIB(:,2),2);
x1 = linspace(1,120,120);
x2 = polyval(p2,x1);
p3 = polyfit(CALIB(:,1),CALIB(:,3),2);
x3 = polyval(p3,x1);
clear CALIB
CALIB=[];
CALIB=[x1' x2' x3'];
save('CALIB.mat','CALIB');