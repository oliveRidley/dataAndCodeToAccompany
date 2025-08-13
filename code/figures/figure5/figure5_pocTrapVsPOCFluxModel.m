
load('../../matchingAndFit/sedTrap/mergedFits.mat',...
     'Xall','yAll','d*','bw*','mdlAll', ...
     'mdlAll8','use8','logCfluxPSD','use8')
     
% bands to use for kriest 1mm to 10mm
useK=find(d>=1 & d<=10); % use 
%>> disp(d(useK))
%    1.1494    1.4482    1.8246    2.2988    2.8963    3.6491    4.5976    5.7926    7.2982    9.1952

pocFluxTrap=10.^yAll;


Clements=doClements(Xall,d);
cfluxPSD=@(c,psd,d,bw) nansum(psd.*(c(1).*(d.^c(2)).*bw),2);

% modelled cflux using Kriest.
Kriest=cfluxPSD([16.5 2.24],Xall(:,useK),d(useK),bw(useK));


figure('pos', [193   720   921   617],'defaultAxesFontSize',16);
loglog(Clements,pocFluxTrap,'markerfacecolor',[.95,.95,.45], ...
       'markeredgecolor','none','marker','s','linestyle','none')
hold on
% Kriest 
loglog(Kriest,pocFluxTrap,'markerfacecolor',[1 .75 .75], ...
       'markeredgecolor','none','marker','d','linestyle','none')

hold on

% exports done the same way, 8 bands
% guidi out of the box
Goob=cfluxPSD([12.5 3.81],Xall(:,use8),d8,bw8); % Guidi "out of the box"
loglog(Goob,pocFluxTrap,'bo'); 

loglog(10.^mdlAll8.Fitted,pocFluxTrap,'pk','markerfacecolor','k')

% exports using 23 bands.
loglog(10.^mdlAll.Fitted,pocFluxTrap,'+','linewidth',1.5,'color',[.75 0 0])


%loglog([pocFluxNA;pocFluxNP],pocUVPall,'dk','markerfacecolor','k')
axis([.5 1000 .5 1000])

set(gca,'dataaspectratio',[ 1 1 1]);
set(gca,'xtick',get(gca,'ytick'))
numBands=[8 23 8];
nameSet={'  Clements et.al. (2023)','  Kriest (2002)', '  Guidi et.al. (2008)',...
	 '  EXPORTS 8','  EXPORTS 23',};
c=[[18.0,2.63];[16.49,2.24];[12.5 3.81];...
    mdlAll8.Coefficients.Estimate';mdlAll.Coefficients.Estimate'];
legendStr=cell(5,1);
   for i=1:5
legendStr{i}=sprintf('A=%5.2f B=%5.2f %s',c(i,:),nameSet{i});
end

legend(legendStr,'Interpreter','Tex','autoupdate','off')


hl=refline(1); set(hl,'color','k','linestyle',':')
ylabel('traps-POC flux (mg C m^{-2} d^{-1})')
xlabel('UVP-POC flux (mg C m^{-2} d^{-1})')
grid on


set(findobj('type','line'),'markersize',10)

set(findobj('type','line','marker','+'),'LineWidth',2)

set(gca,'YTickLabel',{'1','10','100','1000'},'XTickLabel',{'1','10','100','1000'})