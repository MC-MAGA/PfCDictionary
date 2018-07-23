function [WordData,CountData] = MakeAndCountWords(Spks,Times,binsize)
    
% MAKEANDCOUNTWORDS mkes all non-empty words in spike data, and counts
% them
% [W,C] = MAKEANDCOUNTWORDS(S,I,T,B) given the spike data in struct S, the times of
% each chunk of spikes in the 2-D array T, and the binsize B,
% creates the set of binary words in the spike-data, and
% calculates the number of spikes per bin (K), and further statistics of the K
% count.
%   Input format (all times in S, T & B need to be in the same units):
%       S: is a N x c array of structs, each with a field .spks; the (i,j)th
%           .spks field is the set of spike times for neuron i in the jth chunk
%           of time (e.g. a trial or bout). Each .spks field is a 2D array [times ID] 
%           N neurons, and c chunks.
%       T: is as cx2 array of times, the ith row is the [start end] time of the ith chunk of time
%       B: binsize for counting spikes within each chunk of time
%
%   Output:
%       W: struct of binary words, with fields
%               .edges        : an E length vector of all bin edges
%               .ts_array     : a vector of bin IDs with K>=1 spike, length T
%               .binary_array : a N x T sparse matrix, the ith column the word at time-index T_i 
%
%       C: struct of word count data, with fields
%               .Changed      : count of all 1s that had two or more spikes
%               .Pchanged     : proportion of all 1s that had two or more spikes
%               .K            : vector of 0:max(K) in this data
%               .Khistogram   : count of number of words at each K
%               .K2           : count of all co-active (K>=2) words
%               .Nwords       : total number of words
%
%
% NOTE: assumes neurons are ID stamped at 1,2,...,N in the .spks struct
%
% 30/10/2017: initial code, derived from CountKWords.m
% 31/10/2017: fixed neuron ID bug
%
% Mark Humphries

% get all non-empty sections
fullIndices = arrayfun(@(x) ~isempty(x.spks), Spks); % find all non-empty Neuron+Chunk combinations
tsFull = vertcat(Spks(fullIndices).spks);   % concatenate the time-stamps
IDs = 1:size(Spks,1); 

% makes a vector of all bins that fall within a chunk in the entire dataset
WordData.edges = [];
for iT = 1:size(Times,1)
    % get edges of bins, concatenating all chunks
    % Note: we keep the bins defined by the between-chunk edges: these are the final "word" in each chunk 
    WordData.edges = [WordData.edges Times(iT,1):binsize:Times(iT,2)];     
end

[Counts,~,binIDs] = histcounts(tsFull(:,1),WordData.edges);  % number of spikes within each bin of these entire set

% now make words
WordData.ts_array = find(Counts > 0);  % time-stamps of all non-zero words
WordData.binary_array = zeros(numel(IDs),numel(WordData.ts_array)); % sparse matrix of non-zero words

CountData.Changed = 0;

for iB = 1:numel(WordData.ts_array)
    % ixSpks = find(tsFull(:,1) >= edges(ix_K2(iB)) & tsFull(:,1) < edges(ix_K2(iB)+1));  % spikes that fall in this bin
    % get IDs of neurons that spiked in this bin
    theseIDs = tsFull(binIDs==WordData.ts_array(iB),2);  % all spike IDs in this bin
    keepIDs = unique(theseIDs);     % the set of unique neurons
    % set entry in binary matrix
    WordData.binary_array(keepIDs,iB) = 1;
    
    if numel(theseIDs) > numel(keepIDs)  % then redundant spikes....
        ct = histcounts(theseIDs,keepIDs); % how many of each ID
        CountData.Changed = CountData.Changed + sum(ct > 1);  % count each bin that had redundant spikes
    end
end

% do counting
Ks = sum(WordData.binary_array);        % number of 1s in each K>=1 bin

% make histogram
CountData.K = 0:max(Ks);
CountData.Khistogram = histcounts(Ks,CountData.K + 0.5);  % stupid histogram function only deals with bin edges,so make edges from 0.5 to end    
Nzeros = numel(Counts) -  numel(WordData.ts_array); % how many empty words?
CountData.Khistogram = [Nzeros CountData.Khistogram]; % add in the zero-count


% proportion of 1s that were more than 1 spike
CountData.Pchanged = CountData.Changed ./ sum(Ks);

CountData.K2 = sum(CountData.Khistogram(CountData.K >= 2));  % how many co-active words?
CountData.Nwords = numel(Counts);

% make binary array sparse - or could make it sparse at outset (max N is
% numel(tsFull))
WordData.binary_array = sparse(WordData.binary_array);