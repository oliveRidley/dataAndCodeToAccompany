load('NA/fitNA.mat','XNA','yNA')
load('NP/fitNP.mat','XNP','yNP','logCfluxPSD','blah','d','bw');
NA=load('NA/fitNA.mat','zTh','epochTh','mldTh','ctdTh')
NP=load('NP/fitNP.mat','zTh','epochTh','mldTh','ctdTh')

opts=statset('Display','final','DerivStep',eps^(1/3),'TolFun',1e-13);
Xall=[XNA;XNP];
yAll=[yNA;yNP];
mdlDeepAll=fitnlm(Xall,yAll,blah,[8,2],'Options',opts)

disp('23 bin fit')
disp(sprintf('A=%6.3f A_ci=[%6.3f, %6.3f]\nb=%6.3f b_ci=[%7.3f, %6.3f]',[mdlDeepAll.Coefficients.Estimate mdlDeepAll.coefCI]'))
r2_DeepAll=my_r2(logCfluxPSD(mdlDeepAll.Coefficients.Estimate,Xall,d,bw),yAll);
disp(sprintf('r2=%4.2f\nmy r^2=%4.2f',mdlDeepAll.Rsquared.Ordinary,r2_DeepAll))

%
%
%>> doMergedFitTh
%Iterations terminated: relative norm of the current step is less than OPTIONS.TolX
%
%mdlDeepAll = 
%
%
%Nonlinear regression model:
%    y ~ F(b,X)
%
%Estimated Coefficients:
%          Estimate       SE       tStat       pValue  
%          ________    ________    ______    __________
%
%    b1     19.364        1.453    13.327    5.5309e-37
%    b2     1.3755     0.078363    17.553    3.2345e-59
%
%
%Number of observations: 865, Error degrees of freedom: 863
%Root Mean Squared Error: 0.447
%R-Squared: 0.164,  Adjusted R-Squared 0.163
%F-statistic vs. constant model: 169, p-value = 1.94e-35
%23 bin fit
%A=19.364 A_ci=[16.512, 22.216]
%b= 1.376 b_ci=[  1.222,  1.529]
%r2=0.16
%my r^2=0.56

save fitAll  Xall yAll blah logCfluxPSD mdlDeepAll r2_DeepAll d bw ...
    NA NP
