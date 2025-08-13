% match_trap_ctd500.mat is "RR" ordered 
% I don't see RR index in the trap_fluxes_share_wswimmercorr.xlsx
% so match trap type, epoch, nominal depth to make sure fluxes
% match match_trap_ctd500.mat order
%
% match_trap_ctd_500.mat and trap_fluxes_wswimmerscorr.xlsx are
% both from Meg Estapa.

ws=100
infile=sprintf('match_trap_ctd_%3d.mat',ws)
load(infile)
trapFlux=readtable('trap_fluxes_share_wswimmercorr.xlsx','sheet', ...
		   'mean');
trapStr={'NBST','STT'};	
trapType=trapFlux.TrapType_1_NBST_2_STT_; % 1=nbst


trapId=zeros(32,1);
for i=1:32
  trapId(i)=sscanf(trapFlux.Platform{i},[trapStr{trapType(i)},'%d'])
end

znom=trapFlux.DepthNominal_m_;
z=trapFlux.DepthActual_m_;
epoch=trapFlux.Epoch;

matchTrap=[[match_trap_ctd.epoch]',[match_trap_ctd.trapdepth]', ...
	   [match_trap_ctd.trapid]',[match_trap_ctd.traptype]'];

[LIA,LOCB] = ismember(matchTrap,[epoch,znom,trapId,trapType], 'rows');

trapFlux=trapFlux(LOCB,:);
ztrapFluxActual=z(LOCB);
ztrapNom=znom(LOCB);
outfile= ['trapFluxSortedToRRindex_',infile];
save(outfile, 'trapFlux','ztrapFluxActual', 'match_trap_ctd',  'ztrapNom')