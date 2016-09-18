function [pOpt xplt yplt] = fitSAT(RT,success)
% max likelihood estimation of speed-accuracy tradeoff. Assumes cumulative
% Gaussian shape
%
%   pOpt = fitSAT(RT,success)
%       pOpt = [mu sigma];

% initial parameters
    sigma = .1;
    mu = .3;
    asymptErr = .9;

% eliminate any NaNs
igood = find(~isnan(RT) & ~isnan(success));
RT = RT(igood);
success = success(igood);
% likelihood function:
LL = @(params) -sum(success.*log((1/8+asymptErr*normcdf(RT,params(1),params(2))*7/8)) + (1-success).*log(1-(1/8+asymptErr*normcdf(RT,params(1),params(2))*7/8)));

xplt = [0:.001:1];

pOpt = fminsearch(LL,[mu sigma]);
yplt = normcdf(xplt,pOpt(1),pOpt(2));


