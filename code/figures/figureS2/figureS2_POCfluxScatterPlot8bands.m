%Figure S3 is the equivalent of panel a) in Figure 2 for the traps 8 size bins


% left panel should be 8 bin pooled fit sed traps
% right panel LEAVE empty
%
addpath ../..
figure('pos',[ 309   740   1080   607],'defaultaxesfontsize',16)
colormap(turbo)
 [ha, pos] = tight_subplot(1, 2, .13, [.13 .0275], [.075 .1]);
load('../../matchingAndFit/sedTrap/mergedFits.mat','mdlAll8','zTrapNA','zTrapNP','r2_All8')
  
 
 NA= [true(length(zTrapNA),1);false(length(zTrapNP),1)];  % which of the 50 are NA?  true=NA false=NP

ylab='traps-POC flux (mg C m^{-2}d^{-1})';
xlab='UVP-POC flux (mg C m^{-2}d^{-1})';
				
axes(ha(1))
scatter(10.^mdlAll8.Fitted(NA),10.^mdlAll8.Variables.y(NA),75,zTrapNA,'filled','Marker','o')
hold on
scatter(10.^mdlAll8.Fitted(~NA),10.^mdlAll8.Variables.y(~NA),120,zTrapNP,'filled','Marker','p')

set(gca,'xscale','log','yscale','log','Xlim',[1 1800], ...
    'Ylim',[1 1800],'dataaspectratio',ones(1,3),...
    'XTick',[1 10 100 1000],'XTickLabel',{'1','10','100','1000'},...
     'YTick',[1 10 100 1000],'YTickLabel',{'1','10','100','1000'})
grid on;href(2)=refline(1);box on;href(2).Color='k';
ylabel(ylab)
xlabel(xlab)
ha(2).YTickLabel=[];
text(1.25,950,sprintf('A=%4.2f B=%4.2f\nr^2=%3.2f RMSE=%4.2f',mdlAll8.Coefficients.Estimate,r2_All8,10.^mdlAll8.RMSE),'FontSize',16)




%text(ha(1),.3,3600,'a)','fontsize',20)
%text(ha(2),.3,3600,'b)','fontsize',20)
axes(ha(1))
hl(1)=plot(7,300,'o','markersize',10);
hl(2)=plot(7,190,'p','markersize',15);
set(hl,'clipping','off','markerEdgeColor','none', ...
       'markerFaceColor',[.7 .7 .7])
text(7.5,300,' =NA','Fontweight','demi','Color',[.5 .5 .5],'FontSize',16)
text(7.5,190,' =NP','Fontweight','demi','Color',[.5 .5 .5],'FontSize',16)

axes(ha(1))
cb=colorbar;cb.Ticks=0:100:500;
set(ha(1),'pos',pos{1})
delete(ha(2))
cb.Label.String='depth (m)';
cb.Label.FontSize=get(gca,'FontSize')