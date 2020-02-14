% This script displays the results of the precision test, including the
% precision as a funciton of depth, two-lobe-disparity as a function of
% depth, PSF lateral shift as a funciton of depth and the recovered PSFs for
% each depth superimposed. It can run with the save results of the script
% "Precision_depth.m", namely Xs.mat, Ys.mat, Zs.mat, SRP.mat and
% SRN.mat.
% -------------------------------------

load('Xs.mat');load('Ys.mat');load('Zs.mat');

% --calsulate and show the standard deviations of the 1000 measurements for
% each depth, i.e. the precision test result--
figure;hold on
plot(-60:10:50,std(Xs(:,1:12)),'-s','linewidth',2);
plot(-60:10:50,std(Ys(:,1:12)),'-s','linewidth',2);
plot(-60:10:50,std(Zs(:,1:12)),'-s','linewidth',2);
hold off
xlabel('Depth/ \mum')
ylabel('Standard Deviations/ nm')
grid on
set(gca, 'fontsize',16)
xlim([-60 60])
%xticks(-5:1:5)
ylim([0 80])
legend('\sigma_{x}','\sigma_{y}','\sigma_{z}')

% --load the saved recoved PSFs to calculate the two-lobe-disparity and PSF
% lateral translation. Display the results against depth.--
load('SRP');load('SRN');
RECPS=zeros(424,350);
RECNS=RECPS;
RECPpara=[];RECNpara=[];
P_row=123;P_col=100;N_row=303;N_col=100;psfSize=80;
Size=[424 350];
for z=1:12
    % -- find the centroid of deconvolved PSFs 
    temp=zeros(Size(1),Size(2));
    temp(P_row-psfSize-15:P_row+psfSize,P_col-psfSize:P_col+psfSize+10)=SRP(P_row-psfSize-15:P_row+psfSize,P_col-psfSize:P_col+psfSize+10,z);
    RECP=temp;
    temp=zeros(Size(1),Size(2));
    temp(N_row-psfSize:N_row+psfSize+15,N_col-psfSize:N_col+psfSize+10)=SRN(N_row-psfSize:N_row+psfSize+15,N_col-psfSize:N_col+psfSize+10,z);
    RECN=temp;
    clear temp;
    %imshow(RECP,[]);
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
    z
end

SSRP=sum(SRP,3);
SSRP(SSRP>1.8e4)=1.8e4;
SSRN=sum(SRN,3);
SSRN(SSRN>2e4)=2e4;
imshowpair(SSRP,SSRN,'ColorChannels','red-cyan')
title('Recovered PSFs superimposed throughout the depth range')
figure;hold on
yyaxis left
%plot(-60:10:50,RECNpara(1:12,4)-RECPpara(1:12,4),'-o','linewidth',2);
plot(-60:10:50,(RECNpara(1:12,4)-RECPpara(1:12,4)).*6.5./20,'-o','linewidth',2);
xlabel('Depth / \mum')
%ylabel('Two-lobe disparity / pixel')
ylabel('Two-lobe disparity / \mum')
ylim([10 110])
grid on
set(gca, 'fontsize',16)
%xlim([-5 5])
%xticks(-5:1:5)

yyaxis right
%plot(-60:10:50,RECNpara(1:12,2)-ones(1,12).*RECNpara(7,2),'-o','linewidth',2);
plot(-60:10:50,(RECNpara(1:12,2)-ones(1,12).*RECNpara(7,2)).*6.5./20,'-o','linewidth',2);
ylabel('Shift in x / \mum')
%ylabel('Shift in x / pixel')
hold off

%% show the stack of the raw PSFs
%clear all; close all
load('SPSF');
figure;
h=slice(SPSF(41:end-40,71:end-160,:),[],[],3:1:11); %SRP(41:end-40,71:end-160,:)+SRN(41:end-40,71:end-160,:)
set(h,'edgecolor','none')
axis off
grid off
title('TA-PSF stack')
%rotate(h,[1,0,0],90)
daspect([1 1 0.009])
view([1 -0.3 0.9])%view([1 -1 0.65])
colormap(hot)
