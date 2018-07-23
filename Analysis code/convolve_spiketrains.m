function spkfcn = convolve_spiketrains(spkdata,T,Qt,window,Pars)

% CONVOLVE_SPIKETRAINS convolve set of spike-trains with fixed-width function
% S = CONVOLVE_SPIKETRAINS(D,Qt,W,P) convolves each spike-train in the set
% of spike-trains in the 2D array D = [ID ts], over the time-period T = [t1 t2] (in seconds);
% at time-resolution Qt (in seconds); 
% using window W = {'Gaussian','exponential'} with the parameters in P.
%
% Mark Humphries 26/4/2018

% set of spike-trains
Didxs = unique(spkdata(:,1));  % set of spike-train indices
nIDs = numel(Didxs);

bins = T(1):Qt:T(2);  % time-steps of convolution

if nIDs == 0
    spkfcn = zeros(numel(bins),1);  % return all zeros
else
    spkfcn = zeros(numel(bins),nIDs);
end

switch window
    case 'Gaussian'
        SD = Pars(1);
        sig = round(SD / Qt); % SD in time-steps
        x = [-5*sig:1:5*sig]';  % x-axis values of the discretely sampled Gaussian, out to 5xSD
        h = (1/(sqrt(2*pi*sig^2)))*exp(-((x.^2*(1/(2*sig^2))))); % y-axis values of the Gaussian

    case 'exponential'
        tau = Pars(1);
        sig = round(tau / Qt);
        x = [0:1:10*sig]';   % spread to 10 times the time constant
        h = exp(-x/sig);
end
h = h ./sum(h); % make sure kernel has unit area, then can use for rate functions (spikes/s)

try
for iN = 1:nIDs
    % get all sigs for this spike-train 
    spkts = spkdata(spkdata(:,1)==Didxs(iN),2); % current time-stamps
    spkts(spkts < T(1) | spkts > T(2)) = []; 
    spkts = spkts - T(1); % shift to start wrt first bin
    %keyboard
    for iS =  1:numel(spkts)
        spk = round(spkts(iS) / Qt);
        ixs = spk+x;  % shift to spike-time
        spkfcn(ixs(ixs>0 & ixs<=numel(bins)),iN) = spkfcn(ixs(ixs>0 & ixs<=numel(bins)),iN) + h(ixs>0 & ixs<=numel(bins)); % convolve, truncating outside range
    end
end
catch
    keyboard
end

