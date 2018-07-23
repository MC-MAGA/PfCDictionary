function [newP,newID] = RenormalisedPword(Words,P,IDs,K)

% RENORMALISEDPWORD recomputes P(word) for restricted subset of words
% [newP,newID] = RENORMALISEDPWORD(W,P,ID,K) takes the N-length array P
% of the probabilites for the indexed words in the N-length array ID, and converts
% it into a new P(word) distribution after excluding words according the
% criterion K. The m x N matrix W is the set of N binary words, each
% m-elements in length.
%
% Criteria: include all words that are >= K
% Does: converts included set of values in P into a true probability distribution (sums to 1)  
%
% Output:
%       newP: S-length array of the probabilties of the retained words
%       newID: S-length array of the indices of the retained words
%
% 22/11/2017
% Mark Humphries

if numel(P) ~= numel(IDs) error('Probability and ID arrays are not the same length'); end;
if size(Words,2) ~= numel(P) error('Set of words and P are not the same length'); end;

Ks = sum(Words);

ixRetain = Ks >= K;
newID = IDs(ixRetain);
newP = P(ixRetain) ./ sum(P(ixRetain));