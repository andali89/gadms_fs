% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com

function [ pdom, index_ndom ] = paretodominance( F, Flist )
%PARETODOMINANCE Summary of this function goes here
%   determine if trainfunc dominate one or more functions in trainfunclist
%   and return the domination results.
%   pdom: 0 -  trainfunc dominate
%         1 - trainfunc don't dominate
%   index_ndom: 1 means corresponding one being not dominated by trainfunc

index_ndom    = [];
[M, N] = size(Flist);
Faux = repmat(F, M, 1);
index_e = find(sum(abs(Faux - Flist), 2) == 0, 1);

if ~isempty(index_e)
    pdom       = 0;
    index_ndom = logical(ones(1,M));
else
    index = logical(sum(logical(Faux < Flist), 2)); %ok
    if (sum(index) < M)
        pdom = 1; % some point(s) dominate F
    else
        pdom       = 0;
        index      = sum(logical(Faux <= Flist), 2); %
        index_ndom = ~logical(index' == N);  % only contains the index that are not dominated by F
    end
end

end

