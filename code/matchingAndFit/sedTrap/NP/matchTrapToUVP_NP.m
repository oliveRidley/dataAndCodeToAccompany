
opts=statset('Display','final','DerivStep',eps^(1/3),'TolFun',1e-13);
addpath ../../../
definePathsAndFiles
load(whereUVP.NP,'psd','isRide','binInfo','station');

% toss the first two sizes from the get go.  
psdBinCenter=binInfo.bin_centers_diam(3:end);
psdBinEdge=binInfo.bin_edges_diam(3:end,:);
psdBinWidth=diff(psdBinEdge,1,2)';
psd=permute(psd(:,3:end,:),[1 3 2]); % tweak things to be like the previous
                          % uvp file with psd(depth,cast,size)
shipStationFromUVP=[isRide+1,station];
load(wherePOCflux.sedTrap.NP);




%>> notes=m.match_trap_ctd_notes
%
%notes =
%
%  7×1 cell array
%
%    {'CTD casts that intersect 100 m/d source funnels of each trap at some point during the trap deployment'}
%    {'See Estapa et al. (2021) appendix for source funnel details'                                          }
%    {'traptype 1=NBST, 2=STT'                                                                               }
%    {'trapid is either NBST serial no or STT order (1,2,3,4,5)'                                             }
%    {'CTD table columns: 1=ship (1=RR,2=SR), 2=castno, 3=castdn, 4:5=castpos'                               }
%    {'Cast matches are for standard (SIO) rosettes only'                                                    }
%    {'Table is sorted by trap team internal "RR" index'                                                     }

castsUsedNP=cell(32,1);


% we have the matching casts for each of the 32 traps.

%trap type = match_trap_ctd(itrap).traptype; 1=nbst


iz=fix(ztrapFluxActual/5)+1;
iz(iz>101)=101;   % this is a fudge because deep traps were below 500m


psdTrapNP=NaN(32,23);

for itrap=1:32
  use=find(ismember(shipStationFromUVP,match_trap_ctd(itrap).CTDtable(:,1:2),'rows'));

   psdTrapNP(itrap,:)=nanmean(reshape(psd((iz(itrap)-3):iz(itrap),use,:),[4*length(use),23]));
castsUsedNP{itrap}=[use,shipStationFromUVP(use,:)];

end
pocFluxNP=12*trapFlux.Swimmer_correctedPOCFlux_mmol_C_m2_d_ ;  % mgC/m^2/d
pocFluxUncNP=12*trapFlux.Uncertainty;

% if no matching psd, toss
toss=find(sum(isnan(psdTrapNP'))==23);
psdTrapNP(toss,:)=[];
pocFluxNP(toss)=[];
pocFluxUncNP(toss)=[];
castsUsedNP(toss)=[];
epochNP=[match_trap_ctd.epoch]';
epochNP(toss)=[];


zTrapNP=ztrapFluxActual;
trapTypeNP=[match_trap_ctd(:).traptype];
zTrapNP(toss)=[];
trapTypeNP(toss)=[];


units=struct('pocFluxNP','mgC/m^2/d', ...
       'psdTrapNP','#/l/mm','trapTypeNP','1=nbst 2=STT',...
       'psdBinStuff','mm','ztrapNP','m');
d=psdBinCenter; 
bw=psdBinWidth;

		       
		       

XNP=psdTrapNP;
yNP=log10(pocFluxNP);


% fit log(modeledPoc)  log(obs poc)   
 % model is 
logCfluxPSD=@(c,psd,d,bw) log10(nansum(psd.*(c(1).*(d.^c(2)).*bw),2)); 
blah=@(b,X) logCfluxPSD(b,X,d,bw); % make function with only the b X
mdlNP=fitnlm(XNP,yNP,blah,[8,2],'Options',opts)
disp('23 bin fit')
disp(sprintf('A=%6.3f A_ci=[%6.3f, %6.3f]\nb=%6.3f b_ci=[%7.3f, %6.3f]',[mdlNP.Coefficients.Estimate mdlNP.coefCI]'))
r2_NP=my_r2(logCfluxPSD(mdlNP.Coefficients.Estimate,XNP,d,bw),yNP);
disp(sprintf('r2=%4.2f\nmy r^2=%4.2f',mdlNP.Rsquared.Ordinary,r2_NP))



% want to use just the sizes between .25 and 1.5mm
disp('8 bin fit')
use8=find(d>=.25 & d<=1.5);
d8=d(use8);
bw8=bw(use8);
blah8=@(b,X) logCfluxPSD(b,X,d8,bw8); % make function with only the b X

mdlNP8=fitnlm(XNP(:,use8),yNP,blah8,[8,2],'Options',opts)

disp(sprintf('A=%6.3f A_ci=[%6.3f, %6.3f]\nb=%6.3f b_ci=[%7.3f, %6.3f]',[mdlNP8.Coefficients.Estimate mdlNP8.coefCI]'))
r2_NP8=my_r2(logCfluxPSD(mdlNP8.Coefficients.Estimate,XNP(:,use8),d8,bw8),yNP);
disp(sprintf('r2=%4.2f\nmy r^2=%4.2f',mdlNP8.Rsquared.Ordinary,r2_NP8))


clear where* psd  toss shipStationFromUVP station isRide HOME DATA ...
    CODE re2ec T opts i use itrap ans 
save matchAndFits_NP 


%Iterations terminated: relative norm of the current step is less than OPTIONS.TolX
%
%mdlNP = 
%
%
%Nonlinear regression model:
%    y ~ F(b,X)
%
%Estimated Coefficients:
%          Estimate      SE       tStat       pValue  
%          ________    _______    ______    __________
%
%    b1     15.384      3.7454    4.1075    0.00028393
%    b2     1.7187     0.33266    5.1664    1.4559e-05
%
%
%Number of observations: 32, Error degrees of freedom: 30
%Root Mean Squared Error: 0.232
%R-Squared: -0.128,  Adjusted R-Squared -0.166
%F-statistic vs. constant model: 0, p-value = 1
%23 bin fit
%A=15.384 A_ci=[ 7.735, 23.033]
%b= 1.719 b_ci=[  1.039,  2.398]
%r2=-0.13
%my r^2=0.04
%8 bin fit
%Iterations terminated: relative change in SSE less than OPTIONS.TolFun
%
%mdlNP8 = 
%
%
%Nonlinear regression model:
%    y ~ F(b,X)
%
%Estimated Coefficients:
%          Estimate      SE       tStat      pValue 
%          ________    ______    ________    _______
%
%    b1      3.0241    16.014     0.18885    0.85149
%    b2    -0.79549      4.87    -0.16335    0.87134
%
%
%Number of observations: 32, Error degrees of freedom: 30
%Root Mean Squared Error: 0.216
%R-Squared: 0.0185,  Adjusted R-Squared -0.0142
%F-statistic vs. constant model: 0.566, p-value = 0.458
%A= 3.024 A_ci=[-29.680, 35.728]
%b=-0.795 b_ci=[-10.741,  9.150]
%r2=0.02
%my r^2=0.09
%>> 