% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% email: andali1989@163.com

function [ swarm_pair ] = tournament_selection( swarm,tour,M )
%TOURNAMENT_SELECTION Summary of this function goes here
%   select a  pair of chromosomes by tournament selection
%  M-number of elements


    
    swarm_pair = t_select(swarm,tour,M);
    while 1
        swarm_pair2 = t_select(swarm,tour,M);
        if ~isequal(swarm_pair.pos,swarm_pair2.pos)
            break;
        end
    end
    swarm_pair = combine_particle(swarm_pair,swarm_pair2);

    function [swarm_sel] = t_select(swarm,tour,M)
        sel_num = zeros(tour,1);
        for i = 1:tour    
            while(1)
                sel_temp = randi(M);
                if isempty(find(sel_num == sel_temp, 1))
                    sel_num(i) = sel_temp;
                    break;
                end
            end    
        end
        swarm_temp = slice_sw(swarm, sel_num);
        [~ , index] = sortrows(swarm_temp.front_dis,[1 -2]);
        swarm_sel.pos(1,:) = swarm_temp.pos(index(1),:);
        swarm_sel.front_dis(1,:) = swarm_temp.front_dis(index(1),:);
        swarm_sel.trainfunc(1,:) = swarm_temp.trainfunc(index(1),:);
    end
 
end

