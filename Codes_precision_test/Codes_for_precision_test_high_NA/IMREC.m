function Rec=IMREC(image,psf)
% This function deconvolves the recorded image with the PSF using a Wiener
% filter.
Fimage=fftshift(fft2(image));% Fourier transform of the image
Fpsf=fftshift(fft2(psf));% Fourier transform of the PSF
FRec=Fimage.*conj(Fpsf)./(Fpsf.*conj(Fpsf)+0.005);%0.005 for precision analysis 0.0001 for calibration
Rec=abs(ifftshift(ifft2(FRec)));% inverse Fourier transform
end