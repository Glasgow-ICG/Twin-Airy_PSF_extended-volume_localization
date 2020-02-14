% This script performs the calibration of xyz using the pre-recorded PSF
% stack. It generates the calibration file "CALIB.mat" which will be used
% for following data analysis.
% -------------------------------------

clear all; close all;
% --load the in-focus image--
% the PSF stack contains 181 images recorded with 1um step in z direction,
% psf (91).tif corresponds to the in-focus plane.
PSF=im2double(imread(fullfile('..', 'Raw_data_PSF_stack','psf (91).tif')));
Size=size(PSF);
figure;imshow(PSF,[]);title('example of raw PSF image');
% --remove background--
bkgrd=mean(mean(PSF(end/2-100:end/2+100,end/2:end/2+200)));
PSF=PSF-ones(Size(1),Size(2)).*bkgrd;
% --get infocus PSFs as deconvolution kernel, i.e. PSFP(upper) and PSFN(lower)--
% setting parameters: P_row and P_col are the coordinates of the brightest
% pixel in the TA-PSF upper half; N_row and N_col are the coordinates of the brightest
% pixel in the TA-PSF lower half; psfSize is the cropped size of the PSF halves 
P_row=924;P_col=848;N_row=1091;N_col=848;psfSize=100;
% putting the main lobe in the middle of the image
PSFP=zeros(Size(1),Size(2));PSFN=PSFP;
PSFP(floor(Size(1)/2)-psfSize:floor(Size(1)/2)+psfSize,floor(Size(2)/2)-psfSize:floor(Size(2)/2)+psfSize)=PSF(P_row-psfSize:P_row+psfSize,P_col-psfSize:P_col+psfSize);
PSFN(floor(Size(1)/2)-psfSize:floor(Size(1)/2)+psfSize,floor(Size(2)/2)-psfSize:floor(Size(2)/2)+psfSize)=PSF(N_row-psfSize:N_row+psfSize,N_col-psfSize:N_col+psfSize);
%imshow(PSFP,[])

% normalize intensity
PSFP=PSFP./sum(PSFP(:));
PSFN=PSFN./sum(PSFN(:));

% --loop to get the recoverd PSFs: RECP and RECN at different depths--
RECPS=zeros(2048,2048);RECNS=RECPS;RECPpara=[];RECNpara=[];
for z=1:181 %the PSF stack contains 181 images
    % -- load image recorded at z-th axial position--
    img1=im2double(imread(fullfile('..','Raw_data_PSF_stack',strcat('psf (',num2str(z),')','.tif'))));
    img1=img1-ones(Size(1),Size(2)).*bkgrd;
    % -- deconvolve with in-focus PSF--
    RECP=IMREC(img1,PSFP);
    RECN=IMREC(img1,PSFN);
    % -- discard the unsuccessfully recovered PSF halves--
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
    [I_row, I_col] = ind2sub(size(RECP),I);
    RECPpara=[RECPpara;gaussFit(RECP,[I_col,I_row])];
    [M,I]=max(RECN(:));
    [I_row, I_col] = ind2sub(size(RECN),I);
    RECNpara=[RECNpara;gaussFit(RECN,[I_col,I_row])];
    % --keep the deconvolved PSFs for display--
    RECPS=RECPS+RECP;
    RECPS(floor((P_row+N_row)/2):end,:)=0;
    RECNS=RECNS+RECN;
    RECNS(1:floor((P_row+N_row)/2),:)=0;
    disp(['depths: ',num2str(z),' / 181.'])
end
RECPS=RECPS./181;
RECNS=RECNS./181;
% --display the sum of the recovered PSFs over the depth range--
figure;imshowpair(RECPS,RECNS);title({'recovered PSFs for different depths superimposed'});
% --generate and save the calibration file--
CALIB=[RECNpara(:,4)-RECPpara(:,4) ((-90:1:90).*0.5)' (RECNpara(:,2)+RECPpara(:,2))./2-(RECNpara(91,2)+RECPpara(91,2))./2];
save('CALIB.mat','CALIB');
