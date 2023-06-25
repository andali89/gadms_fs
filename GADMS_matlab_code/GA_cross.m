% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com

function [ swarm_pairo ] = GA_cross( swarm_pair,crate,N)
%GA_CROSS Summary of this function goes here
%   perform cross process
  
    if rand() > crate
        swarm_pairo = swarm_pair;
        
        return;        
    end
    %% added for crossover more efficiently
    difbits = bitxor(swarm_pair.pos(1, :) , swarm_pair.pos(2, :));
    point_candi = find(difbits == 1);
    len_candi =  length(point_candi);
    if len_candi <= 1
       swarm_pairo = swarm_pair;
       return;
    end
    
    c_index = 1+ randi(len_candi - 1);
    c_point = point_candi(c_index);
    %%
    %c_point = 1 + randi(N-1);
    swarm_pairo.pos(1,:) = [swarm_pair.pos(1,1: c_point -1),swarm_pair.pos(2,c_point:end)];
    swarm_pairo.pos(2,:) = [swarm_pair.pos(2,1: c_point -1),swarm_pair.pos(1,c_point:end)];
    n_obj = size(swarm_pair.trainfunc,2);
    swarm_pairo.trainfunc = zeros(2,n_obj);
    swarm_pairo.front_dis = zeros(2,2);

end

