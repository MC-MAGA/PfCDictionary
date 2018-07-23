function [grp_vector,Pword,binaryIDs,tsbinaryIDs] = Pwords(binary_array,Nwords)

% PWORDS probability distribution of every unique word
% [G,P,I,Is] = PWORDS(B,N) computes the probability of each unique word in the
% binary array of words B, given the total number of words N. 
%       Input:
%           B : nxT matrix of every K>0 word in the time-series (n neurons,
%               T non-zero words - one per column)
%           N : total number of words in entire time-series
%
%       Output: 
%           G : n*U matrix of every unique word in the time-series
%           P : U length vector of the probability of each word
%           I : U length array of the unique words' ID numbers, derived
%               from each word's binary code
%           Is : T-length array of the time-series of ID numbers
%               
%
%  NOTES:
%  The first entry in G, P and I is always the K=0 word. 
%  "Is" does *not* contain this word: [reconstruct the full time-series by filling all elements not
%               in T with 0s]
%
%   30/10/2017: initial code
%   10/11/2017: added creation of binary word IDs, and time-series thereof
%
% Mark Humphries 

[Nneurons,NNZwords] = size(binary_array);  % number of neurons, number of non-zero words
unchkd = 1:NNZwords; 



%% % full binary word approach
% grp_vector = []; grp_ts = {}counts = [];
% % get time-series of binary 
% tic
% for iW = 1:NNZwords
%     tsbinaryIDs(iW) = bin2num(binary_array(:,iW));
% end
% 
% binaryIDs = unique(tsbinaryIDs);
% for iB = 1:numel(binaryIDs)
%        grp_ts{iB} = find(binaryIDs(iB) == tsbinaryIDs);  % find all vectors identical to this one
%        counts = [counts; numel(grp_ts{iB})];  % make histogram
%        grp_vector = [grp_vector binary_array(:,grp_ts{iB}(1))]; % save this vector 
% end
% toc
% 
% PwordBinary = counts ./ Nwords;


%% counting approach: much faster
grp_vector = []; 
counts = []; nVecs = 0;
tsbinaryIDs = zeros(NNZwords,1);
% find just matching sum words
allsums = sum(binary_array);
while ~isempty(unchkd)
    % numel(unchkd)
    nVecs = nVecs + 1;
    candidate = unchkd(1);  % next unchecked vector
    % find sums of all existing vectors: compare only to those with same
    % sum!
    ixMatchedSum = find(allsums(candidate) == allsums); % 
    
    % then just check rows with 1s from target: should also be same sum if
    % same pattern
    ixRowsWithOnes = find(binary_array(:,candidate));
    ixRowSum = find(sum(binary_array(ixRowsWithOnes,:),1) == numel(ixRowsWithOnes));
    
    % store all matches...
    binaryIDs(nVecs) = bin2num(binary_array(:,candidate));
    grp_ts = intersect(ixRowSum,ixMatchedSum);  % find all vectors identical to this one
    tsbinaryIDs(grp_ts) = binaryIDs(nVecs);
    counts = [counts; numel(grp_ts)];  % make histogram
    iM = ismember(unchkd,grp_ts); % find in queue
    unchkd(iM) = [];  % remove from queue
    grp_vector = [grp_vector binary_array(:,candidate)]; % save this vector
end

% add all-zeros to word set, word counts, and grp-occurrence
if Nwords - NNZwords > 0  % then there are 0 words
    binaryIDs = [0 binaryIDs];
    grp_vector = [zeros(Nneurons,1) grp_vector];
    counts = [Nwords - NNZwords; counts];     % all words minus all non-zero words
end

% compute P(word)
Pword = counts ./ Nwords;
