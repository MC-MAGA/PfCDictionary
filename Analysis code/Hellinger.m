function H = Hellinger(p,Ip,q,Iq)

% HELLINGER compute Hellinger distance between two discrete distributions
% H = HELLINGER(P,IP,Q,IQ) computes the Hellinger distance between the two
% discrete probability distributions P and Q, respectively defined at the
% sets of values IP and IQ. 
%
% If IP ~= IQ, the two sets of values are combined, and probability 0
% assigned to the missing values from IP in IQ and vice-versa.
%
%
% 7/11/2017
% Mark Humphries

if sum(p) < 1-1e-10 error('P is not a probabiltiy distribution'); end
if sum(q) < 1-1e-10 error('Q is not a probabiltiy distribution'); end

if numel(p) ~= numel(Ip) error('P and IP are not the same length'); end
if numel(q) ~= numel(Iq) error('Q and IQ are not the same length'); end


if size(p,1) ==1 p = p'; end % column vectors
if size(q,1) ==1 q = q'; end 
if size(Ip,1) == 1 Ip = Ip'; end 
if size(Iq,1) ==1 Iq = Iq'; end 

[~,IinP,IinQ] = setxor(Ip,Iq);  % set of all values that are only in one distribution

Pfull = [Ip p; Iq(IinQ) zeros(numel(IinQ),1)]; % create full array of all values

Pfull = sortrows(Pfull,1); % sort into value order
Qfull = [Iq q; Ip(IinP) zeros(numel(IinP),1)]; % create full array of all values
Qfull = sortrows(Qfull,1); % sort into value order

% keyboard

% compute Hellinger distance
H = sqrt(sum((sqrt(Pfull(:,2)) - sqrt(Qfull(:,2))).^2)) / sqrt(2);
