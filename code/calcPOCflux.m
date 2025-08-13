function pocFlux= calcPOCflux(nlModel,d,bw,psd)
% given a nlmodel and matching psd
% here matching means the same 22 bands 
% assumes a psd(depth, band, time) format

psd=movmean(psd,[3 0],'omitnan');

A=nlModel.Coefficients.Estimate(1);
b=nlModel.Coefficients.Estimate(2);
    % psd*(bw * A*d^b)   % using implicit expansion
    % psd*blah(:)

blah=((A.*bw).*(d.^b))';

ncasts=size(psd,3);
ndepths=size(psd,1);
pocFlux=zeros(ndepths,ncasts);



for i=1:ncasts
pocFlux(:,i)=psd(:,:,i)*blah;
end

return


