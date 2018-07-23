function c= PopCouple(ratefcns,lag,flag)

% POPCOUPLE computes the coupling of each neuron to the population
% C = POPCOUPLE(R,L,flag) computes the population coupling of each neuron,
% given:
%   R: the [TxN] matrix of rate functions, where N is the number of neurons,
%   and T is the number of time-steps. Each entry is the rate of that neuron 
%   at that time (from eg a rate histogram  or spike density function)
%    
%   L: the lag between the neuron and the population (in time steps); lag <
%   0 means the neuron leads the population, and vice-versa
%
%   flag: the type of population coupling C(i):
%       'Pearson': C(i) is the correlation coefficient between the rate 
%               function of neuron i, and the sum of all other rate functions
%               [which is equivalent to the product of the Z-scores]; as
%               per Okun et al 2015 
%       'Spearman': C(i) is the Spearman's rank instead
%
% Returns: 
%   C, the N-length column vector of population coupling     
%
% Mark Humphries 30/4/2018

[nTime,nIDs] = size(ratefcns);
ixs = 1:nIDs;
c = zeros(nIDs,1);
for iN = 1:nIDs
    PRnow = sum(ratefcns(:,ixs~=iN),2);
    if lag <= 0
        %c(iN) = sum((ratefcns(1:nTime-lag,iN) - mean(ratefcns(1:nTime-lag,iN))) .* PRnow(1+abs(lag):end));
        c(iN) = corr(ratefcns(1:nTime-lag,iN),PRnow(1+abs(lag):end),'type',flag);
    else
        % c(iN) = sum((ratefcns(1+lag:end,iN) - mean(ratefcns(1+lag:end,iN))) .* PRnow(1:nTime-lag:end));
        c(iN) = corr(ratefcns(1+lag:end,iN),PRnow(1:nTime-lag:end),'type',flag);
    end
    if isnan(c(iN))  % because there is no spikes for this neuron....
        c(iN) = 0;
    end
end



