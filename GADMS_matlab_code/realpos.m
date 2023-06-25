% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com

function [ real_pos ] = realpos( pos,ubound, lbound, thred )
%REALPOS Summary of this function goes here
%   get real coded from binary coded position
    [M, N] = size(pos);
    a = 0.000000001;
    b = 0.999999999;    
    real_pos = zeros(M , N);
    for i = 1 : M        
        randnum = a + (b - a) * rand();
        real_pos(i, :) = (lbound + (thred - lbound) * randnum) .* (1 - pos(i, :))...
            + (ubound - (ubound - thred) * randnum) .*  pos(i, :);        
    end


end

