% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com

%% find find the Non_Swarm and sort non_swarm based on the non-domination
%% distance
% input: swarm_sort: swarm_Sort object, been sorted  by non_domination_sort
%        option: 0- find the Non_Swarm from Swarm_Non and sort based on distance
%                1- Only sort based on distance
%                2- Only find the Non_Swarm without sort



function non_swarm = find_sort(swarm_sort,option)
V = size(swarm_sort.pos,2);
M = size(swarm_sort.trainfunc,2);

% find Non_Swarm
if option ~=1
    select = swarm_sort.front_dis(:,1)==1;
    non_swarm.pos = swarm_sort.pos(select,:);
    non_swarm.trainfunc = swarm_sort.trainfunc(select,:);
    
    non_swarm.front_dis = swarm_sort.front_dis(select,:);
    
else
    non_swarm = swarm_sort;
end

%sort
if option ~=2
    temp_swarm = flipud(sortrows([non_swarm.front_dis,non_swarm.pos,non_swarm.trainfunc],2));
    
        non_swarm.front_dis = temp_swarm(:,1:2);
    
    non_swarm.pos = temp_swarm(:,3:2+V);
    non_swarm.trainfunc = temp_swarm(:,2+V+1:2+V+M);
end


end