function G = WordIndices(WordSet)

% WORDINDICES the indices of each non-zero element per word
% G = WORDINDICES(W) given the (NxT) matrix of binary words W, finds the indices
% of each non-zero entry in each of the T words. Returns G, the T-length cell array of indices
% per word.
%
% 30/10/17: initial code
%
% Mark Humphries 

[iNeuron,iWord] = find(WordSet);  % the (row,column) index of every {1}
G = cell(max(iWord),1);  % max number of columns = number of words
for iW = 1:max(iWord)
    G{iW} = iNeuron(iWord == iW); % neuron indices in the current word
end