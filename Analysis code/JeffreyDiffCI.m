function [CI,pdiff,phat] = JeffreyDiffCI(X,m,Y,n,alpha)

% JEFFREYDIFFCI quasi-Bayesian confidence interval on the difference between proportions
% [C,Diff,P] = JEFFREYDIFFCI(X,m,Y,n,alpha) computes the confidence interval for the
% difference between two proporstions, given scalars:
%       X: number of successes in sample 1
%       m: trials in sample 1
%       Y: number of successes in sample 2
%       n: trials in sample 2
%   alpha: the confidence interval (0.05 = 95%; 0.01 = 99% etc)
%
% Output: 
%       CI: 2-element array giving [L,U] confidence interval for the difference
%     Diff: the estimated difference in proportions
%        P: the estimated probabilties [given the Jeffrey's prior]
% 
% References:
% Brown & Li (2005) Confidence intervals for two sample binomial distribution 
% Journal of Statistical Planning and Inference, 130, 359-375  
%
% 24/11/2017: initial version
% Mark Humphries 

phat(1) = (X + 0.5) / (m+1);
phat(2) = (Y + 0.5) / (n+1);
pdiff = phat(1) - phat(2);
sd1 = phat(1)*(1-phat(1)) / m;
sd2 = phat(2)*(1-phat(2)) / m;


z = norminv(1-alpha/2);  % critical value of Normal distribution at requested alpha

CI(1) = pdiff - z * sqrt(sd1 + sd2);
CI(2) = pdiff + z * sqrt(sd1 + sd2);