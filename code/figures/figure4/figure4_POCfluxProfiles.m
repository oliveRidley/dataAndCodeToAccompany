%[fields@ember figure3]$ diff fuckAroundWith3.m figure3_POCfluxProfiles.m
%51c51
%< load('../../matchingAndFit/Th/NP/fitNP.mat','mdlDeepNP','pocFluxNssTh','zTh','epochTh','ctdTh','pocFluxNssUncTh')
%---
%> load('../../matchingAndFit/Th/NP/fitNP.mat','mdlDeepNP','pocFluxNssTh','zTh','epochTh','ctdTh')
%92c92
%< 	'color','b','markerfacecolor','b','markersize',4,'clipping','on')
%---
%> 	'color','b','markerfacecolor','b','markersize',6,'clipping','off')
%108c108
%< 	'color','b','markerfacecolor','b','markersize',4,'clipping','on')
%---
%> 	'color','b','markerfacecolor','b','markersize',6,'clipping','off')
%126c126
%< hold on
%---
%> 
%129,131c129
%< %  line(pocFluxNssTh(thisCast),zTh(thisCast),'color',liteGrey)
%<    errorbar(pocFluxNssTh(thisCast),zTh(thisCast),pocFluxNssUncTh(thisCast),'d','horiz',...
%< 	'color','b','markerfacecolor','b','markersize',4,'clipping','on','linewidth',.5) 
%---
%>   line(pocFluxNssTh(thisCast),zTh(thisCast),'color',grey)
%138c136
%< %line(meanPOC,meanZ,'color','k','linewidth',2)
%---
%> line(meanPOC,meanZ,'color','k','linewidth',2)
%151,154c149
%< %  line(pocFluxNssTh(thisCast),zTh(thisCast),'color','b')
%<   hold on
%<   errorbar(pocFluxNssTh(thisCast),zTh(thisCast),pocFluxNssUncTh(thisCast),'d','horiz',...
%< 	'color','b','markerfacecolor','b','markersize',4,'clipping','on','linewidth',.5)
%---
%>   line(pocFluxNssTh(thisCast),zTh(thisCast),'color',grey)
%161c156
%< %line(meanPOC,meanZ,'color','k','linewidth',2)
%---
%> line(meanPOC,meanZ,'color','k','linewidth',2)
%[fields@ember figure3]$ c
%


% NA with 8 panels
%top panels sedtrap
%bottom panels 234Th
% column 1 global fit
% columns 2-4 regional fits, columns 2-4 are the Epochs 1-3
% 
% sedTraps 1 global 2 E1  3 E2 4 E3
% 234Th    5 global 6 E1  7 E2 8 E3

% figure 3 is the same set up with NP.

addpath ../..
definePathsAndFiles
%DUMBASS depth bins to do time mean Th profiles
zEdgesNA=[0  43    57    70    89   104   119   137   168   211   241   266   289   317   423   541];
	 
	 
	 
load([DATA,'/mld/mldInfo.mat'],'mldNA')
pink=[1,.75 .75]; % chg [.6 .6 .6]; to pink
liteGrey=[.8 .8 .8];
grey=[.45 .45 .45];



load(whereUVP.NA,'t','psd','station','ship','r2ec','z')
psd(:,1:2,:)=[];
inEddy=r2ec<=15;

NAuvp.psd=psd(:,:,inEddy); clear psd
NAuvp.station=station(inEddy);
NAuvp.ship=ship(inEddy);
NAuvp.epoch=discretize(t(inEddy),datenum(2021,5,[4,11,21,30]));

% make it just the inEddy subset

% want poc calculated from several models
% bot row2  col 1 mdlAll     col 2-4 mdlNP      These are sed Trap
% top row1  col 1 mdlDeepAll col 2-4 mdlDeepNP  these are 234Th

load('../../matchingAndFit/sedTrap/mergedFits.mat','mdlAll','d','bw');
load('../../matchingAndFit/sedTrap/NA/matchAndFits_NA.mat','mdlNA','zTrapNA','pocFlux*NA','epochNA')
load('../../matchingAndFit/Th/fitAll.mat','mdlDeepAll')
load('../../matchingAndFit/Th/NA/fitNA.mat','mdlDeepNA','pocFluxNssTh','zTh','epochTh','ctdTh','pocFluxNssThErr')

NAuvp.pocGlobalSedTrap=calcPOCflux(mdlAll,d,bw,NAuvp.psd);
NAuvp.pocRegionalSedTrap=calcPOCflux(mdlNA,d,bw,NAuvp.psd);
NAuvp.pocGlobalTh=calcPOCflux(mdlDeepAll,d,bw,NAuvp.psd);
NAuvp.pocRegionalTh=calcPOCflux(mdlDeepNA,d,bw,NAuvp.psd);


% dyThCasts is cell of the RRS Discovery Casts that match for each epoch
% dyThCasts{1} would be the casts that matched in epoch 1
%
% uvpIndInEpochNP  contains specifications for the uvp that match
% [ind (of inEddy subset of merged uvp), castNumber, ship (Discovery==2)]  
load([CODE,'matchingAndFit/tallys.mat'],'dyThCasts','uvpIndInEpochNA');

%%%%%%%%%%%%
% now get poc data (from Sam and Meg)


%%%

figure('pos',[100 740 1200 900],'defaultAxesFontSize',16)

%figure('units','norm','pos',[0 0 1 1])
[ha, pos] = tight_subplot(2, 4, [.1 .05], [.075 .05], [.05 .05]); 


% panel 1 sed trap global fit


axes(ha(1))
use=find(z>mldNA.cruise);  % shallower than the cruise mean mix layer
plot(NAuvp.pocGlobalSedTrap(use,uvpIndInEpochNA{end}(:,1)),z(use),'color',pink)
set(gca,'ydir','rev','xlim',[0 500],'ylim',[0 505])
line([0 500],repmat(mldNA.cruise,1,2),'color','r','linestyle','--');
line(nanmean(NAuvp.pocGlobalSedTrap(use,uvpIndInEpochNA{end}(:,1)),2),z(use),'color','r','linewidth',2);

hold on
errorbar(pocFluxNA,zTrapNA,pocFluxUncNA,'d','horiz',...
	'color','b','markerfacecolor','b','markersize',4,'clipping','off')
ylabel('depth (m)')
title('NA global with traps')

for i=1:3
axes(ha(i+1))
use=find(z>mldNA.epoch(i));  % shallower than epoch1 mean  mix
                             % layer
plot(NAuvp.pocRegionalSedTrap(use,uvpIndInEpochNA{i}(:,1)),z(use), ...
     'color',pink)
set(gca,'ydir','rev','xlim',[0 500],'ylim',[0 505])
line([0 500],repmat(mldNA.epoch(i),1,2),'color','r','linestyle','--');
line(nanmean(NAuvp.pocRegionalSedTrap(use,uvpIndInEpochNA{i}(:,1)),2),z(use),'color','r','linewidth',2);
hold on
thisEpoch=epochNA==i;
errorbar(pocFluxNA(thisEpoch),zTrapNA(thisEpoch),pocFluxUncNA(thisEpoch),'d','horiz',...
	'color','b','markerfacecolor','b','markersize',4,'clipping','off')
title(sprintf('NA E%1d',i))
end





% lower panel now
% which is the 234Th poc flux
for i=1:4
indUvpMatchingTh{i}=...
    (NAuvp.ship==2 &  ismember(NAuvp.station,dyThCasts{i}));
end



axes(ha(5))
use=find(z>mldNA.cruise);  % shallower than the cruise mean mix layer
plot(NAuvp.pocGlobalTh(use,indUvpMatchingTh{4}),z(use),'color',pink)
set(gca,'ydir','rev','xlim',[0 500],'ylim',[0 505])
line([0 500],repmat(mldNA.cruise,1,2),'color','r','linestyle','--');
line(nanmean(NAuvp.pocGlobalTh(use,indUvpMatchingTh{4}),2),z(use),'color','r','linewidth',2);
title('NA global with ^{234}Th')
ylabel('depth (m)');
hold on
for i=dyThCasts{4}'
  thisCast=find(ctdTh==i & zTh>mldNA.cruise); 
%  line(pocFluxNssTh(thisCast),zTh(thisCast),'color','b');
 errorbar(pocFluxNssTh(thisCast),zTh(thisCast),pocFluxNssThErr(thisCast),'d','horiz','color','b','markerfacecolor','b','markersize',4,'clipping','on','linewidth',.5) 
end


% mean of all these
thisCast=(ismember(ctdTh,dyThCasts{4}) & zTh>mldNA.cruise); 
[meanZ,meanPOC]=binTimeMeanProfile(zTh(thisCast),pocFluxNssTh(thisCast),zEdgesNA,mldNA.cruise);
%line(meanPOC,meanZ,'color','k','linewidth',2)


for iepoch=1:3
  axes(ha(iepoch+5))
use=find(z>mldNA.epoch(iepoch));  % shallower than the cruise mean mix layer
plot(NAuvp.pocRegionalTh(use,indUvpMatchingTh{iepoch}),z(use),'color',pink)
set(gca,'ydir','rev','xlim',[0 500],'ylim',[0 505])
line([0 500],repmat(mldNA.epoch(iepoch),1,2),'color','r','linestyle','--');
line(nanmean(NAuvp.pocRegionalTh(use,indUvpMatchingTh{iepoch}),2), ...
     z(use),'color','r','linewidth',2);
hold on
title(sprintf('NA E%1d',iepoch))
for i=dyThCasts{iepoch}'
  thisCast=find(ctdTh==i & zTh>mldNA.epoch(iepoch)); 
  %line(pocFluxNssTh(thisCast),zTh(thisCast),'color',grey)
  errorbar(pocFluxNssTh(thisCast),zTh(thisCast),pocFluxNssThErr(thisCast),'d','horiz','color','b','markerfacecolor','b','markersize',4,'clipping','on','linewidth',.5)
end


% mean of all these
thisCast=(ismember(ctdTh,dyThCasts{iepoch}) & zTh>mldNA.epoch(iepoch));
[meanZ,meanPOC]=binTimeMeanProfile(zTh(thisCast),pocFluxNssTh(thisCast),zEdgesNA,mldNA.cruise);
%line(meanPOC,meanZ,'color','k','linewidth',2)
end


offset=abs('a')-1;
for i=1:8
  text(ha(i),-7.5*10,-25,[char(offset+i),')'],'fontsize',22, ...
       'fontweight','demi');

    xlabel(ha(i),'POC flux (mg C m^{-2} d^{-1})')
    
  
end

set(ha,'YTick',[0:100:500])