% 2024-01-09  add the station and ship to the castsForTrap cell
%  this will be useful for figures DV is currently asking for.
%
% 20231227 after fucking zoom meeting 2023-12-15 
%  things I want to look into-
% using old vs new uvp processing (new is easier to share the code
% for)
% use resurface vs lids or minimum of the two.
%
% use fitnlm instead of fminschbnd because there is a confidence
% interval.  Worked with NA all, but need to apply it to more sets.
% 
% STT and NBST can be merged or at least their symbols can be the
% same in the plots.
%%%%%%%%%%%%%%%%




% redo after final uvp intercalibration 2022-08-09
%
% trap data from
%North Atlantic 2021 Shared Data > Sediment Trap Bulk Fluxes
%
% NAtl_trap_fluxes_share_V2.xlsx
%
%link 
%https://docs.google.com/spreadsheets/d/1bHVUdK1vLOzatvk0eH3gHNC0XlyJd5Ln/edit?usp=sharing&ouid=112192141700358136624&rtpof=true&sd=true
% enclosing folder with readme
% https://drive.google.com/drive/folders/1syoR3OFiPYWEEHLRwDSsDvE3lQn1vqrD?usp=sharing



T=readtable('../NA/NAtl_trap_fluxes_share_V2.xlsx','Sheet','mean');


% interested in  DepthActual_m DateDeploy_UTC DateResurface_UTC to find uvp cast matches.
OLD=false;

if OLD
load('../NA/mergedUVPto500m_inEddy.mat','psd','t','psdBin*','station','ship')
else
  load('/home/oceancolor-fields/projects/exportsUVP/NA/exportsNAuvp_testAdjust.mat','r2ec','psd','t','binInfo','r2ec','station','ship')
 psdBinCenter=binInfo.bin_centers_diam;
 psdBinWidth=binInfo.bin_widths;
 psdBinEdge=binInfo.bin_edges_diam;
 inEddy=find(r2ec<=15)
 psd=psd(:,:,inEddy);
 station=station(inEddy);
 ship=ship(inEddy);
 t=t(inEddy);
 psd=permute(psd,[1 3 2]);
end	
psd(:,:,1:2)=NaN; % JC doesn't have these sizes, so blank it for all.

%
%Use the closest 5m bin. or 20m above it?
% below I used 4 bins above, so 20m

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



psdTrapNA=zeros(23,25);

for i=1:23
psdTrapNA(i,:)=nanmean(reshape(psd(iz(i)-3:iz(i),castsForTrap{i}(:,1),:),[4*length(castsForTrap{i}(:,1)),25]));

end

pocFluxNA=12*T.POCFlux_mmol_POC_m2_d_ ;  % mgC/m^2/d
pocFluxUncNA=12*T.POCFluxUncertainty; 

units=struct('pocFluxNA','mgC/m^2/d', ...
       'psdTrapNA','#/l/mm','trapTypeNA','1=nbst 2=STT',...
       'psdBinStuff','mm','ztrap','m')
if OLD
save matchResultsNA_old  *NA psdBin* units castsForTrap ttrap OLD
else
save matchResultsNA_new  *NA psdBin* units castsForTrap ttrap OLD
end

d=psdBinCenter; 
bw=psdBinWidth;
bw(1:2)=[]; d(1:2)=[]; % toss the firt couple bins that are empty,
                       % else fitnlm bombs.
		       
		       
% dave says not to include STTs in NA epoch 3	
use=~(trapTypeNA==2 & epochNA==3)
X=psdTrapNA(use,3:end);
y=log10(pocFluxNA(use));
 
 % fit log(modeledPoc)  log(obs poc)   
 % model is 
logCfluxPSD=@(c,psd,d,bw) log10(nansum(psd.*(c(1).*(d.^c(2)).*bw),2)); 
blah=@(b,X) logCfluxPSD(b,X,d,bw); % make function with only the b X


    
mdl=fitnlm(X,y,blah,[8,2],'Options',...
statset('Display','iter','DerivStep',eps^(1/3),'TolFun',1e-13))


[mdl.Coefficients.Estimate mdl.coefCI]
mdl.Rsquared.Ordinary
% old
%    12.4303    4.0736   20.7870
%    1.4763    0.8660    2.0865
% 0.6708
% new 
%   12.4580    4.1062   20.8098
%    1.4776    0.8693    2.0858
% 0.6711
