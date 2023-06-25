% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com
function swarm = slice_sw(union,index,forns)
    swarm.pos =  union.pos(index,:);    
    swarm.trainfunc = union.trainfunc(index,:);
    swarm.front_dis = union.front_dis(index,:);
    if nargin ==3 && forns ==1
        fns = 1;
    else
        fns = 0;
    end   
      
    if fns ==1
        swarm.realpos = union.realpos(index,:);
        swarm.alfa =  union.alfa(index,:);
    end
end