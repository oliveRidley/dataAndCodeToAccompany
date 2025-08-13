% left panel should be 23 bin pooled fit sed traps
% right panel should be 23 bin pooled fit Th

clear
addpath ../..
definePathsAndFiles



figure('pos',[ 100   740   1080   607],'defaultAxesFontSize',16);
colormap(turbo); 

%Pekka Kumpulainen (2025). tight_subplot(Nh, Nw, gap, marg_h, marg_w) (https://www.mathworks.com/matlabcentral/fileexchange/27991-tight_subplot-nh-nw-gap-marg_h-marg_w), MATLAB Central File Exchange. Retrieved January 29, 2025. 
 [ha, pos] = tight_subplot(1, 2, .13, [.13 .025], [.075 .1]);

load('../../matchingAndFit/sedTrap/mergedFits.mat','mdlAll','zTrapNA','zTrapNP','r2_All')
 
 
 NA= [true(18,1);false(32,1)];  % which of the 50 are NA?  true=NA
                                % false=NP
ylab='traps-POC flux (mg C m^{-2}d^{-1})';
xlab='UVP-POC flux (mg C m^{-2}d^{-1})';
tickLabs={'1','10','100','1000'};ticks=10.^(0:3);			
axes(ha(1));
scatter(10.^mdlAll.Fitted(NA),10.^mdlAll.Variables.y(NA),75,zTrapNA,'filled','Marker','o');
hold on
scatter(10.^mdlAll.Fitted(~NA),10.^mdlAll.Variables.y(~NA),120,zTrapNP,'filled','Marker','p');

set(gca,'xscale','log','yscale','log','Xlim',[1 1800],'Ylim',[1 ...
		    1800],'dataaspectratio',ones(1,3),'Xtick', ...
	ticks,'Ytick',ticks,'XTickLabel',tickLabs,...
    'YTickLabel',tickLabs)
grid on;href(2)=refline(1);box on;href(2).Color='k';
ylabel(ylab);
xlabel(xlab);
ha(2).YTickLabel=[];
text(1.25,950,sprintf('A=%4.2f B=%4.2f\nr^2=%3.2f RMSE=%4.2f',mdlAll.Coefficients.Estimate,r2_All,10.^mdlAll.RMSE),'FontSize',14)


load('../../matchingAndFit/Th/fitAll.mat','mdlDeepAll','r2_DeepAll', ...
     'yAll','Xall','N*')


isNA=[true(length(NA.zTh),1);false(length(NP.zTh),1)];



ylab=' ^{234}Th-POC flux (mg C m^{-2}d^{-1})';
xlab='UVP-POC flux (mg C m^{-2}d^{-1})';

axes(ha(2));
scatter(10.^mdlDeepAll.Fitted(isNA),10.^mdlDeepAll.Variables.y(isNA),75,NA.zTh,'filled','Marker','o');
hold on
scatter(10.^mdlDeepAll.Fitted(~isNA),10.^mdlDeepAll.Variables.y(~isNA),120,NP.zTh,'filled','Marker','p');
set(gca,'xscale','log','yscale','log','Xlim',[1 1800],'Ylim',[1 ...
		    1800],'dataaspectratio',ones(1,3),'Xtick', ...
	ticks,'Ytick',ticks,'XTickLabel',tickLabs,...
    'YTickLabel',tickLabs)

grid on;hl=refline(1);hl.Color='k';box on;
ylabel(ylab);
xlabel(xlab);
text(1.25,950,sprintf('A=%4.2f B=%4.2f\nr^2=%3.2f RMSE=%4.2f',mdlDeepAll.Coefficients.Estimate,r2_DeepAll,10.^mdlDeepAll.RMSE),'FontSize',14);
cb=colorbar;cb.Ticks=0:100:500;
cb.Label.String='Depth (m)'
ha(2).Position=pos{2};


text(ha(1),.3,3600,'a)','fontsize',22);
text(ha(2),.3,3600,'b)','fontsize',22);
axes(ha(2));
hl(1)=plot(7,300,'o','markersize',10);
hl(2)=plot(7,190,'p','markersize',15);
set(hl,'clipping','off','markerEdgeColor','none', ...
       'markerFaceColor',[.7 .7 .7]);
ht(1)=text(7.5,300,' =NA','Fontweight','demi','Color',[.5 .5 .5]);
ht(2)=text(7.5,190,' =NP','Fontweight','demi','Color',[.5 .5 .5]);
set(ht,'FontSize',16)
copyobj([ht,hl],ha(1))
