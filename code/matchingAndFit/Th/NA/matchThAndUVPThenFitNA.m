addpath ../../../
definePathsAndFiles

opts=statset('Display','final','DerivStep',eps^(1/3),'TolFun',1e-13);







%MLD_DY.mat downloaded from the exports google drive
%
%https://drive.google.com/drive/folders/1kdBrKn7U2xsIArS5qyXBbDlLXHlilH3n
%
%EXPORTS>North Atlantic 2021 > >North Atlantic 2021 Shared Data > CTD / AUV Metrics > Ship CTD Metrics - MLD, Zeu, etc
%
%
%"ZMLD:  Mixed layer depth based on a 0.03 kg/m^3 threshold with respect to a 5-m potential density average beginning after the first non-NaN value greater than or equal to 10-m"
% from README_StandardMetrics
%MLD_DY    and time_DY131
%seems 112 so cast is the array index.
%
load(whereMld.NA)
MLD_DY=MLD_DY';


blah=load(whereUVP.NA,'psd','t','binInfo','station','ship','r2ec');
idy=(blah.ship==2) & (blah.r2ec<=15); % just the DY in the eddy
psd=blah.psd(:,3:end,idy);
station=blah.station(idy);
t=blah.t(idy);
d=blah.binInfo.bin_centers_diam(3:end);
bw=blah.binInfo.bin_widths(3:end);  
clear blah	
 
%
% get poc flux (Th Nss) from Sam Clevenger
load(wherePOCflux.Th.NA)


[hasMatch,whereMatch]=ismember(pocFlux.cast,station);
% this says only station 54 uvp is missing, so 19 matches less
% whereMatch(hasMatch) gives the where in the stations array the
% match is. poc.cast(hasMatch) and matches station(whereMatch(hasMatch));
% 
zTh=pocFlux.z(hasMatch);
ctdTh=pocFlux.cast(hasMatch);
epochTh=pocFlux.epoch(hasMatch);
pocFluxNssTh=pocFlux.flux(hasMatch);
pocFluxNssThErr=pocFlux.fluxErr(hasMatch);
pocFluxInEddy=pocFlux.inEddy(hasMatch);

whereMatch=whereMatch(hasMatch); % location in station of uvps matching.
%station=station(whereMatch);
%t=t(whereMatch);


mldTh=MLD_DY(ctdTh);
ibin=min(fix(zTh/5)+1,101); % If the depth is great than the 502.5m ...
                             % depth of uvp max, just assign it to 502.5
ibin=ibin-[0:3];
psd20m=zeros(length(ibin),23);
for i=1:length(ibin)
   use=ibin(i,:);
   psd20m(i,:)=squeeze(nanmean(psd(use(use>0),:,whereMatch(i)),1));  %20m bin
end


allMissing=(sum(isnan(psd20m),2)==25);  % all nans so no guidi 
negFlux=pocFluxNssTh<=0;
toss=allMissing | negFlux;
ctdTh(toss)=[];
epochTh(toss)=[];
mldTh(toss)=[];
pocFluxNssTh(toss)=[];
pocFluxNssThErr(toss)=[];
pocFluxInEddy(toss)=[];
%station(toss)=[];
%t(toss)=[];
zTh(toss)=[];
psd20m(toss,:)=[];

deeperThanMld=find(zTh(:)>mldTh(:));


castActuallyUsed=ismember(station,unique(ctdTh));
psd=psd(:,:,castActuallyUsed);
station=station(castActuallyUsed);
t=t(castActuallyUsed);



XNA=psd20m(deeperThanMld,:);
yNA=log10(pocFluxNssTh(deeperThanMld));

logCfluxPSD=@(c,psd,d,bw) log10(nansum(psd.*(c(1).*(d.^c(2)).*bw), 2));
blah=@(b,X) logCfluxPSD(b,X,d,bw); % make function with only the b X

% want only the matches deeper than the mixed layer
deeperThanMld=find(zTh>mldTh);
mdlDeepNA=fitnlm(XNA,yNA,blah,[13,4],'Options',opts)
disp('23 bin fit')
disp(sprintf('A=%6.3f A_ci=[%6.3f, %6.3f]\nb=%6.3f b_ci=[%7.3f, %6.3f]',[mdlDeepNA.Coefficients.Estimate mdlDeepNA.coefCI]'))
r2_NA=my_r2(logCfluxPSD(mdlDeepNA.Coefficients.Estimate,XNA,d,bw),yNA);
disp(sprintf('r2=%4.2f\nmy r^2=%4.2f',mdlDeepNA.Rsquared.Ordinary,r2_NA))

 
%>> matchThAndUVPThenFitNA
%Iterations terminated: relative change in SSE less than OPTIONS.TolFun
%
%mdlDeepNA = 
%
%
%Nonlinear regression model:
%    y ~ F(b,X)
%
%Estimated Coefficients:
%          Estimate      SE       tStat       pValue  
%          ________    _______    ______    __________
%
%    b1     6.7669      2.1561    3.1386     0.0018703
%    b2    0.81871     0.24334    3.3644    0.00086882
%
%
%Number of observations: 296, Error degrees of freedom: 294
%Root Mean Squared Error: 0.493
%R-Squared: -11.7,  Adjusted R-Squared -11.7
%F-statistic vs. constant model: 0, p-value = 1
%23 bin fit
%A= 6.767 A_ci=[ 2.524, 11.010]
%b= 0.819 b_ci=[  0.340,  1.298]
%r2=-11.67
%my r^2=0.02
%


pocFluxModeledDeep=10.^mdlDeepNA.predict;





% since only depths > mld were used for matches, lets make it all
% consistently  data below the mld.


pocFluxNssTh=pocFluxNssTh(deeperThanMld);
pocFluxNssThErr=pocFluxNssThErr(deeperThanMld);
zTh=zTh(deeperThanMld);
epochTh=epochTh(deeperThanMld);
ctdTh=ctdTh(deeperThanMld);
psd20m=psd20m(deeperThanMld,:);
mldTh=mldTh(deeperThanMld);

if false
figure

scatter(pocFluxModeledDeep,pocFluxNssTh,30,zTh,'filled')

set(gca,'Xscale','log','yscale','log','dataaspectratio',[1 1 1])
refline(1)
box on 
grid on
end


clear opts CODE DATA HOME ans deeperThanMld opt pocFluxInEddy ...
    castActuallyUsed where*
 clear i j idy  j ibin idy MLD_DY *DY131 toss allMissing negFlux ...
    use hasMatch whereMatch

save fitNA 
