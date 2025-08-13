function [psd,psd_relunc,z,binInfo,t,lat,lon ctdStationNum]=readUVP(file,stationString)
%function [psd,psd_relunc,z,binInfo,t,lat,lon ctdStationNum]=readUVP(file,stationString)
% 
% read a odv format uvp5 file
%
% this makes a lot of assumptions.  Assumes odv format.
% assumes station is some fixed string followed by three digits
% like 'ctd001' or 'exports068' .  This grabs LPM_* fields and
% tosses first 19 and last (sizes >26mm).  The first 19 are
% smaller than the camera can resolve. 

% to set things up sizewise, start with 1um diameter particle size,
% compute the volume, double 44 times. these are the size bins. the
% function SetUpLogVolBins does that simple calculation

monomer_diam=1e-3; % diameter in mm 
n_bins=44;  %number of volume doubles
nreturn=25; %number of uvp bins to return (first 19 are empty).
binInfo=SetUpLogVolBins(monomer_diam,n_bins,nreturn);

T=readtable(file);  % read wad in as a table
f=fields(T); % fields of table T

% want t,lat lon, depth, sampled volume, LPM, station
lat=T.(f{find(contains(f,'Lat'))});
startCast=find(~isnan(lat));  % the lat,lon,time,station are only
                              % written once, at the start of a cast.
endCast=[startCast(2:end)-1; length(lat)];			      
lat=lat(startCast);
lon=T.(f{find(contains(f,'Lon'))})(startCast);
t=datenum(T.(f{find(contains(f,'yyyy_mm_ddHh_mm'))})(startCast));
depth=T.(f{find(contains(f,'Depth'))});
sampleVolume=T.(f{find(contains(f,'SampledVolume'))}); % units of
                                                       % liters
						       
nStation=length(startCast); % number of stations/casts
station=T.(f{find(contains(f,'Station'))})(startCast); % string


% snarf out the fields with LPM_* large particle material, i think. #/l
iLPM=find(contains(f,'LPM_'));
iLPM=iLPM(20:44); % only want the 25 largest, ignore the 19 empty bins
LPM=table2array(T(:,iLPM));
countingError=1./sqrt(LPM.*sampleVolume); %(particleConc*sampledVolume)^(-1/2)

%preallocate arrays
ctdStationNum=zeros(nStation,1);
z=cell(nStation,1);psd=z;psd_relunc=z;

for i=1:nStation;
  % assumes 3 digits  like exports001 or ctd123 naames020
ctdStationNum(i)=sscanf(station{i}(end-2:end),'%03d');  
psd{i}=LPM(startCast(i):endCast(i),:)./binInfo.bin_widths;
psd_relunc{i}=countingError(startCast(i):endCast(i),:);
z{i}=depth(startCast(i):endCast(i));
end


function bins = SetUpLogVolBins(monomer_diam, n_bins,nreturn)
%
% Sets up logarithmic size bins based on a doubling of conserved particle
% volume.  Adrian Burd wrote this and I tweaked it to only return
% the useful bins.
%

monomer_vol  = (pi/6) * monomer_diam^3;  % Monomer volume
particle_vol = monomer_vol * 2.^(0:n_bins)';

bins.bin_edges_vol    = [particle_vol(1:end-1) particle_vol(2:end)];
bins.bin_edges_diam   = ( 6 * bins.bin_edges_vol / (pi)) .^ (1/3);
bins.bin_centers_diam = geomean( bins.bin_edges_diam, 2 )';
bins.bin_widths       = diff( bins.bin_edges_diam, 1, 2 )';
bins.n_bins           = length( bins.bin_centers_diam );
bins=blankBins(bins,n_bins-nreturn);  % toss out first 19 bins
return % End of function SetUpConservedVolBins 

function bins=blankBins(bins,nfewer)
bins.bin_edges_vol(1:nfewer,:)=[];
bins.bin_edges_diam(1:nfewer,:)=[];
bins.bin_centers_diam(1:nfewer)=[];
bins.bin_widths(1:nfewer)=[];
bins.n_bins=bins.n_bins-nfewer;
return

