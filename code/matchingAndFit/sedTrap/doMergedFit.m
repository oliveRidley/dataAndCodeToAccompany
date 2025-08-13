load('NP/matchAndFits_NP.mat','XNP','yNP','logCfluxPSD','blah', ...
     'blah8','d','d8','bw*','use8','zTrapNP','epochNP','castsUsedNP');
load('NA/matchAndFits_NA.mat','XNA','yNA','zTrapNA','epochNA', ...
     'castsForTrap')
castsUsedNA=castsForTrap;
opts=statset('Display','final','DerivStep',eps^(1/3),'TolFun',1e-13);

% merge NA and NP then fit
Xall=[XNA;XNP];
yAll=[yNA;yNP];
mdlAll=fitnlm(Xall,yAll,blah,[8,2],'Options',opts)

disp('23 bin fit')
disp(sprintf('A=%6.3f A_ci=[%6.3f, %6.3f]\nb=%6.3f b_ci=[%7.3f, %6.3f]',[mdlAll.Coefficients.Estimate mdlAll.coefCI]'))
r2_All=my_r2(logCfluxPSD(mdlAll.Coefficients.Estimate,Xall,d,bw),yAll);
disp(sprintf('r2=%4.2f\nmy r^2=%4.2f',mdlAll.Rsquared.Ordinary,r2_All))



% repeat with 8bin 
mdlAll8=fitnlm(Xall(:,use8),yAll,blah8,[8,2],'Options',opts)
disp('8 bin fit')
disp(sprintf('A=%6.3f A_ci=[%6.3f, %6.3f]\nb=%6.3f b_ci=[%7.3f, %6.3f]',[mdlAll8.Coefficients.Estimate mdlAll8.coefCI]'))
r2_All8=my_r2(logCfluxPSD(mdlAll8.Coefficients.Estimate,Xall(:,use8),d8,bw8),yAll);
disp(sprintf('r2=%4.2f\nmy r^2=%4.2f',mdlAll8.Rsquared.Ordinary,r2_All8))






save mergedFits mdlAll* d d8 bw* logCfluxPSD blah* r2_All* use8 yAll* ...
    Xall epoch* zTrap* cast*
%
%
%>> doMergedFit
%Iterations terminated: relative norm of the current step is less than OPTIONS.TolX
%
%mdlAll = 
%
%
%Nonlinear regression model:
%    y ~ F(b,X)
%
%Estimated Coefficients:
%          Estimate      SE       tStat       pValue  
%          ________    _______    ______    __________
%
%    b1     13.981      2.8771    4.8595    1.2985e-05
%    b2     1.5935     0.22127    7.2016    3.6114e-09
%
%
%Number of observations: 50, Error degrees of freedom: 48
%Root Mean Squared Error: 0.224
%R-Squared: 0.81,  Adjusted R-Squared 0.806
%F-statistic vs. constant model: 205, p-value = 6.15e-19
%23 bin fit
%A=13.981 A_ci=[ 8.197, 19.766]
%b= 1.593 b_ci=[  1.149,  2.038]
%r2=0.81
%my r^2=0.83
%Iterations terminated: relative norm of the current step is less than OPTIONS.TolX
%
%mdlAll8 = 
%
%
%Nonlinear regression model:
%    y ~ F(b,X)
%
%Estimated Coefficients:
%          Estimate      SE       tStat     pValue 
%          ________    ______    _______    _______
%
%    b1     15.441     10.707     1.4421    0.15578
%    b2    0.73234     0.7723    0.94826    0.34775
%
%
%Number of observations: 50, Error degrees of freedom: 48
%Root Mean Squared Error: 0.235
%R-Squared: 0.792,  Adjusted R-Squared 0.788
%F-statistic vs. constant model: 183, p-value = 5.4e-18
%8 bin fit
%A=15.441 A_ci=[-6.088, 36.969]
%b= 0.732 b_ci=[ -0.820,  2.285]
%r2=0.79
%my r^2=0.80
%>> 
%