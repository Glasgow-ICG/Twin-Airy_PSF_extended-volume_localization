function y = twoD_Gauss_func(params,xdata)
% two-dimensional Gauss function for image centroiding

% input paramters:
% params: parameters [amplitude, x0, sigmax, y0, sigmay, angle]
% xdata: xy meshgrid

%output: 2D array of Gauss function

xdatarot(:,:,1)= xdata(:,:,1)*cos(params(6)) - xdata(:,:,2)*sin(params(6));
xdatarot(:,:,2)= xdata(:,:,1)*sin(params(6)) + xdata(:,:,2)*cos(params(6));
x0rot = params(2)*cos(params(6)) - params(4)*sin(params(6));
y0rot = params(2)*sin(params(6)) + params(4)*cos(params(6));

y = params(1)*exp( -((xdatarot(:,:,1)-x0rot).^2/(2*params(3)^2) + (xdatarot(:,:,2)-y0rot).^2/(2*params(5)^2) ) );
