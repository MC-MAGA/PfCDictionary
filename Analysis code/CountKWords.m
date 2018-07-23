function CountData = CountKWords(Spks,Times,binsize)
    
% COUNTKWORDs counts how many words of K exist in the spike data
% C = COUNTKWORDS(S,T,B) given the spike data in struct S, the times of
% each chunk of spikes in the 2-D array T, and the binsize B,
% calculates the number of spikes per bin (K), and further statistics of the K
% count.
%   Input format (all times in S, T & B need to be in the same units):
%       S: is a N x C array of structs, each with a field .spks; the (i,j)th
%           .spks field is the set of spike times for neuron i in the jth chunk
%           of time (e.g. a trial or bout). Each .spks field is a 2D array [times ID] 
%           N neurons, and C chunks.
%       T: is as Cx2 array of times, the ith row is the [start end] time of the ith chunk of time
%       B: binsize for counting spikes within each chunk of time
%
% 24/10/2017: initial code
% Mark Humphries

% get all non-empty sections
fullIndices = arrayfun(@(x) ~isempty(x.spks), Spks); % find all non-empty Neuron+Chunk combinations
tsFull = vertcat(Spks(fullIndices).spks);   % concatenate the time-stamps
IDs = unique(tsFull(:,2));

% makes a vector of all bins that fall within a chunk in the entire dataset
edges = [];
for iT = 1:size(Times,1)
    % trial-by-trial counting
    edges = [edges Times(iT,1):binsize:Times(iT,2)];     
end
[Counts,~,binIDs] = histcounts(tsFull,edges);  % number of spikes within each bin of these entire set; i.e. the K per bin
% now make words
ix_K = find(Counts > 0);
binary_array = zeros(numel(IDs),numel(ix_K));

for iB = 1:numel(ix_K2)
    % ixSpks = find(tsFull(:,1) >= edges(ix_K2(iB)) & tsFull(:,1) < edges(ix_K2(iB)+1));  % spikes that fall in this bin
    
    ixSpks = find(binIDs(:,1)==ix_K2(iB));
    
    theseIDs = unique(tsFull(ixSpks,2));  % unique spike IDs in this bin
    
    if numel(ixSpks) < 2  % catch error if bin is not correctly found
        if ix_K2(iB) == numel(Counts)
            % the is last bin and MATLAB decided to throw an out-of-bound
            % spike in there
            Counts(ix_K2(iB)) = 1;
        else 
            keyboard
        end
    end
    if numel(theseIDs) > 1  % if bin has more than one neurons, keep it
        ixKeep(iB) = 1;
    end
end

% adjust Count by all that do not have at leas 2 unique neurons
Counts(ix_K2(~logical(ixKeep))) = 1;  

ix_K2 = ix_K2(logical(ixKeep));



% Note: we keep the bins defined by the between-chunk edges: these are the final "word" in each chunk 

CountData.K2 = sum(ixKeep);
% CountData.K2 = numel(ix_K2);
CountData.Nwords = numel(Counts);
