% NP with 8 panels
%top panels sedtrap
%bottom panels 234Th
% column 1 global fit
% columns 2-4 regional fits, columns 2-4 are the Epochs 1-3
% 
% sedTraps 1 global 2 E1  3 E2 4 E3
% 234Th    5 global 6 E1  7 E2 8 E3

% figure 4 is the same set up with NA.

addpath ../..
definePathsAndFiles
%DUMBASS depth bins to do time mean Th profiles
zEdgesNP=[0  41    57    71    87   103   117   136   180   206   234 ...
	 265   292   317   382   539];

load([DATA,'mld/mldInfo.mat'])
pink=[1,.75 .75]; % chg [.6 .6 .6]; to pink
liteGrey=[.8 .8 .8];
grey=[.45 .45 .45];



load(whereUVP.NP,'t','psd','station','isRide','lon','z')
psd(:,1:2,:)=[];
NPuvp.psd=psd; clear psd
NPuvp.inExports=lon<-144; % just one  the first
NPuvp.station=station;
NPuvp.isRide=isRide;
% email 2019-12-03 from DV Re: official epoch times
%Epoch 1 = datenum(2018,8,14,0) to datenum(2018,8,23,9) 
%Epoch 2 = datenum(2018,8,23,9) to datenum(2018,8,31,9)  
%Epoch 3 = datenum(2018,8,31,9) to datenum(2018,9,9,18)  

epochEdges=datenum(...
[2018,8,14,0,0,0;...
2018,8,23,9,0,0;...
2018,8,31,9,0,0;...
2018,9,9,18,0,0]);
NPuvp.epoch=discretize(t,epochEdges);


% want poc calculated from several models
% bot row2  col 1 mdlAll     col 2-4 mdlNP      These are sed Trap
% top row1  col 1 mdlDeepAll col 2-4 mdlDeepNP  these are 234Th

load('../../matchingAndFit/sedTrap/mergedFits.mat','mdlAll','d','bw');
load('../../matchingAndFit/sedTrap/NP/matchAndFits_NP.mat','mdlNP','zTrapNP','pocFlux*NP','epochNP')
load('../../matchingAndFit/Th/fitAll.mat','mdlDeepAll')
load('../../matchingAndFit/Th/NP/fitNP.mat','mdlDeepNP','pocFluxNssTh','zTh','epochTh','ctdTh','pocFluxNssUncTh')

NPuvp.pocGlobalSedTrap=calcPOCflux(mdlAll,d,bw,NPuvp.psd);
NPuvp.pocRegionalSedTrap=calcPOCflux(mdlNP,d,bw,NPuvp.psd);
NPuvp.pocGlobalTh=calcPOCflux(mdlDeepAll,d,bw,NPuvp.psd);
NPuvp.pocRegionalTh=calcPOCflux(mdlDeepNP,d,bw,NPuvp.psd);


% srThCasts is cell of the Ride Cast that match for each epoch
% srThCasts{1} would be the casts that matched in epoch 1
%
% uvpIndInEpochNP are the indices of the uvp used. 
load ../../../code/matchingAndFit/tallys.mat srThCasts uvpIndInEpochNP
	      
%%%%%%%%%%%%
% now get poc data (from Sam and Meg)


%figure('units','norm','pos',[0 0 1 1],'defaultAxesFontSize',16)
figure('pos',[100 740 1200 900],'defaultAxesFontSize',16)
[ha, pos] = tight_subplot(2, 4, [.1 .05], [.075 .05], [.05 .05]); 


% panel 1 sed trap global fit
% station(NPuvp.inExports & NPuvp.isRide & ismember(NPuvp.station,srThCasts{4})
%  matches srThCasts{4})

for i=1:4
indUvpMatchingTh{i}=...
    (NPuvp.inExports & NPuvp.isRide &  ismember(NPuvp.station,srThCasts{i}));
end
% station(indUvpMatchingTh) matches srThCasts{4})

axes(ha(1))
use=find(z>mldNP.cruise);  % shallower than the cruise mean mix layer
plot(NPuvp.pocGlobalSedTrap(use,uvpIndInEpochNP{end}(:,1)),z(use),'color',pink)
set(gca,'ydir','rev','xlim',[0 50],'ylim',[0 505])
line([0 100],repmat(mldNP.cruise,1,2),'color','r','linestyle','--');
line(nanmean(NPuvp.pocGlobalSedTrap(use,uvpIndInEpochNP{end}(:,1)),2),z(use),'color','r','linewidth',2);

hold on
errorbar(pocFluxNP,zTrapNP,pocFluxUncNP,'d','horiz',...
	'color','b','markerfacecolor','b','markersize',4,'clipping','on')
ylabel('depth (m)')
title('NP global with traps')

for i=1:3
axes(ha(i+1))
use=find(z>mldNP.epoch(i));  % shallower than epoch1 mean  mix
                             % layer
plot(NPuvp.pocRegionalSedTrap(use,uvpIndInEpochNP{i}(:,1)),z(use), ...
     'color',pink)
set(gca,'ydir','rev','xlim',[0 50],'ylim',[0 505])
line([0 100],repmat(mldNP.epoch(i),1,2),'color','r','linestyle','--');
line(nanmean(NPuvp.pocRegionalSedTrap(use,uvpIndInEpochNP{i}(:,1)),2),z(use),'color','r','linewidth',2);
hold on
thisEpoch=epochNP==i;
errorbar(pocFluxNP(thisEpoch),zTrapNP(thisEpoch),pocFluxUncNP(thisEpoch),'d','horiz',...
	'color','b','markerfacecolor','b','markersize',4,'clipping','on')
title(sprintf('NP E%1d',i))
end





% lower panel now
% which is the 234Th poc flux
axes(ha(5))
use=find(z>mldNP.cruise);  % shallower than the cruise mean mix layer
plot(NPuvp.pocGlobalTh(use,indUvpMatchingTh{4}),z(use),'color',pink)
set(gca,'ydir','rev','xlim',[0 50],'ylim',[0 505])
line([0 100],repmat(mldNP.cruise,1,2),'color','r','linestyle','--');
line(nanmean(NPuvp.pocGlobalTh(use,indUvpMatchingTh{4}),2),z(use),'color','r','linewidth',2);
title('NP global with ^{234}Th')
ylabel('depth (m)');
hold on
for i=srThCasts{4}'
  thisCast=find(ctdTh==i & zTh>mldNP.cruise); 
%  line(pocFluxNssTh(thisCast),zTh(thisCast),'color',liteGrey)
   errorbar(pocFluxNssTh(thisCast),zTh(thisCast),pocFluxNssUncTh(thisCast),'d','horiz',...
	'color','b','markerfacecolor','b','markersize',4,'clipping','on','linewidth',.5) 
end


% mean of all these
thisCast=(ismember(ctdTh,srThCasts{4}) & zTh>mldNP.cruise);
[meanZ,meanPOC]=binTimeMeanProfile(zTh(thisCast),pocFluxNssTh(thisCast),zEdgesNP,mldNP.cruise);
%line(meanPOC,meanZ,'color','k','linewidth',2)


for iepoch=1:3
  axes(ha(iepoch+5))
use=find(z>mldNP.epoch(iepoch));  % shallower than the cruise mean mix layer
plot(NPuvp.pocRegionalTh(use,indUvpMatchingTh{iepoch}),z(use),'color',pink)
set(gca,'ydir','rev','xlim',[0 50],'ylim',[0 505])
line([0 100],repmat(mldNP.epoch(iepoch),1,2),'color','r','linestyle','--');
line(nanmean(NPuvp.pocRegionalTh(use,indUvpMatchingTh{iepoch}),2),z(use),'color','r','linewidth',2);
title(sprintf('NP E%1d',iepoch))
for i=srThCasts{iepoch}'
  thisCast=find(ctdTh==i & zTh>mldNP.epoch(iepoch)); 
%  line(pocFluxNssTh(thisCast),zTh(thisCast),'color','b')
  hold on
  errorbar(pocFluxNssTh(thisCast),zTh(thisCast),pocFluxNssUncTh(thisCast),'d','horiz',...
	'color','b','markerfacecolor','b','markersize',4,'clipping','on','linewidth',.5)
end


% mean of all these
thisCast=(ismember(ctdTh,srThCasts{iepoch}) & zTh>mldNP.epoch(iepoch));
[meanZ,meanPOC]=binTimeMeanProfile(zTh(thisCast),pocFluxNssTh(thisCast),zEdgesNP,mldNP.cruise);
%line(meanPOC,meanZ,'color','k','linewidth',2)
end


offset=abs('a')-1;
for i=1:8
  text(ha(i),-7.5,-25,[char(offset+i),')'],'fontsize',22, ...
       'fontweight','demi');
    xlabel(ha(i),'POC flux (mg C m^{-2} d^{-1})')
  
end

set(ha,'YTick',[0:100:500])