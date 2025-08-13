% match uvp to 234Th measurements of carbon flux from RV Ride and
% fit.   use 23 bins and only measurements deeper than the mld.

addpath ../../../
definePathsAndFiles

opts=statset('Display','final','DerivStep',eps^(1/3),'TolFun',1e-13);




% this matches up nss Th234  poc fluxes with uvp data 
% since the Th is from Ride, this really just finding the uvp data for that 
% Th cast
% 



T=readtable(wherePOCflux.Th.NP, 'sheet','Table S1','range','A6:U765','readVariableNames',false);

% header doesn't read in properly. brute force it manually
% readVariableNames false
%
% it might be confused by all the annotation and multiline header
% Var2    depth
% Var4    ctd
% Var5    epoch
% Var6    lat
% Var7    lon
% Var9,10  date time
% Var18   SS POC flux (mmol/m^2/d)
% Var19   SS POC flux unc
%
% depth and ctd should match uvp, lat, lon, time are bonus to
% confirm.

zTh=T.Var2;
ctdTh=T.Var4;
epochTh=T.Var5;
pocFluxNssTh=12*T.Var20;
pocFluxNssUncTh=12*T.Var21;

% load the MLD sift out the Ride 

load(whereMld.NP);
%MLD_all.platform_id(1) 'SRide = 1'
mld=MLD_all(4).MLD(MLD_all(4).platform==1);
mldTh=mld(ctdTh); clear MLD_all mld;

ibin=fix(zTh/5)+1;  % 5m depth bin the measurement falls into


% load UVP
load(whereUVP.NP,'z','psd','t','isRide','binInfo','station');

t(~isRide)=[]; % just want the Ride (from which 234Th measurements
               % were made)
station(~isRide)=[];
psd=psd(:,3:end,isRide); % 3-end-1 are the sizes we will use.


% this is checking to see if for  Th, there is a
% corresponding uvp (station is ctd cast number).
[i,j]=ismember(ctdTh,station);

% some ctdTh don't have corresponding uvp (49,60,106,115,120)
% toss those and one that is 752m depth 
% and depths shallower than 50????
toss=(~i | ibin>101 | pocFluxNssTh<=0 );
%toss=(toss & z<50)
zTh(toss)=[];ctdTh(toss)=[];pocFluxNssTh(toss)=[];...
	  pocFluxNssUncTh(toss)=[];ibin(toss)=[];j(toss)=[];epochTh(toss)=[];
mldTh(toss)=[];

n=length(ibin);
psdUse=zeros(n,23);
for i=1:n
  use=ibin(i)-[0:3];use(use<=0)=[];
psdUse(i,:)=nanmean(psd(use,:,j(i)),1);
end


% turns out there are some records with missing data, NaN.  the uvp 
allMissing=sum(isnan(psdUse),2)==size(psdUse,2);  % checks for if all are NaN
psdUse(allMissing,:)=[];;
zTh(allMissing)=[];
epochTh(allMissing)=[];
pocFluxNssTh(allMissing)=[];
pocFluxNssUncTh(allMissing)=[];
j(allMissing)=[];
ctdTh(allMissing)=[];
mldTh(allMissing)=[];
clear allMissing

deeperThanMld=find(zTh(:)>mldTh(:));
XNP=psdUse(deeperThanMld,:);
yNP=log10(pocFluxNssTh(deeperThanMld));

d=binInfo.bin_centers_diam(3:end);
bw=binInfo.bin_widths(3:end);
logCfluxPSD=@(c,psd,d,bw) log10(nansum(psd.*(c(1).*(d.^c(2)).*bw),2)); 
blah=@(b,X) logCfluxPSD(b,X,d,bw); % make function with only the b X


mdlDeepNP=fitnlm(XNP,yNP,blah,[8,2],'Options',opts)

disp('23 bin fit')
disp(sprintf('A=%6.3f A_ci=[%6.3f, %6.3f]\nb=%6.3f b_ci=[%7.3f, %6.3f]',[mdlDeepNP.Coefficients.Estimate mdlDeepNP.coefCI]'))
r2_NP=my_r2(logCfluxPSD(mdlDeepNP.Coefficients.Estimate,XNP,d,bw),yNP);
disp(sprintf('r2=%4.2f\nmy r^2=%4.2f',mdlDeepNP.Rsquared.Ordinary,r2_NP))

 

% make all the other useful variables consistent (deeperThanMld etc)
epochTh=epochTh(deeperThanMld);
mldTh=mldTh(deeperThanMld);
pocFluxNssTh=pocFluxNssTh(deeperThanMld);
pocFluxNssUncTh=pocFluxNssUncTh(deeperThanMld);
psdUse=psdUse(deeperThanMld,:);
j=j(deeperThanMld);
zTh=zTh(deeperThanMld);
ctdTh=ctdTh(deeperThanMld);

ju=unique(j);  % indices of unique casts used.
psd=psd(:,:,ju);
station=station(ju);
t=t(ju);

clear isRide toss i where* CODE DATA ibin HOME T j* opts n


save fitNP 


% likely not used
if false
% is 8 bin is wanted change false to true
disp('8 bin fit')
use8=find(d>=.25 & d<=1.5);
d8=d(use8);
bw8=bw(use8);
blah8=@(b,X) logCfluxPSD(b,X,d8,bw8); % make function with only the b X

mdlDeepNP8=fitnlm(XNP(deeperThanMld,use8),yNP(deeperThanMld),blah8,[8,2],...
		 'Options',opts)
disp('8 bin fit')
disp(sprintf('A=%6.3f A_ci=[%6.3f, %6.3f]\nb=%6.3f b_ci=[%7.3f, %6.3f]',[mdlDeepNP8.Coefficients.Estimate mdlDeepNP8.coefCI]'))
r2_NP=my_r2(logCfluxPSD(mdlDeepNP8.Coefficients.Estimate,XNP(deeperThanMld,use8),d8,bw8),yNP(deeperThanMld));
disp(sprintf('r2=%4.2f\nmy r^2=%4.2f',mdlDeepNP.Rsquared.Ordinary,r2_NP))
end

%>> matchThAndUVPThenFitNP
%Iterations terminated: relative norm of the current step is less than OPTIONS.TolX
%
%mdlDeepNP = 
%
%
%Nonlinear regression model:
%    y ~ F(b,X)
%
%Estimated Coefficients:
%          Estimate       SE       tStat       pValue  
%          ________    ________    ______    __________
%
%    b1      25.81       1.7549    14.708    1.0299e-41
%    b2     1.4529     0.076719    18.939     2.398e-62
%
%
%Number of observations: 569, Error degrees of freedom: 567
%Root Mean Squared Error: 0.382
%R-Squared: -0.452,  Adjusted R-Squared -0.454
%F-statistic vs. constant model: 0, p-value = 1
%23 bin fit
%A=25.810 A_ci=[22.363, 29.257]
%b= 1.453 b_ci=[  1.302,  1.604]
%r2=-0.45
%my r^2=0.08