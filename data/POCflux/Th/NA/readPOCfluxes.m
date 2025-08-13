
% read in NSS POC flux
% provided 3/9/23 in an email from Sam Clevenger 
% subject Re: Carbon Flux from Eddy Center
blah_inEddy=readtable('POCFluxes.xlsx','sheet','EC');
blah_outEddy=readtable('POCFluxes.xlsx','sheet','NEC');

pocFlux.inEddy=logical([ones(size(blah_inEddy,1),1);zeros(size(blah_outEddy,1),1)]);

pocFlux.flux=12*[blah_inEddy.POCFlux_mmol_m2_d_; ...
	blah_outEddy.POCFlux_mmol_m2_d_];

pocFlux.fluxErr=12*[blah_inEddy.Error; ...
	blah_outEddy.Error];

pocFlux.time=[blah_inEddy.Date_Time;blah_outEddy.Date_Time];
pocFlux.z=[blah_inEddy.Depth;blah_outEddy.Depth];
pocFlux.cast=[blah_inEddy.Cast_;blah_outEddy.Cast_];

% get epoch
% using cruiseMetricsDefinitionsAug22_2022.pdf
%https://drive.google.com/drive/folders/1vqayshuAcl3K241hkvmV1XV1cBhBEKHi
% I am assuming the "broad definition" is the one.
%1    May 4-10 
%2       11-20
%3       21 29
pocFlux.epoch=discretize(day(pocFlux.time),[4 11 21 30]);
%The jth bin contains element X(i) if edges(j) <= X(i) < edges(j+1)
%for 1 <= j < N, where N is the number of bins and length(edges) =
%N+1. The last bin contains both edges such that edges(N) <= X(i)
%<= edges(N+1).

save pocFluxFromNssTh pocFlux