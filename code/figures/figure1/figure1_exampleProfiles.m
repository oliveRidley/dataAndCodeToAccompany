function figure1_exampleProfiles()
addpath ../..
definePathsAndFiles
load(whereUVP.NA','psd','t','binInfo','station','ship','z');
 psdBinCenter=binInfo.bin_centers_diam;

Nprofile=NaN(101,25,3);

use3=find(ship==2 & station==94);  % matching casts elena had.
use2=find(ship==2 & station==3);


Nprofile(:,:,2)=psd(:,:,use2);
Nprofile(:,:,3)=psd(:,:,use3);



load(whereUVP.NP,'psd','isRide','station');
use1=find(isRide & station==56);
Nprofile(:,:,1)=psd(:,:,use1);
Nprofile(:,1:2,:)=NaN;  % only show bands common to all


clear psd  use* binInfo station ship isRide uvpFile


figure('pos',[100    800   800   900],'defaultaxesfontsize',16);

%colormap(turbo(256))
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

[ha,pos]=tight_subplot(3,2,[.075 .15],.1 ,.1);
labs={'a)','b)','c)'};
labs2={'NP E2', 'NA E1', 'NA E3'};

for i=1:3
makeBrowse(ha(2*i+[ -1 0]),Nprofile(:,:,i),psdBinCenter,z);
text(ha(2*i-1),.033,-41.5,labs{i},'fontsize',22,'fontweight','demi');
text(ha(2*i-1),5,450,labs2{i},'fontsize',18,'fontweight','demi');

end
return

function makeBrowse(hax,psd,d,z)
cmap=viridis(256);
colormap(cmap);
axes(hax(1));
set(hax(1),'ColorScale','log','Xscale','log')
imagesc(d,z,psd,'alphadata',~isnan(psd) & psd>0);
set(gca,'ColorScale','log')
caxis(10.^[-3 4]);
cb=colorbar;
cb.Label.String='abundance (# L^{-1} mm^{-1})';
cb.Label.FontSize=hax(1).YLabel.FontSize;
cb.Ruler.MinorTick = 'on';
cb.TickLength=.025


set(gca,'XScale','log');
set(gca,'xtick',[.1  1 10]);
set(gca,'XTickLabel',{'0.1','1','10'})
xlabel('ESD (mm)');
ylabel('depth (m)')

axes(hax(2));
% make colors for lines 
% interpolating the jet colormap.
lineColors=interp1(linspace(0, 520,256),cmap,z);
loglog(d,psd(1,:),'color',lineColors(1,:));
for j=2:length(z)
line(d,psd(j,:),'color',lineColors(j,:));
end
set(gca,'xtick',[.1  1 10]);
set(gca,'XTickLabel',{'0.1','1','10'})
    


grid on
box on
ylabel('abundance (# L^{-1} mm^{-1})')
xlabel('ESD (mm)')
caxis([0 500])
set(gca,'ylim',10.^[-3 4],'xlim', [.075   23.6513],'Xtick',[.1 1 10])

cb=colorbar(hax(2));
cb.Ticks=[0:100:500];
cb.Label.String='depth (m)';
cb.Label.FontSize=hax(1).YLabel.FontSize;

return


