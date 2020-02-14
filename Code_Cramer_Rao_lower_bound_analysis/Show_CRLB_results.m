% This script loads, and plots the results from 
% Calculate_Cramer_Rao_lower_bound.m script
clear all;
%% ----load and display pre-saved results for Fig. 2---
load('CRLB_SA4'); % CRLBs for single Airy PSF with alpha = 4 
load('CRLB_TA2'); % CRLBs for twin-Airy PSF with alpha = 2
load('CRLB_TA4'); % CRLBs for twin-Airy PSF with alpha = 4
load('CRLB_TA6'); % CRLBs for twin-Airy PSF with alpha = 6

% show the calculated CRLBs in x, y or z
close all;
kk=4; % kk=1,2,3,4 corresponds to z, CRLBx, CRLBy and CRLBz respectively
figure;hold on
plot(CRLB_TA2(:,1),CRLB_TA2(:,kk).*1000,'r','LineWidth',2);
plot(CRLB_TA4(:,1),CRLB_TA4(:,kk).*1000,'color',[1,165/255,0],'LineWidth',2);
plot(CRLB_TA6(:,1),CRLB_TA6(:,kk).*1000,'g','LineWidth',2);
plot(CRLB_SA4(:,1),CRLB_SA4(:,kk).*1000,'b','LineWidth',2);
hold off
xlabel(['z / ',char(181), 'm']);
ylabel('CRLBz / nm');
ylim([0 100]);
set(gca,'fontsize',12);
%legend('x','y','z')
legend('TA \alpha = 2','TA \alpha = 4','TA \alpha = 6','SA \alpha = 4');
grid on
set(gcf,'color','w');

