function [meanZ,meanPOC]=binTimeMeanProfile(z,poc,zBinEdges,mld)
%function [meanZ,meanPOC]=binTimeMeanProfile(z,poc,zBinEdges,mld)
% 
% give a set of paired z, poc(z) this finds the mean within the
% bins defined by zBinEdges.  Also finds the mean of the depths, to
% assign the meanPOC to. 
%
% mayne this isn't ideal, but the bins are picked from looking at a
% plot of sort(zThNA)  or sort(zThNP) and using ginput to pick the
% boundaries.
% is a bin is empty it will contain NaN, just remove that bin and
% make a profile from the valid data.
ibin=discretize(z,zBinEdges);
nbins=length(zBinEdges)-1;
meanPOC=NaN(nbins,1);
meanZ=meanPOC;


for i=1:nbins
  use=find(ibin==i);
  meanPOC(i)=nanmean(poc(use));
  meanZ(i)=nanmean(z(use));
end
use=find(meanZ>=mld & ~isnan(meanPOC)); % mean depth that isn't
 
meanZ=meanZ(use);
meanPOC=meanPOC(use);

return