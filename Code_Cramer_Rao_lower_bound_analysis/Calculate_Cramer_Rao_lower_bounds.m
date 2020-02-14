% This script performs the Cramer-Rao lower bound simulations for the
% comparison of twin-Airy PSF, single Airy PSF and diffraction-limited PSF

clear all;
%% Setup the simulation parameters %%
wavelength = 0.665;  % assumed wave length in microns
NA         = 1.4;   % numerical aperture of the objective
M          = 60;    % magnification of the objective
pixelSize  = 13./M;  % effective pixel size (assumed pixel size here is 13 microns)
numPixels  = 512;    % number of pixels in the camera
numPhoton  = 3500;   % number of photons
bgPhoton   = 50;      % background photons per pixel  
n          = 1.515;   % refractive index
%% Create the image plane coordinates
x = linspace(-pixelSize*(numPixels/2-0.5), pixelSize*(numPixels/2-0.5), numPixels); % microns

%% Create the Fourier plane
dx = x(2) - x(1);    % Sampling period, microns
fS = 1 / dx;         % Spatial sampling frequency, inverse microns
df = fS / numPixels; % Spacing between discrete frequency coordinates, inverse microns
%fx = -fS / 2 : df : fS / 2; % Spatial frequency, inverse microns
% pupil plane coordinates
[fx, fy]        = meshgrid(linspace(-df*(numPixels/2-0.5), df*(numPixels/2-0.5), numPixels),...
    linspace(-df*(numPixels/2-0.5), df*(numPixels/2-0.5), numPixels)); 
% pupil plane polar coordinates
[ftheta, fp]    = cart2pol(fx,fy);

%% Create the pupil, which is defined by the numerical aperture
fNA             = NA / wavelength; % radius of the pupil, inverse microns
%pupilRadius     = fNA / df;        % radius of the pupil, pixels
pupilAperture   = fp <= fNA; %Circular aperture

%% Calculate the PSFs at different z
alpha       = 4;%     % cubic abberation in waves
zRange      = 6;      % z range in micron
zInterv     = 0.1;   % z interval in micron

% single Airy phase mask term
SAMask=exp(1i.*2.*pi.*alpha.*((fx./fNA).^3+(fy./fNA).^3));

% twin Airy phase mask term
TAMask=exp(-1i.*2.*pi.*alpha.*(cos(pi.*fx./fNA)+0.5.*sin(pi.*fy./fNA)));


%% Choose the Phase mask
PhaseMask=TAMask; % or SAMask

%% ----
PSFs=[];              % PSFs at differnt z
PSFs_xplus=[];xplus=0.01.*pixelSize; %in microns
PSFs_yplus=[];yplus=0.01.*pixelSize; %in microns
PSFs_zplus=[];zplus=0.00001; %in microns
for z=-zRange:zInterv:zRange
DefocusPhase=exp(1i.*2.*pi.*z.*sqrt((n./wavelength).^2-fx.^2-fy.^2)); 
pupilFunc=pupilAperture.*DefocusPhase.*PhaseMask; %pupil function
psf_a = fftshift(fft2(pupilFunc)); %amplitude PSF
image = abs(psf_a).^2;image=image./sum(image(:)).*numPhoton; % PSF normalized and mutiplyed by number of photons
PSFs=cat(3,PSFs,image); % PSFs at different z 

% calculate a shifted psf along x
pupilFunc_xplus=pupilAperture.*DefocusPhase.*PhaseMask.*exp(1i.*2.*pi.*fx.*xplus); %shift the psf by xplus microns
psf_a_xplus = fftshift(fft2(pupilFunc_xplus)); %amplitude PSF
image_xplus = abs(psf_a_xplus).^2;image_xplus=image_xplus./sum(image_xplus(:)).*numPhoton; % PSF normalized and mutiplyed by number of photons
PSFs_xplus=cat(3,PSFs_xplus,image_xplus); % PSFs at different z 

% calculate a shifted psf along y
pupilFunc_yplus=pupilAperture.*DefocusPhase.*PhaseMask.*exp(1i.*2.*pi.*fy.*yplus); %shift the psf by xplus microns
psf_a_yplus = fftshift(fft2(pupilFunc_yplus)); %amplitude PSF
image_yplus = abs(psf_a_yplus).^2;image_yplus=image_yplus./sum(image_yplus(:)).*numPhoton; % PSF normalized and mutiplyed by number of photons
PSFs_yplus=cat(3,PSFs_yplus,image_yplus); % PSFs at different z 

% calculate a shifted psf along z
DefocusPhase_zplus=exp(1i.*2.*pi.*(z+zplus).*sqrt((n./wavelength).^2-fx.^2-fy.^2)); 
pupilFunc_zplus=pupilAperture.*DefocusPhase_zplus.*PhaseMask; %pupil function
psf_a_zplus = fftshift(fft2(pupilFunc_zplus)); %amplitude PSF
image_zplus = abs(psf_a_zplus).^2;image_zplus=image_zplus./sum(image_zplus(:)).*numPhoton; % PSF normalized and mutiplyed by number of photons
PSFs_zplus=cat(3,PSFs_zplus,image_zplus); % PSFs at different z 

z
end

%% Partial derivative matrix for x, y, z
PPSFPx=(PSFs_xplus-PSFs)./xplus;
PPSFPy=(PSFs_yplus-PSFs)./yplus;
PPSFPz=(PSFs_zplus-PSFs)./zplus;
%% Cramer-Rao LB for x,y and z at differnt z
Corex=PPSFPx.^2./(PSFs+bgPhoton);CRLBx=1./sqrt(sum(sum(Corex,2),1));
Corey=PPSFPy.^2./(PSFs+bgPhoton);CRLBy=1./sqrt(sum(sum(Corey,2),1));
Corez=PPSFPz.^2./(PSFs+bgPhoton);CRLBz=1./sqrt(sum(sum(Corez,2),1));
%% plot the x y z Cramer-Rao LBs
figure;
p=plot(-zRange:zInterv:zRange,squeeze(CRLBx).*1000,'-',...
    -zRange:zInterv:zRange,squeeze(CRLBy).*1000,'--',-zRange:zInterv:zRange,squeeze(CRLBz).*1000,'-');
ylim([0,100])
p(1).LineWidth=2;
p(1).Color='r';
p(2).Color='g';
p(2).LineWidth=2;
p(3).LineWidth=2;
p(3).Color='b';
xlabel(['z / ',char(181),'m'])
ylabel('CRLBs / nm')
set(gca,'fontsize',14)
%xticks(-zRange:2:zRange)
%yticks(0:20:80)
xlim([-zRange zRange])
title(['CRLBs for TA-PSF with alpha = ',num2str(alpha)])
grid on

% save the calculated CRLBs: the example below "CRLB_TA2" indicates its for
% twin-Airy PSF with alpha = 2
CRLB_TA4=[(-zRange:zInterv:zRange)',squeeze(CRLBx),squeeze(CRLBy),squeeze(CRLBz)];
save('CRLB_TA4','CRLB_TA4');
