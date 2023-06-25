% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com

function [ match , trainfunc  ] = match_point( pos , Cache )
%MATCH_POINT Summary of this function goes here
%   determine if the position match one evaluated position

    match = 0;
    trainfunc =[];
    
    if isempty(Cache.pos)
       trainfunc = zeros(1,2);
       return;
    end

    index = find(sum(Cache.pos,2) == sum(pos));

    if ~isempty(index)
        pos_sel = Cache.pos(index,:);
        func_sel = Cache.trainfunc(index,:);

        pos_rep = repmat(pos, size(pos_sel,1), 1);
        index2 = find(sum(abs(pos_rep - pos_sel) , 2) == 0 ,1);
        if ~isempty(index2)
           match = 1;
           trainfunc = func_sel(index2,:);
        end
    end

    
    
    

end

