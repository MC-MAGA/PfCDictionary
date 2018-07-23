function [K,Kset] = KIndices(WordSet)

% KINDICES indices of set of words that each have K spikes in total
% [K,I] = KINDICES(W) given the (NxT) matrix of binary words W, finds each
% set of words with the same total number of spikes K.
% Returns K, a k-length array of the distribution of K across all words in
% W; and I, a k-length cell array, cell I(i) giving the indices of the
% words in W that have K(i) spikes in total.
%
% 30/10/17: initial code
%
% Mark Humphries 

Ks = full(sum(WordSet));  % K for each word
K = unique(Ks);
Kset = cell(numel(K),1);
for iK = 1:numel(K);
    Kset{iK} = find(Ks == K(iK));
end