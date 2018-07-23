function CI = JeffreyCI(N,s,alpha)

% JEFFREYCI Jeffrey's CI for binomial proportions
% C = JEFFREYCI(N,S,ALPHA) computes the Jeffrey's CI given the number of
% trials N, the number of successes S, and the specified ALPHA level (e.g.
% 0.01 for a 99% CI); specifying ALPHA as an N-length array returns a Nx2
% array of CIs.
%
% 12/12/2017
% Mark Humphries

% Jeffrey priors
a_0 = 0.5;
b_0 = 0.5;

% update parameters
a = s + a_0;
b = N - s + b_0;

% specify CI
prctiles = sort([alpha/2,1-alpha/2]);

CI = betainv(prctiles,a,b);


