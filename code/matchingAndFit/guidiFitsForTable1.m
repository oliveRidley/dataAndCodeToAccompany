function tableOfFits=guidiFitsForTable1()
% the confidence intervals for the coeffs
% correct table1 in Elena document

% the models are 

% 8 band pooled
load('sedTrap/mergedFits.mat', ...
     'mdl*')
results(1,:)=nlfInfo(mdlAll8); % pooled 8

% 23 bands
results(2,:)=nlfInfo(mdlAll);  % pooled 23

load('sedTrap/NP/matchAndFits_NP.mat','mdlNP');
load('sedTrap/NA/matchAndFits_NA.mat','mdlNA');

results(3,:)=nlfInfo(mdlNP); % regional NP
results(4,:)=nlfInfo(mdlNA); % regional NA

% Thorium 
load('Th/fitAll.mat','mdlDeepAll');					
results(5,:)=nlfInfo(mdlDeepAll);  % pooled 
load('Th/NA/fitNA.mat','mdlDeepNA');
load('Th/NP/fitNP.mat','mdlDeepNP');
results(6,:)=nlfInfo(mdlDeepNP); % regional NP
results(7,:)=nlfInfo(mdlDeepNA); % regional NA
disp(results)
tableOfFits=table(results(:,1),results(:,2),results(:,3:4),results(:,5),results(:,6),results(:,7:8),results(:,9),results(:,10),results(:,11),...
		  'VariableNames',{'A','A_unc','A_ci','b','b_unc','b_ci','r2','RMSE','meanBias'},...
		    'RowNames',{'Sed Trap 8band Global','Sed Trap 23band Global','Sed Trap 23band NP',...
		    'Sed Trap 23band NA','234Th 23band Global','234Th 23band NP','234Th 23band NA'});
writetable(tableOfFits,'table1.xlsx','WriteRowNames',true)
return

function resultsOfInterest=nlfInfo(mdl)
Ab=mdl.Coefficients.Estimate;
ci=mdl.coefCI();
unc=ci(:,2)-Ab;
ci=mdl.coefCI();
x=mdl.Fitted;
y=mdl.Variables.y;
bad=find(isinf(mdl.Fitted));
y(bad)=[];
x(bad)=[];
meanBias=mean(mdl.Residuals.Raw); % if I convert this to bias in
                                  % mgC/m^2/d  rather than log
                                  % space, it is pretty much 10.^(1e-12)=1
%meanBias=sign(meanBias)*10.^abs(meanBias);
RMSE=mdl.RMSE;  % for the fit of log(POCflux)  [actual RMSE for POCflux  would
                % be 10^RMSE  so it would be mg/m^2/d]

resultsOfInterest=[reshape([Ab,unc,ci]',1,[]),my_r2(x,y),RMSE,meanBias];
return

%>> guidiFitsForTable1
%
%    Sed Trap 8band Global     15.441    21.529    -6.088    36.969    0.73234     1.5528    -0.82047      2.2851     0.80114    0.23464    -1.6373e-12
%    Sed Trap 23band Global    13.981    5.7847    8.1965    19.766     1.5935    0.44488      1.1486      2.0383     0.82527    0.22431    -1.1892e-12
%    Sed Trap 23band NP        15.384     7.649    7.7351    23.033     1.7187    0.67938      1.0393       2.398    0.038245    0.23192      1.531e-08
%    Sed Trap 23band NA        12.458    8.3518    4.1062     20.81     1.4776    0.60824     0.86931      2.0858     0.81769    0.22107     -2.757e-10
%    234Th 23band Global       19.364    2.8518    16.512    22.216     1.3755     0.1538      1.2217      1.5293     0.55671     0.4469    -6.0956e-11
%    234Th 23band NP            25.81    3.4469    22.363    29.257     1.4529    0.15069      1.3023      1.6036    0.077937    0.38155    -1.3034e-08
%    234Th 23band NA           6.7669    4.2433    2.5236     11.01    0.81871    0.47892      0.3398      1.2976    0.020119    0.49324    -1.7907e-12

%                                  A         unc        A-unc    A+unc      b           unc    b-unc     b+unc      r^2      RMSE      meanBias







