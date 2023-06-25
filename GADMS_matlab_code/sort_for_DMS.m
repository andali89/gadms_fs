% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com

function [ NS ] = sort_for_DMS( NS, alfa_par_min, option )
%SORT_FOR_DMS Summary of this function goes here
% sort NS for the DMS process.The first element of NS is the poll center.
% input: NS - non-dominated set
%        alfa_par_min - the minimal alfa value, if alfa being below
%                       alfa_par_min, then do not select this element as
%                       the poll center
%        option - 1 means using crowding distance, first select the point
%                 with the maximum cd
%               - 2 means using alfa first and using crowding distance
%               secondly
    if option ==1
        % sort alfa and crowding distance in descending order, alfa has
        % the first priority
        N = size(NS.front_dis, 1);
        priority = zeros(N, 1); % the last element do not put in the first 
        priority(N) = 1;
        [~, index] = sortrows([NS.alfa > alfa_par_min, priority, NS.front_dis(:,2)], [-1 2 -3]);
    elseif option ==2
        [~, index] = sortrows([NS.alfa, NS.front_dis(:,2)], [-1 -2]);
    else
        first = find(NS.alfa > alfa_par_min, 1);
        NSnum = size(NS, 1);
        index = 1: NSnum;
        if first > 1         
            index(2: first) = 1: (first-1);
            index(1) = first;
        end        
    end
    NS = slice_sw(NS, index, 1);
end

