function pocClements=doClements(psd,duvp)

% clements is applied over the range 35um-5mm

% use adrian volume doublings to construct bins to use. 
%
%  find the psd slope from  105um to 5mm  

d0=1e-3 ; 
v0=(pi/6)*d0^3;



vEdges=(2.^(0:44))*v0;

d=(6*vEdges./pi).^(1/3);


dEdges   = [d(1:end-1)' d(2:end)'];  % arrange so each row is the min and max of
                                   % that bin.
				   
d = sqrt(dEdges(:,1) .* dEdges(:,2)); % geomean esd at edges to be
                                      % center diameter

useFit=find(d>=.105 & d<=5);
useGuidi=find(d>=.035 & d<=5);
dc=d(useGuidi);  % call dc sizes used to apply guidi model 

dcf=d(useFit); % dcf the size used to find the slope



% duvp is d(22:end)  d(1:21) are not useable 
% useFit-22 is 0-16. so the first size bin is not contained the UVP
% data we have.  toss is is best I can do ,  dcf(1)=[];
dcf(1)=[];

psd=psd(:,1:16);  
psd(psd==0)=NaN;  % NaN bins with no counts to remove them from the regression



%want to fit  N=Ad^b
% take log of both sides
% log(N)=log(Ad^b)=log(A) + b*log(d)
% log(N)=slope*log(d)+intercept
% slope=b exponent
% intercept = log(A) = 10^intercept

logd=log10(dcf);
logN=log10(psd);
X=[logd ones(size(logd))];

A=zeros(length(logd),1);
b=A;
for i=1:size(logN,1)
  c=regress(logN(i,:)',X);
  A(i)=10^c(2);
  b(i)=c(1);
end


bwc=diff(dEdges(useGuidi,:),1,2);

Nc=A.*(dc').^b;


pocClements=(Nc.*bwc')*18.0*dc.^2.63;

return
