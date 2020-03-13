function [ matchedP,matchedN ] = MatchCentroids( centrP,centrN )

% This function matches the centroids in the recovered upper lobes of the
% twin-Airy PSFs to the recovered lower lobes.

% Input parameters:
% centrP: array of centroids (xy coordinates) in the upper lobes
% centrN: array of centroids in the lower lobes

% Output: lists of matched centroids in upper lobes and the lower lobes 

% --check the number of centroids in both kernels--
SL=size(centrP); 
SR=size(centrN);
Pos_img=zeros(min(SL(1),SR(1)),6);
Neg_img=Pos_img;
count=1;
for i=1:SL(1) %loop within centroids P
    deltaX_uplmt=2.5; %maximum allowed misalignment of upper and lower lobes (for a perfectly aligned system, this is 0)
    deltaY_uplmt=270; %upper limit of the two-lobe disparity (refer to calibration)
    deltaY_lwlmt=87; %lower limit of the two-lobe disparity (refer to calibration)
    mid_point=(deltaY_uplmt+deltaY_lwlmt)./2;
    for j=1:SR(1) %loop within centroids N
        deltaX=abs(centrP(i,2)-centrN(j,2));
        deltaY=centrN(j,4)-centrP(i,4);
        temp=(deltaY_uplmt-deltaY_lwlmt)/2;
        % skip if it fails to meet the matching criteria
        
        %check two-lobe seperation, intensity difference, ellipticity difference and lateral allignment
        if deltaX>deltaX_uplmt||deltaY>deltaY_uplmt||deltaY<deltaY_lwlmt||abs(centrP(i,1)-centrN(j,1))/max(centrP(i,1),centrN(j,1))>0.5||... %0.28 %0.5 %0.8 %1
                abs(centrP(i,3)-centrN(j,3))/max(centrP(i,3),centrN(j,3))>0.25||abs(centrP(i,5)-centrN(j,5))/max(centrP(i,5),centrN(j,5))>0.25 %0.5 %1 
            continue
        end
        if abs(deltaY-mid_point)<temp&&temp==(deltaY_uplmt-deltaY_lwlmt)/2 %this could be the matched point if there is no point more closer
            Pos_img(count,:)=centrP(i,:);
            Neg_img(count,:)=centrN(j,:);
            temp=abs(deltaY-mid_point);
            count=count+1;
        elseif abs(deltaY-mid_point)<temp&&temp<40 %the closer, the better
            Pos_img(count,:)=centrP(i,:);
            Neg_img(count,:)=centrN(j,:);
            temp=abs(deltaY-mid_point);
        end         
    end
end

% --matched centroids in the upper lobe and the lower lobe--
matchedP=Pos_img(1:count-1,:);
matchedN=Neg_img(1:count-1,:);
