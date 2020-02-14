function x = gaussFit( Target,Pos )
% This function fits a two-dimensional Gauss function to estimate the
% centroids in a recovered (deconvolved) image.

% Input parameters:
% Target: the recovered image with point-like features
% Pos: Initial guess of the centroid

% Output: Estimated xy coordinates (Actually it returns all the parameters
% of the twoD_Gauss_func "x" with x(2) and x(4) being the coordinates of
% the centroid)

%% ----Area of interest----
MdataSize = 10; % Size of nxn data matrix
Col=round(Pos(1));
Row=round(Pos(2));
if Row-MdataSize/2<1||Row+MdataSize/2>2160||Col-MdataSize/2<1||Col+MdataSize/2>2560
    x=[0 0 0 0 0 0];
    return
end
Z=Target(Row-MdataSize/2:Row+MdataSize/2,Col-MdataSize/2:Col+MdataSize/2);
%% ---------Initial guess---------------------
% parameters are: [Amplitude, x0, sigmax, y0, sigmay, angel(in rad)]
x0 = [max(Z(:)),Pos(1),1,Pos(2),1,0]; %Inital guess parameters
%% ----Set cordinates--------------------------------------

[X,Y] = meshgrid(linspace(Col-MdataSize/2,Col+MdataSize/2,MdataSize+1),linspace(Row-MdataSize/2,Row+MdataSize/2,MdataSize+1));
xdata = zeros(size(X,1),size(Y,2),2);
xdata(:,:,1) = X;
xdata(:,:,2) = Y;


%% --- Fit---------------------
% define lower and upper bounds [Amp,xo,wx,yo,wy,fi]
lb = [0,Col-MdataSize/2,0,Row-MdataSize/2,0,-pi/4];
ub = [max(Z(:)),Col+MdataSize/2,MdataSize/2,Row+MdataSize/2,MdataSize/2,pi/4];%(MdataSize/2)^2
opts = optimset('Display','off');
[x,resnorm,residual,exitflag] = lsqcurvefit(@twoD_Gauss_func,x0,xdata,Z,lb,ub,opts);

%% ---------Plot 3D Image-------------
% [Xhr,Yhr] = meshgrid(linspace(Col-MdataSize/2,Col+MdataSize/2,300),linspace(Row-MdataSize/2,Row+MdataSize/2,300)); % generate high res grid for plot
% xdatahr = zeros(300,300,2);
% xdatahr(:,:,1) = Xhr;
% xdatahr(:,:,2) = Yhr;

% figure(1)
% C = del2(Z);
% mesh(X,Y,Z,C) %plot data
% hold on
% surface(Xhr,Yhr,twoD_Gauss_func(x,xdatahr),'EdgeColor','none') %plot fit
% hold off
%% End

end

