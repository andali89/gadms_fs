% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com

function [ swarm_o,eval_time,Cache] = GA_process( swarm,classifier,trainset,crate,mrate,infold, Cache )
%GA_PROCESS Summary of this function goes here
%   perform binary tourment selection, cross, mutation
%%
[M,N] = size(swarm.pos); % number of elements, number of features
tour = 2; % binary tourment selection
swarm_o.pos = [];
swarm_o.front_dis = [];
swarm_o.trainfunc = [];
eval_time = 0;

in_para_num = 7;
if nargin < in_para_num
    Cache = [];
end
%%


for i = 1: M/2
    swarm_pair = tournament_selection(swarm,tour,M);
    swarm_pair = GA_cross(swarm_pair,crate,N);
    swarm_pair = GA_mutation(swarm_pair,mrate,N);
    for p = 1:2
        % match 1 match, 0 no match
        %swarm_pair.pos(p , :)
        [match ,trainfunc_temp] = match_point(swarm_pair.pos(p , :) , Cache);
        if ~match
             
            swarm_pair.trainfunc(p , :) = ...
                runclassifier(classifier , trainset , swarm_pair.pos(p , :) , infold);
            % add new evaluation results to Cache
            if nargin == in_para_num
                Cache.pos = [Cache.pos ; swarm_pair.pos(p , :)];
                Cache.trainfunc = [Cache.trainfunc ; swarm_pair.trainfunc(p , :)];
            end
            %eval_time = eval_time + 1;
        else
           % disp('match') 
         swarm_pair.trainfunc(p , :) = trainfunc_temp;
         eval_time = eval_time + 1;
        end    
    end
    swarm_o = combine_particle(swarm_o, swarm_pair);
end

end

