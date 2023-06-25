% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com

function swarmo = combine_particle(swarm,particle,forns)
    swarmo.pos =  [swarm.pos;particle.pos];    
    swarmo.trainfunc = [swarm.trainfunc;particle.trainfunc];
    swarmo.front_dis = [swarm.front_dis;particle.front_dis];
    if nargin ==3 && forns ==1
       fns = 1; 
    else
       fns = 0 ;
    end
    if fns == 1     
        swarmo.realpos = [swarm.realpos; particle.realpos];     
        swarm.alfa =  [swarm.alfa; particle.alfa];
    end
end