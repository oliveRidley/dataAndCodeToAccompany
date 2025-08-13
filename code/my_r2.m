function r2=my_r2(y,yhat)
% function r2=my_r2(y,yhat)
% 
% calculates r^2 for two time series.
% y and yhat may be matrices such that
% r^2(i)=my_r2(y(:,i),yhat(:,i))
%

n=size(y,1);
ybar=mean(y);
yhatbar=mean(yhat);
dyhat=yhat-yhatbar(ones(n,1),:);
dy=y-ybar(ones(n,1),:);

r2=(sum(dyhat.*dy).^2)./(sum(dyhat.^2).*sum(dy.^2));
return
