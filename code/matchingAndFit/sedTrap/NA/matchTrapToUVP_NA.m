addpath ../../../
definePathsAndFiles



opts=statset('Display','final','DerivStep',eps^(1/3),'TolFun',1e-13);
T=readtable(wherePOCflux.sedTrap.NA,'Sheet','mean');

% interested in  DepthActual_m DateDeploy_UTC DateResurface_UTC to find uvp cast matches.
load(whereUVP.NA,'r2ec','psd','t','binInfo','r2ec','station','ship');
psdBinCenter=binInfo.bin_centers_diam;
psdBinWidth=binInfo.bin_widths;
psdBinEdge=binInfo.bin_edges_diam;
inEddy=find(r2ec<=15);
psd=psd(:,:,inEddy);
station=station(inEddy);
ship=ship(inEddy);
t=t(inEddy);
psd=permute(psd,[1 3 2]);

psd(:,:,1:2)=NaN; % JC doesn't have these sizes, so blank it for all.

% use the date the lids are closed unless the resurface date is
% sooner.
ttrap(:,1)=datenum(T.DateDeploy_UTC_);
ttrap(:,2)=datenum(T.DateLids_UTC_);
ttrap(:,3)=datenum(T.DateResurface_UTC_);
ttrap(:,2)=min(ttrap(:,2:3),[],2);
ttrap(:,3)=[];

trapTypeNA=T.TrapType_1_NBST_2_STT_;
zTrapNA=T.DepthActual_m_;
castsForTrap=cell(23,1);
 epochNA=T.Epoch;
for i=1:23
    use=find(t>ttrap(i,1) & t<ttrap(i,2));
 castsForTrap{i}=[use, station(use),ship(use)];
end


iz=fix((T.DepthActual_m_)/5 )+ 1;   % indice of uvp to use for closest depth



psdTrapNA=zeros(23,25);  % 23 traps x 25 size bins.

for i=1:23
psdTrapNA(i,:)=nanmean(reshape(psd(iz(i)-3:iz(i),castsForTrap{i}(:, ...
						  1),:),[4*length(castsForTrap{i}(:,1)),25])); 
% average of 20m  (5m bin enclosing the depth and the 3 bins above.
end


pocFluxNA=12*T.POCFlux_mmol_POC_m2_d_ ;  % mgC/m^2/d
pocFluxUncNA=12*T.POCFluxUncertainty; 

units=struct('pocFluxNA','mgC/m^2/d', ...
       'psdTrapNA','#/l/mm','trapTypeNA','1=nbst 2=STT',...
       'psdBinStuff','mm','ztrap','m');

% toss the first couple bins that are empty,
                      % else fitnlm bombs.
psdBinCenter(1:2)=[];
psdBinWidth(1:2)=[];
psdBinEdge(1:2,:)=[];
d=psdBinCenter; 
bw=psdBinWidth;
psdTrapNA(:,1:2)=[];
		       
% dave says not to include STTs in NA epoch 3 	
use=~(trapTypeNA==2 & epochNA==3);
XNA=psdTrapNA(use,:);
yNA=log10(pocFluxNA(use));

% remove the e3 STTS from other data 
pocFluxNA=pocFluxNA(use);
pocFluxUncNA=pocFluxUncNA(use);
psdTrapNA=psdTrapNA(use,:);
castsForTrap=castsForTrap(use);
zTrapNA=zTrapNA(use);
trapTypeNA=trapTypeNA(use);
ttrap=ttrap(use);
epochNA=epochNA(use);


 % fit log(modeledPoc)  log(obs poc)   
 % model is 
logCfluxPSD=@(c,psd,d,bw) log10(nansum(psd.*(c(1).*(d.^c(2)).*bw),2)); 
blah=@(b,X) logCfluxPSD(b,X,d,bw); % make function with only the b X



    
mdlNA=fitnlm(XNA,yNA,blah,[8,2],'Options',opts)
disp('23 bin fit')
disp(sprintf('A=%6.3f A_ci=[%6.3f, %6.3f]\nb=%6.3f b_ci=[%7.3f, %6.3f]',[mdlNA.Coefficients.Estimate mdlNA.coefCI]'))
r2_NA=my_r2(logCfluxPSD(mdlNA.Coefficients.Estimate,XNA,d,bw),yNA);
disp(sprintf('r2=%4.2f\nmy r^2=%4.2f',mdlNA.Rsquared.Ordinary,r2_NA))


% now redo with 8 size bins
%  .25 and 1.5mm
disp('8 bin fit')
use8=find(d>=.25 & d<=1.5);
d8=d(use8);
bw8=bw(use8);
blah8=@(b,X) logCfluxPSD(b,X,d8,bw8); % make function with only the b X

mdlNA8=fitnlm(XNA(:,use8),yNA,blah8,[8,2],'Options',opts)


disp(sprintf('A=%6.3f A_ci=[%6.3f, %6.3f]\nb=%6.3f b_ci=[%7.3f, %6.3f]',[mdlNA8.Coefficients.Estimate mdlNA8.coefCI]'))
r2_NA8=my_r2(logCfluxPSD(mdlNA8.Coefficients.Estimate,XNA(:,use8),d8,bw8),yNA);
disp(sprintf('r2=%4.2f\nmy r^2=%4.2f',mdlNA8.Rsquared.Ordinary,r2_NA8))


% clean up workspace to save
clear where* psd inEddy t station ship HOME DATA CODE r2ec T opts ...
    i use iz
save matchAndFits_NA 

%Iterations terminated: relative norm of the current step is less than OPTIONS.TolX
%
%mdlNA = 
%
%
%Nonlinear regression model:
%    y ~ F(b,X)
%
%Estimated Coefficients:
%          Estimate      SE       tStat       pValue  
%          ________    _______    ______    __________
%
%    b1     12.458      3.9397    3.1622     0.0060391
%    b2     1.4776     0.28692    5.1497    9.6889e-05
%
%
%Number of observations: 18, Error degrees of freedom: 16
%Root Mean Squared Error: 0.221
%R-Squared: 0.671,  Adjusted R-Squared 0.651
%F-statistic vs. constant model: 32.7, p-value = 3.2e-05
%23 bin fit
%A=12.458 A_ci=[ 4.106, 20.810]
%b= 1.478 b_ci=[  0.869,  2.086]
%r2=0.67
%my r^2=0.82
%8 bin fit
%Iterations terminated: relative change in SSE less than OPTIONS.TolFun
%
%mdlNA8 = 
%
%
%Nonlinear regression model:
%    y ~ F(b,X)
%
%Estimated Coefficients:
%          Estimate      SE       tStat     pValue 
%          ________    ______    _______    _______
%
%    b1      13.63     15.833    0.86086    0.40203
%    b2     0.4389     1.3192    0.33271    0.74367
%
%
%Number of observations: 18, Error degrees of freedom: 16
%Root Mean Squared Error: 0.264
%R-Squared: 0.531,  Adjusted R-Squared 0.502
%F-statistic vs. constant model: 18.1, p-value = 0.000604
%A=13.630 A_ci=[-19.934, 47.194]
%b= 0.439 b_ci=[ -2.358,  3.235]
%r2=0.53
%my r^2=0.77
%>> 