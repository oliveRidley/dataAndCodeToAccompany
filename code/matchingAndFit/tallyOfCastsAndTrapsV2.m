% get casts and numbers of matches that will be useful for tables
% and figures 


% Th matches  (note that the Th casts were done by the Discovery
% (NA) and the Ride (NP) and we compared with uvp from those
% casts- one to one matching
load Th/fitAll.mat NA NP 

% this N* structure contains z,epoch, mdl, and ctd for 234Th casts with
% uvp matches. 



nThNP=zeros(4,1);  % store number of casts that match per epoch and
                   % the 4th will contain the cruise wide result
nThNA=nThNP;
srThCasts=cell(4,1);
dyThCasts=cell(4,1);
% for Th
for i=1:3
  srThCasts{i}=unique(NP.ctdTh(NP.epochTh==i)); %sally ride casts
  dyThCasts{i}=unique(NA.ctdTh(NA.epochTh==i)); % discovery casts
  nThNP(i)=length(srThCasts{i});
  nThNA(i)=length(dyThCasts{i});
end
srThCasts{4}=unique(NP.ctdTh);
dyThCasts{4}=unique(NA.ctdTh);

nThNA(4)=sum(nThNA);
nThNP(4)=sum(nThNP);
[nThNP nThNA]

%Thorium/uvp casts  used
% these are one to one
%       NP    NA
%E1    17     5
%E2    20     8
%E3    18     9
% C    55    22


%%%%%%%%%%%%%%%%%

% for sed traps
load sedTrap/mergedFits.mat epoch* castsUsedN*

% number of traps in each epoch.  For the NP the uvp to match with
% were from Meg, the fall rate of 100m/d was used.  For NA the uvp
% cast within the period the traps were open and within the eddy
% were used. THere were stored in castsUsedN*
nTrapsPerEpochNA=hist(epochNA,[1, 2, 3 ])';
nTrapsPerEpochNP=hist(epochNP,[1, 2, 3 ])';
nTrapsPerEpochNA(4)=sum(nTrapsPerEpochNA); % 4th is total for cruise
nTrapsPerEpochNP(4)=sum(nTrapsPerEpochNP);


% find the unique uvp cast for each epoch and for the cruise
uvpIndInEpochNA={[];[];[];[]};
for i=1:length(epochNA)
 uvpIndInEpochNA{epochNA(i)}= [uvpIndInEpochNA{epochNA(i)};castsUsedNA{i}];
end
uvpIndInEpochNA{4}=[uvpIndInEpochNA{1};uvpIndInEpochNA{2}; ...
		    uvpIndInEpochNA{3}];

uniqueRows=@(x)unique(x,'rows');
uvpIndInEpochNA=cellfun(uniqueRows,uvpIndInEpochNA,'UniformOutput',false);

% tally up the number for each epoch and entire cruise
nCastsNA=zeros(4,1);
nCastsNP=zeros(4,1);
for i=1:3
  nCastsNA(i)=size(uvpIndInEpochNA{i},1);
end
nCastsNA(4)=size(uniqueRows([uvpIndInEpochNA{1};uvpIndInEpochNA{2};uvpIndInEpochNA{3}]),1); %   "

uvpIndInEpochNP={[];[];[];[]};
for i=1:length(epochNP)
  uvpIndInEpochNP{epochNP(i)}= [uvpIndInEpochNP{epochNP(i)};castsUsedNP{i}];
end
uvpIndInEpochNP{4}=[uvpIndInEpochNP{1};uvpIndInEpochNP{2}; ...
		    uvpIndInEpochNP{3}];



uvpIndInEpochNP=cellfun(uniqueRows,uvpIndInEpochNP,'UniformOutput',false);
for i=1:4
  nCastsNP(i)=size(uniqueRows(uvpIndInEpochNP{i}),1);
end



%> [nTrapsPerEpochNP nCastsNP  nTrapsPerEpochNA nCastsNA]
%
%ans =
%
%    11    37     7    17
%    11    34     5    18
%    10    73     6     9

% get casts for the cruise then unique to get the number of casts
% used.   For the NP the value maybe slightly less than the sum for
% each epoch because some small number of casts were in the 100m/d
% source funnel of traps in different epochs.  






[nTrapsPerEpochNP nCastsNP  nTrapsPerEpochNA nCastsNA]



%       NP            NA           
%     traps  uvp   traps uvp    
%E1    11    37     7    17  
%E2    11    34     5    18  
%E3    10    73     6     9      
%C     32   137    18    44
%




clear N* cast* epochN* i ans uniqueRows

save tallys 