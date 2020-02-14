% This script displays the results of the precision test, including the
% precision as a funciton of depth, two-lobe-disparity as a function of
% depth, PSF lateral shift as a function of depth and the recovered PSFs for
% each depth superimposed. It can run with the save results of the script
% "Precision_depth.m", namely Xs.mat, Ys.mat, Zs.mat, SRP.mat and
% SRN.mat.
% -------------------------------------

load('Xs.mat');load('Ys.mat');load('Zs.mat');

% --calsulate and show the standard deviations of the 1000 measurements for
% each depth, i.e. the precision test result--
figure;hold on
plot(-4:4,std(Xs(:,1:9)),'-s','linewidth',2);
plot(-4:4,std(Ys(:,1:9)),'-s','linewidth',2);
plot(-4:4,std(Zs(:,1:9)),'-s','linewidth',2);
hold off
xlabel('Depth/ \mum')
ylabel('Standard Deviations/ nm')
grid on
set(gca, 'fontsize',16)
xlim([-5 5])
xticks(-5:1:5)
ylim([5 60])
legend('\sigma_{x}','\sigma_{y}','\sigma_{z}')

% --load the saved recovered PSFs to calculate the two-lobe-disparity and PSF
% lateral translation. Display the results against depth.--
load('SRP');load('SRN');
RECPS=zeros(138,84);RECNS=RECPS;RECPpara=[];RECNpara=[];
P_row=43;P_col=21;N_row=98;N_col=21;psfSize=20;Size=[138 84];
figure;
for z=1:11
    % -- find the centroid of deconvolved PSFs 
    temp=zeros(Size(1),Size(2));
    temp(P_row-psfSize-15:P_row+psfSize,P_col-psfSize:P_col+psfSize+10)=SRP(P_row-psfSize-15:P_row+psfSize,P_col-psfSize:P_col+psfSize+10,z);
    RECP=temp;
    temp=zeros(Size(1),Size(2));
    temp(N_row-psfSize:N_row+psfSize+15,N_col-psfSize:N_col+psfSize+10)=SRN(N_row-psfSize:N_row+psfSize+15,N_col-psfSize:N_col+psfSize+10,z);
    RECN=temp;
    clear temp;
    imshow(RECP,[]);
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
    imshowpair(RECP,RECN);hold on
    plot(I_colp,I_rowp,'r*');
    plot(RECPpara(:,2),RECPpara(:,4),'go');
    hold off
    disp(['depth: ',num2str(z),' /11.']);
end
% --plot the averaged recovered PSFs superimposed for all the depths--
imshowpair(sum(SRP,3),sum(SRN,3),'ColorChannels','red-cyan');
title({'Recovered PSFs superimposed','throughout the depth range'})

% --plot the two-lobe disparity and the lateral shift in the PSFs as a
% function of depth--
figure;hold on
yyaxis left
%plot(-4:5,RECNpara(1:10,4)-RECPpara(1:10,4),'-o','linewidth',2);
plot(-4:5,(RECNpara(1:10,4)-RECPpara(1:10,4)),'-o','linewidth',2);%.*13./60
xlabel('Depth / \mum')
ylabel('Two-lobe disparity / pixel')
%ylabel('Two-lobe disparity / \mum')
grid on
set(gca, 'fontsize',16)
xlim([-5 5])
xticks(-5:1:5)
%ylim([5 22.5])
%yticks(5:2.5:25)

yyaxis right
plot(-4:5,(RECNpara(1:10,2)-ones(1,10).*RECNpara(5,2)),'-o','linewidth',2);%.*13./60
ylabel('Shift in x / pixel')
%ylabel('Shift in x / \mum')
%ylim([-2.2 1])
hold off

