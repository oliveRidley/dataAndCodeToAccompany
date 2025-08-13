addpath ../..
% using colormap viridis from-
%Stephen23 (2025). MatPlotLib Perceptually Uniform Colormaps 
%(https://www.mathworks.com/matlabcentral/fileexchange/62729-matplotlib-perceptually-uniform-colormaps)
%MATLAB Central File Exchange. Retrieved August 11, 2025. 
definePathsAndFiles
figure('pos',[400    800   850   600],'defaultaxesfontsize',16)
load('../../matchingAndFit/sedTrap/mergedFits.mat', 'bw','d','mdlAll')

load(whereUVP.NA,'psd','t','binInfo','r2ec','z');
 psdBinCenter=binInfo.bin_centers_diam;
psd(:,[1 2],:)=[];  % toss bands to have set in common set NP/NA

inEddy=find(r2ec<=15);
psd=psd(:,:,inEddy);
t=t(inEddy);
pocFlux= calcPOCflux(mdlAll,d,bw,psd);


axes('pos',[.1 .125 .6, .8])
cmap=viridis(256);
colormap(cmap);
lineColors=interp1(linspace(t(1), t(end),256),cmap,t);
caxis([t(1),t(end)])



semilogx(pocFlux(:,1),z,'color',lineColors(1,:))


for j=2:length(t)
line(pocFlux(:,j),z,'color',lineColors(j,:))
end
cb=colorbar;
caxis([t(1),t(end)]-datenum(2021,5,0))
set(cb.Label,'String', 'time (day in May 2021)')
set(gca,'Xtick',[1 10 100 1000],'ylim',[0 500],...
    'XTickLabel',{'1','10','100','1000'})
ylabel('depth (m)')
xlabel('UVP-POC flux (mg C m^{-2} d^{-1})')
set(gca,'ydir','rev')
set(gca,'YTick',0:100:500);

axes('pos',[ 0.700    0.1250    0.1500    0.8000]);
a=quiver(.5 ,1.05,0, .7);
set(a,'LineWidth',1.1,'autoscale','off','MaxHeadSize',.15,'color', ...
      'k')
text(.5,1,'early cruise','horizontalAlign','center','fontweight','demi','fontsize',16)
text(.5,1.8,'late cruise','horizontalAlign','center','fontweight','demi','fontsize',16)
set(gca,'visible','off','dataaspectratio',[1 1 1])
