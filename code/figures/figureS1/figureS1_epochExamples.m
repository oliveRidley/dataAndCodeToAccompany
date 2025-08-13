function figureS1_epochExamples()
addpath ../..
definePathsAndFiles
load(whereUVP.NA,'psd','t','binInfo','station','ship','z');
 psdBinCenter=binInfo.bin_centers_diam;

Nprofile=NaN(101,25,6);
dyCast=[3 33 94];
for i=1:3
use=find(ship==2 & station==dyCast(i));  % matching casts
                                              % elena had.
					      
Nprofile(:,:,i+3)=psd(:,:,use);
end




load(whereUVP.NP,'psd','isRide','station');

rideCast=[12,56 116];
for i=1:3
use=find(isRide & station==rideCast(i));
Nprofile(:,:,i)=psd(:,:,use);
end


Nprofile(:,1:2,:)=NaN;  % only show bands common to all


clear psd  use* binInfo station ship isRide uvpFile


figure('pos',[423    730   1200   700],'defaultaxesFontSize',16);
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

[ha,pos]=tight_subplot(3,4,[.075 .075],.05 ,.075);
% scoot 2nd column left a scootch say 10%, ax indices 2 6 10
% scoot 3rd column right same. ax indices 3 7 11
% 
ind=[2 6 10];
for i=1:3
  ha(ind(i)).Position(1)=ha(ind(i)).Position(1)*.95;
  ha(ind(i)+1).Position(1)=ha(ind(i)+1).Position(1)*1.025;
end

imgAxeInd=[1,5, 9 3 7 11];
label={'NP E1','NP E2','NP E3','NA E1','NA E2','NA E3'};
label2={'a)','b)','c)','d)','e)','f)'};
for i=1:length(imgAxeInd)
makeBrowse(ha(imgAxeInd(i)+[ 0 1]),Nprofile(:,:,i),psdBinCenter,z);
text(ha(imgAxeInd(i)),.02,-45.5,label2{i},'fontsize',24,'fontweight','demi');
text(ha(imgAxeInd(i)),5,450,label{i},'fontsize',14,'fontweight','demi');
end
return

function makeBrowse(hax,psd,d,z)
cmap=viridis(256);
% using colormap viridis from-
%Stephen23 (2025). MatPlotLib Perceptually Uniform Colormaps 
%(https://www.mathworks.com/matlabcentral/fileexchange/62729-matplotlib-perceptually-uniform-colormaps)
%MATLAB Central File Exchange. Retrieved August 11, 2025. 
colormap(cmap);
axes(hax(1));
set(hax(1),'ColorScale','log','Xscale','log')
imagesc(d,z,psd,'alphadata',~isnan(psd) & psd>0);
set(gca,'ColorScale','log')
caxis(10.^[-3 4]);
cb=colorbar;
%cb.Label.String='abundance (# L^{-1} mm^{-1})';
%cb.Label.FontSize=hax(1).YLabel.FontSize;
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
cb.Label.FontSize=hax(1).YLabel.FontSize;%

return


