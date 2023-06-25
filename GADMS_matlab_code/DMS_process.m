% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com

function [NS, success, eval_time, Cache] = DMS_process(NS, classifier, trainset, parameter, Cache)
%DMS_PROCESS Summary of this function goes here
%   perform DMS process
% input: NS---- a set of non-dominated solutions
%        parameter---- parameters for DMS
%        Cache------ Cache
% output: NS_o ---- updated NS by DMS
%         success ---- 1-update success, 0-fail
%         eval_time ---- func evaluation time
%         Cache ---- new Cache

%% get parameters
ubound = parameter.ubound;
lbound = parameter.lbound;
thred = parameter.thred;
beta_par = parameter.beta_par;
gamma_par = parameter.gamma_par;
infold = parameter.infold;
success = 0;
index_poll_center = 1;
added = zeros(size(NS.trainfunc, 1), 1);
eval_time = 0;
dir_dense = parameter.dir_dense;
in_para_num = 5;
if nargin < in_para_num
    Cache = [];
end

n = size(NS.realpos, 2);
%% Generate the positive basis.
%pollnum=pollnum+1
 if (dir_dense == 0)
    D = [eye(n) -eye(n)];
 else
    v     = 2 * rand(n ,1) - 1;
    [Q,R] = qr(v);
    if ( R(1) > 1 )
       %D = Q * [ eye(n) -eye(n) ];
       D = [ eye(n); -eye(n) ] * Q;
    else
       %D = Q * [ -eye(n) eye(n) ];
       D = [ -eye(n); eye(n) ] * Q;
    end
 end
 nd = size(D, 1); % number of basises to do poll step
 
%% poll process
 for i = 1 : nd  
    rpos_temp = NS.realpos(1, :) + NS.alfa(1, :) * D(i, :);
    % make the rpos_temp in the range of [ lbound, ubound]    
    rpos_temp(rpos_temp >= ubound)=ubound-0.0000001;    
    rpos_temp(rpos_temp <= lbound)=lbound+0.0000001;
    bpos_temp = (rpos_temp > thred) * 1;
    % determine if match one point in NS
    [matchNS, ~] = match_point(bpos_temp, NS);
    if ~matchNS
         % determine if match one point in Cache
         [match, trainfunc_temp] = match_point(bpos_temp, Cache);        
         if ~match
             [trainfunc_temp] = runclassifier(classifier, trainset, bpos_temp, infold);
             if nargin == in_para_num
                Cache.pos = [Cache.pos; bpos_temp];
                Cache.trainfunc = [Cache.trainfunc; trainfunc_temp]; 
             end
             %eval_time = eval_time + 1;      
         end
         eval_time = eval_time + 1; 
         if index_poll_center ~= 0
            [pdom, index_ndom] = paretodominance(trainfunc_temp, NS.trainfunc);
         else
            [pdom, index_ndom] = paretodominance(trainfunc_temp, NS.trainfunc(2 : end, :));
            index_ndom = logical([1, index_ndom]);
         end
    else
        pdom = 1; % pdom being 1 means there are points in NS dominate pos_temp
    end
    
    if (pdom == 0)
          code_add = 1;
          success  = 1;
          if index_ndom(1) == 0 
             index_poll_center = 0; % poll center has been dominated by new solution
             index_ndom(1)     = 1;
          end
          NS.pos = [NS.pos(index_ndom, :); bpos_temp];
          NS.realpos = [NS.realpos(index_ndom, :); rpos_temp];
          NS.trainfunc = [NS.trainfunc(index_ndom, :); trainfunc_temp];
          NS.alfa = [NS.alfa(index_ndom, :); NS.alfa(1, :)];
          NS.front_dis = [NS.front_dis(index_ndom, :); [1 1]];
          added = [added(index_ndom, :); code_add];
    end 
 end
 %% update NS
 NSnum = size(NS.trainfunc, 1);
 if index_poll_center == 0
     % delete poll center
     NS = slice_sw(NS, 2:NSnum, 1);
     added = added(2:NSnum, :);
 else
     % move poll center to the last
     NS.pos = [NS.pos(2 : NSnum, :); NS.pos(1, :)];
     NS.realpos = [NS.realpos(2 : NSnum, :); NS.realpos(1, :)];
     NS.trainfunc = [NS.trainfunc(2 : NSnum, :); NS.trainfunc(1, :)];
     NS.front_dis = [NS.front_dis(2 : NSnum, :); NS.front_dis(1, :)];
     NS.alfa = [NS.alfa(2 : NSnum, :); NS.alfa(1, :)];
     added = [added(2:NSnum, :); 1];
 end
 
 %%     Update the step size parameter.
if success
    NS.alfa(logical(added)) = NS.alfa(logical(added)) * gamma_par;          
else
    NS.alfa(logical(added))= NS.alfa(logical(added)) * beta_par;
end
    

end

