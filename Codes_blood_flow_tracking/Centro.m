function centroids = Centro(Rec,ratio,sigma_ratio)
% This function finds the centroids in the recovered (deconvolved) images
% using two-dimensional Gaussian fit

% Input parameters:
% Rec: an image with point-like features, i.e. the recovered images
% ratio: threshold for preliminary centroiding, discarding the centroids
% that have lower intensity than ratio*MaxIntensity
% sigma_ratio: sigma1/sigma2 in the 2D Gaussian fit, which defines the
% acceptable flattening/ellipticity

% Output parameters:
% centroids: in the form of 

%% ----thresholding to find preliminary centroids----
mxl=max(Rec(:));
sl=regionprops((Rec>ratio.*mxl),Rec,'WeightedCentroid');
points=cat(1,sl.WeightedCentroid);
% imshow(Rec,[]);hold on
% plot(points(:,1),points(:,2),'r*');
% hold off
%% ----gaussian fit to better estimate the centroids----
Size=size(points);
X=zeros(Size(1),6);%where true centroids be stored
count=1;
for k=1:Size(1)
    temp=gaussFit(Rec,points(k,:));
    temp=gaussFit(Rec,[temp(2),temp(4)]);
    %if the point is near the image edge or if there's too much difference in sigmaX and sigmaY 
    %or if the point is the maximum value in the image, this point should be abandoned
    if (max(temp)==0&&min(temp)==0)||((temp(3)/temp(5))>sigma_ratio)||(temp(3)/temp(5))<(1/sigma_ratio)||temp(3)<1||temp(5)<1||temp(3)>10||temp(5)>10
        continue
    end

    if count==1
    X(count,:)=temp;
    count=count+1;
    else
        used=0;
        % check if this current centroid has been previously estimated
        for i=1:count-1
            if sqrt((temp(2)-X(i,2))^2+(temp(4)-X(i,4))^2)<min(X(i,3),X(i,5))
                used=1;
                break
            end
        end
        if used==1
            continue
        else
            X(count,:)=temp;
            count=count+1;
        end
        
    end

end
centroids=X(1:count-1,:);
%% ----plot----
% figure; imshow(Rec,[]);
% hold on
% plot(centroids(:,2),centroids(:,4),'*');
% hold off 

end