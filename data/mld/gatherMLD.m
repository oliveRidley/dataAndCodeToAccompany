function [mldNA,mldNP]=gatherMLD()
% add mean mld
% to not waste a lot of time, I am just using the process ship
% mld ONLY.  get mean of cruise and  epochs for A and P


%>> MLD_all(2).platform_id
%
%ans =
%
%    'RR_SIO = 2'

load('/home/oceancolor-fields/projects/guidiForCeballos/Th/NP_redo23band/MLD_all')
tWo=find(MLD_all(1).platform==2); 
t_mldNP=MLD_all(1).datenum(tWo);

% email 2019-12-03 from DV Re: official epoch times
%Epoch 1 = datenum(2018,8,14,0) to datenum(2018,8,23,9) 
%Epoch 2 = datenum(2018,8,23,9) to datenum(2018,8,31,9)  
%Epoch 3 = datenum(2018,8,31,9) to datenum(2018,9,9,18)  

epochEdges=datenum(...
[2018,8,14,0,0,0;...
2018,8,23,9,0,0;...
2018,8,31,9,0,0;...
2018,9,9,18,0,0]);
eNP=discretize(t_mldNP,epochEdges);
mldNP=MLD_all(1).MLD(tWo);

mldNP=struct('cruise',nanmean(mldNP),'epoch',[nanmean(mldNP(eNP==1)),nanmean(mldNP(eNP==2)),nanmean(mldNP(eNP==3))]);
load('/home/oceancolor-fields/projects/guidiForCeballos/Th/NA_redowithNssPOC_20230316/MLD_DY.mat','MLD_DY','time_DY131');

eNA=discretize(time_DY131,datenum(2021,5,[4,11,21,30]));
mldNA=struct('cruise',nanmean(MLD_DY),'epoch',[nanmean(MLD_DY(eNA==1)),nanmean(MLD_DY(eNA==2)),nanmean(MLD_DY(eNA==3))]);
%clear time_DY131 t_mldNP MLD* tWo epochEdges eNA eNP
return