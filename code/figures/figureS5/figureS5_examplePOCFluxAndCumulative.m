function figureS5_examplePOCFluxAndCumulative()
% following figure1 show example profiles from NP and NA
% left panels will be the spectral POC flux (mg C/m^2/d/mm) 
% right panels will be the normalized cummulative integral POC flux
addpath ../..
definePathsAndFiles
load(whereUVP.NA','psd','t','binInfo','station','ship','z');

Nprofile=NaN(101,25,3);
load('../../matchingAndFit/sedTrap/mergedFits.mat','mdlAll','d', ...
     'bw')
A=mdlAll.Coefficients.Estimate(1);
b=mdlAll.Coefficients.Estimate(2);
blah=A*d.^b;

use3=find(ship==2 & station==94);  % matching casts elena had.
use2=find(ship==2 & station==3);


Nprofile(:,:,2)=psd(:,:,use2);
Nprofile(:,:,3)=psd(:,:,use3);



load(whereUVP.NP,'psd','isRide','station');
use1=find(isRide & station==56);
Nprofile(:,:,1)=psd(:,:,use1);
Nprofile(:,1:2,:)=[];  % only show bands common to all


for i=1:3
  Nprofile(:,:,i)=disappearLS(Nprofile(:,:,i));
end
Nprofile=movmean(Nprofile,[3,0],'omitnan');

clear psd  use* binInfo station ship isRide uvpFile
POCprofile=Nprofile.*blah;
cumPOCprofile=cumtrapz(bw,POCprofile,2);
ncumPOCprofile=cumPOCprofile./cumPOCprofile(:,end,:);
figure('pos',[100    800   800   900],'defaultaxesfontsize',16);

colormap(turbo(256))
%Pekka Kumpulainen (2025). tight_subplot(Nh, Nw, gap, marg_h,marg_w) (https://www.mathworks.com/matlabcentral/fileexchange/27991-tight_subplot-nh-nw-gap-marg_h-marg_w), MATLAB Central File Exchange. Retrieved January 29, 2025. 

%  [ha, pos] = tight_subplot(Nh, Nw, gap, marg_h, marg_w)
% 
%    in:  Nh      number of axes in hight (vertical direction)
%         Nw      number of axes in width (horizontaldirection)
%         gap     gaps between the axes in normalized units (0...1)
%                    or [gap_h gap_w] for different gaps in height and width 
%         marg_h  margins in height in normalized units (0...1)
%                    or [lower upper] for different lower and upper margins 
%         marg_w  margins in width in normalized units (0...1)
%                    or [left right] for different left and right margins 
% 
%   out:  ha     array of handles of the axes objects
%                    starting from upper left corner, going row-wise as in
%                    subplot
%         pos    positions of the axes objects

[ha,pos]=tight_subplot(3,2,[.075 .15],.1 ,.15);
labs={'a)','b)','c)'};
labs2={'NP E2', 'NA E1', 'NA E3'};

for i=1:3
makeBrowse(ha(2*i+[ -1 0]),POCprofile(:,:,i),ncumPOCprofile(:,:,i),d,z);
text(ha(2*i-1),.13,1,labs{i},'fontsize',22,'fontweight','demi');
text(ha(2*i-1),1.5,450,labs2{i},'fontsize',18,'fontweight','demi');
end
xlabel(ha([5,6]),'ESD (mm)')
ylabel(ha(3),'POC Flux (mg C m^{-2} d^{-1} mm^{-1})')
%ylabel(ha(4),{'Normalized Cumulative';'POC flux (mg C m^{-2}
%d^{-1})'})
ylabel(ha(4),'Normalized Cumulative POC flux (mg C m^{-2} d^{-1})')
axes(ha(4))
opos=get(ha(4),'pos')
cb=colorbar(ha(4));
cb.Ticks=[0:100:500];
cb.Label.String='depth (m)';
cb.Label.FontSize=ha(4).YLabel.FontSize;
set(ha(4),'pos',opos);
return

function makeBrowse(hax,pocFlux,npocFlux,d,z)
cmap=turbo(256);
colormap(cmap);
axes(hax(1));
% make colors for lines 
% interpolating the jet colormap.
lineColors=interp1(linspace(0, 520,256),cmap,z);
loglog(d,pocFlux(1,:),'color',lineColors(1,:));
for j=2:length(z)
line(d,pocFlux(j,:),'color',lineColors(j,:));
end
grid on 
box on
%caxis(10.^[-3 4]);
%cb=colorbar;
%cb.Label.String='POC flux (mg C m^{-2} d^{-1} mm^{-1})';
%cb.Label.FontSize=hax(1).YLabel.FontSize;
%cb.Ruler.MinorTick = 'on';
%cb.TickLength=.025


set(gca,'XScale','log');
set(gca,'xtick',[.1  1 10],'xlim',[.1 15]);
set(gca,'XTickLabel',{'0.1','1','10'})
%xlabel('ESD (mm)');
%ylabel('POC Flux (mg C m^{-2} d^{-1} mm^{-1})')
set(gca,'ylim',[.25 1e4])
axes(hax(2));
% make colors for lines 
% interpolating the jet colormap.
semilogx(d,npocFlux(1,:),'color',lineColors(1,:));
for j=2:length(z)
line(d,npocFlux(j,:),'color',lineColors(j,:));
end
set(gca,'xtick',[.1  1 10],'xlim',[.1 15]);
set(gca,'XTickLabel',{'0.1','1','10'})
    


grid on
box on
%ylabel({'Normalized Cumulative';'POC flux (mg C m^{-2} d^{-1})'})
%xlabel('ESD (mm)')
caxis([0 500])
set(gca,'xlim', [.075   23.6513],'Xtick',[.1 1 10])
%opos=get(hax(2),'pos')
%cb=colorbar(hax(2));
%cb.Ticks=[0:100:500];
%cb.Label.String='depth (m)';
%cb.Label.FontSize=hax(1).YLabel.FontSize;
%set(hax(2),'pos',opos);
return

function Npro=disappearLS(Npro)
% make dmax be the location of the first 0 or NaN, removing large solitary
% isolated sizes.  where the spectrum first goes to zero, and
% ignore the larger isolated sizes.
for i=1:size(Npro,1)
  imax=find(Npro(i,:)<=0 | isnan(Npro(i,:)),1,'first');
  Npro(i,imax:end)=0;
end
return