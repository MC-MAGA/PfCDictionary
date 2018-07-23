function N = bin2num(B)

% BIN2NUM convert binary vector into number
% N = BIN2NUM(B) converts the binary vector in n-length array B into the
% corresponding number N. 
% 
% Assumes first entry is 2^(n-1), second entry is 2^(n-2) etc
%
% Mark Humphries 8/11/2017

if any(B~=0 & B~=1)
    error('Not a binary vector');
end

[r,c] = size(B);
if r > c
    B = B'; n = r;
else
    n = c;
end
twos = pow2([n-1:-1:0]);

N = sum(B.*twos);