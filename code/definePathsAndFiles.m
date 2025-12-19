HOME='/Volumes/fields/oceancolor-fields/projects/guidiForCeballos/gitHubVersion/dataAndCodeToAccompanyPaper/';
CODE=[HOME,'code/'];
DATA=[HOME,'data/'];

%define a set of matchup files for
% 234Th from Sam Clevenger
wherePOCflux=struct('Th','','sedTrap','') ;
wherePOCflux.Th.NA=[DATA,'POCflux/Th/NA/pocFluxFromNssTh.mat'];
wherePOCflux.Th.NP=[DATA,'POCflux/Th/NP/Tables for ms v6 modified for UVP Aug 2022.xlsx'];

% sed trap from Meg Estapa

wherePOCflux.sedTrap.NA=[DATA,'POCflux/sedTrap/NA/NAtl_trap_fluxes_share_V2.xlsx'];
wherePOCflux.sedTrap.NP=[DATA,'POCflux/sedTrap/NP/trapFluxSortedToRRindex_match_trap_ctd_100.mat'];
% Note trapFluxSortedToRRindex_match_trap_ctd_100.mat was made from
% trap_fluxes_share_wswimmercorr.xlsx and match_trap_ctd_100.mat
% using script reorderTrapFlux20231228.m

% location of intercalibrated UVP data
whereUVP.NA=[DATA,'UVP/NA/mergedIntercalibratedTo500m.mat'];
whereUVP.NP=[DATA,'UVP/NP/mergedNP_uvp_adjustedAndBiasCorr.mat'];


whereMld.NA=[DATA,'mld/NA/MLD_DY.mat'];
whereMld.NP=[DATA,'mld/NP/MLD_all.mat'];