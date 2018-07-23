function jspks = jitterspikes(spks,jittersize,T)

% JITTERSPIKES adds Gaussian timing jitter to spike-trains
% J = JITTERSPIKES(S,W,T) jitters the set of spike-times in 1D array S (in s)
% by sampling a time-shift for each spike from a Gaussian of mean zero and
% standard deviation W (in s). If jittered spikes fall outside the lower or
% upper time bounds T=[L U] (in s) then they are discarded.
%
% Returns: J the time-stamps of the jittered spikes
%
% 24/10/17: initial code  
% Mark Humphries

% count number of spikes N
N = numel(spks);

% sample N random numbers from Gaussian with SD W 
j = randn(N,1) * jittersize;

% add to original spikes
jspks = spks + j;

% reject any falling outside bounds
ix = jspks < T(1) | jspks > T(2);

% return answer
jspks(ix) = [];