% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com

function [ swarm_pair ] = GA_mutation( swarm_pair,mrate,N,op )
%GA_MUTATION Summary of this function goes here
%  if op = 1 traditional mutation ,else default balanced mutation
if nargin == 4 && op == 1
    for i = 1:2
        for j = 1:N
            if rand() < mrate
                swarm_pair.pos(i,j) = abs(swarm_pair.pos(i,j) - 1);
            end
        end         
    end
else
    for i = 1:2
        %mrate- mutation rate from 1 to 0
        num_one = sum(swarm_pair.pos(i, :));
        mrate2 = mrate* num_one / (N - num_one);
        randnum = rand(1, N);
        sel_one = logical((randnum < mrate) .* swarm_pair.pos(i, :));
        sel_zero = logical((randnum < mrate2) .* ~swarm_pair.pos(i, :));
        swarm_pair.pos(i, sel_one) = 0;
        swarm_pair.pos(i, sel_zero) = 1;
    end
end

end

