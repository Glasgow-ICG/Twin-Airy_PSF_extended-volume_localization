% This script performs the frame-to-frame particle tracking using the
% algorithm developted by Croker et al. (i.e. track.m). The 3D localization
% results from multiframe.m, "LocsList.mat", is need for this script to
% run. It also saves the tracked trajectories as "FlowTraj.mat"

clear all; close all;
load('LocsList');
% --removing invalid data points, i.e. NANs--
for k=1:size(LocsList,1)
    if k>size(LocsList,1)
        break
    end
    if LocsList(k,1)~=LocsList(k,1)
        LocsList=[LocsList(1:k-1,:);LocsList(k+1:end,:)];
    end
end
% --converting x y from pixels to microns--
LocsList(:,1)=LocsList(:,1).*6.5./20;
LocsList(:,2)=LocsList(:,2).*6.5./20;

% --tracking using Crocker et al. IDL particle tracking function: track.m
param=struct('mem',3,'good',10,'dim',3,'quiet',0);
FlowTraj=track(LocsList,20,param);
save('FlowTraj','FlowTraj')

% --plot the localized and tracked tracer trajectories, color codes
% different tracers--
sFlowTraj=size(FlowTraj);
PN=FlowTraj(sFlowTraj(1),sFlowTraj(2));
a=figure; hold on
for i=1:PN
    P=FlowTraj(FlowTraj(:,5)==i,1:3);
    count=size(P);
    count=count(1);
    count=1:1:count;
    plot3(P(count,1),P(count,2),P(count,3),'.','MarkerSize',6);%5 
end
hold off
grid on
set(gcf,'Units','inch')
set(gca,'Position',[0.1 0.1 0.9 0.9])
%axis([0 200 50 250 -40 40])
%title('Particle trajectories in succtesive frames','fontweight','normal','FontSize', 18)
daspect([1 1 1])
xlabel('x / um')
ylabel('y / um')
zlabel('z / um')
view(3)