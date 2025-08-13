
contact 
Erik Fields fields@eri.ucsb.edu
David Siegel david.siegel@ucsb.edu
Earth Research Institute 
Unversity of California, Santa Barbara
Santa Barbara, CA 93106




SOURCES
The UVP data was provided by 
Lee Karp-Boss  University of Maine  (RRS James Cook)
Andrew McDonnell University of Alaska  (RRS Discovery)
Kiko Rainer GEOMAR Helmholtz Centre for Ocean Research Kiel (R/V Sarmiento de Gamboa)
the data was downloaded from ecoPart https://ecopart.obs-vlfr.fr/ 


DESCRIPTION
 The particle size distribution (psd) profiles from the three ships were merged and ordered by time; before that though, data from the RRS James Cook was adjusted so calibrations casts (close in time and space) better matched the RRS Discovery.  The RRS Discovery was considered to be the "standard" and agreed well with the R/V Sarmiento de Gamboa.  The document UVP_Intercal_Report_072022.pdf describes this intercalibration.

The merged data is in matlab and netcdf formats.  The profiles were standardized to 500m (padded with NaNs, if the maximum depth was less than 500m,  truncated if deeper).


The relative error in the psd and the biovolume are also included.  each cast has associated location (time, lat, lon) and info to specify the ship, cast number, and estimated distance to the eddy center.


Netcdf format
ncdump -h mergedIntercalibratedTo500m.nc
netcdf mergedIntercalibratedTo500m {
dimensions:
	depth = 101 ;
	time = 173 ;
	size = 25 ;
	binEdges = 2 ;
variables:
	double t(time) ;
		t:_FillValue = -1. ;
		t:Description = "time" ;
		t:Units = "d (01-Jan-0000 00:00 assigned 1, matlab serial time)" ;
	double lat(time) ;
		lat:Description = "Latitude" ;
		lat:Units = "degree North" ;
	double lon(time) ;
		lon:Description = "Longitude" ;
		lon:Units = "degree East" ;
	byte ship(time) ;
		ship:Description = "ship" ;
		ship:Units = "1=Sarimiento de Gamboa, 2=Discovery 3= James Cook" ;
	double r2ec(time) ;
		r2ec:Description = "radius to eddy center" ;
		r2ec:Units = "km" ;
	byte cast(time) ;
		cast:Description = "cast number (for ship)" ;
	double psd(time, size, depth) ;
		psd:Description = "particle size distribution" ;
		psd:Units = "#/l/mm" ;
	double psd_relunc(time, size, depth) ;
		psd_relunc:Description = "particle size distribution relative uncertainty" ;
		psd_relunc:Units = "" ;
	double bv(time, size, depth) ;
		bv:Description = "particle volume distribution" ;
		bv:Units = "ppmV/mm" ;
	double z(depth) ;
		z:Description = "depth" ;
		z:Units = "m" ;
	double psdBinCenter(size) ;
		psdBinCenter:Description = "size class esd" ;
		psdBinCenter:Units = "mm" ;
	double psdBinEdge(binEdges, size) ;
		psdBinEdge:Description = "size class boundaries" ;
		psdBinEdge:Units = "mm" ;
	double psdBinWidth(size) ;
		psdBinWidth:Description = "size class width" ;
		psdBinWidth:Units = "mm" ;
}




Matlab format

>> load mergedIntercalibratedTo500m
>> whos
  Name              Size                  Bytes  Class     Attributes

  binInfo           1x1                    2276  struct              
  bv              101x25x173            3494600  double              
  castLabel       173x1                   19744  cell                
  lat             173x1                    1384  double              
  lon             173x1                    1384  double              
  psd             101x25x173            3494600  double              
  psd_relunc      101x25x173            3494600  double              
  r2ec            173x1                    1384  double              
  ship            173x1                    1384  double              
  shipStr           1x3                     326  cell                
  station         173x1                    1384  double              
  t               173x1                    1384  double              
  units             1x1                     900  struct              
  z               101x1                     808  double              

>> binInfo

binInfo = 

  struct with fields:

       bin_edges_vol: [25×2 double]
      bin_edges_diam: [25×2 double]
    bin_centers_diam: [0.0905 0.1140 0.1437 0.1810 0.2281 0.2874 0.3620 0.4561 0.5747 0.7241 0.9123 1.1494 1.4482 1.8246 … ] (1×25 double)
          bin_widths: [0.0210 0.0264 0.0333 0.0419 0.0528 0.0665 0.0838 0.1056 0.1331 0.1677 0.2113 0.2662 0.3353 0.4225 … ] (1×25 double)
              n_bins: 25
               units: 'length is mm,  volume is  mm^3'

>> units

units = 

  struct with fields:
            bv: 'ppmV/mm'
           psd: '#/l/mm'
    psd_relunc: ''
          r2ec: 'km'
             t: 'day UTC (01-Jan-0000 = 1)'
             z: 'm'

  psd is the particle size distribution or abundance with units of #/l/mm

binInfo is structure containing info about the size classes, size bins, 
  bin_edges_diam contains the edges of the size bins in millimeters
  bin_edges_vol  is the equivalent volumes  (pi/6)*(bin_edges_diam).^3
  bin_widths is the width of the size class in millimeters
               bin_edges_diam(:,2)-bin_edges_diam(:,1)
  bin_centers_diam is the center of the size class in mm, it is the geometric
               mean of edges  geomean(bin_edges_diam,2)


psd_relunc is the relative uncertainty (fractional 0-1).  
  psd_relunc is 1/sqrt(Nparticles)=1/sqrt(psd*psdBinWidth*sampleVolume)
  as in 1/sqrt(psd(#/l/mm)*psdBinWidth(mm)*sampleVolume(l)))
  from https://github.com/britairving/UVP_plots_basic/blob/master/UVP_calculate_PAR_fields.m
  variable "ship" contains a key for which ship.  1=sdg 2=dy 3=jc
  shipStr is the ship as a string. 
  station is the cast number for a ship.  station(ship==3) would be the Cook stations  station(ship==1) the Sarmiento. 

 castLabels is string label with ship and station, like 'dy058','jc023', ...
     'sdg010'

z (m) is the depth.  The uvp is 5m binned.

t is the time in days with 01-Jan-0000 00:00 assigned 1. 2021-May-04 00:00 would be 738280

bv is the biovolume (ppmV/mm)


r2ec is the distance (km) from the estimated eddy center.  casts were considered "in" the eddy, if r2ec<15

