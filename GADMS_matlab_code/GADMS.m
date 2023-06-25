% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com

%This is an implementation of the multi-objective optimization method called 
%GADMS for key quality characteristic selection (feature selection).
%The optimization method combines the GA with direct multiseach to perform 
%the evolutionary process. For a detailed description of the method please 
%refer to 

% A.-D. Li, B. Xue and M. Zhang, Multi-objective feature selection using 
% hybridization of a genetic algorithm and direct multisearch for key quality 
% characteristic selection, Information Sciences 523 (2020) 245-265.

function [ Solution,Trainfunc, iter_result ] = GADMS(classifier,trainset,setup )
%GADMS Summary of this function goes here
%   input: classifier
%          trainset- the trainset
%          setup - parameters
%   output: solution - selected feature subsets
%           Trainfunc - trainfunction for each feature subset

%% get paparemters
popnum = setup.popnum;
crate = setup.crate;
mrate = setup.mrate;
OrgOneP = setup.OrgOneP;
infold = setup.infold;
% dms
alfaini = setup.alfaini;   % Initial step size.
usecd = setup.usecd; % if usecd=1 then use crowding distance sort before DMS process
stoptype = setup.stoptype; % 1 func evalution time, 2 maximum iteration, 3 parmeter reach minimum thred
                           %  [1,0,1] means func evalution time and
                           % prameter min selected
stop_para = setup.stop_para; % 1*2 , minimum thred = alfa_par_min;

parameter.ubound = setup.ubound;
parameter.lbound = setup.lbound;
parameter.thred = setup.thred;
parameter.infold = setup.infold;
parameter.dir_dense = 1; % 1 or 0, 1 default

% defined in GADMS
parameter.beta_par  =0.95;  % Coefficient for step size contraction.
alfa_par_min=10^-3;
parameter.gamma_par = 1;    % Coefficient for step size expansion.
outprint = 1;
 iter_result ={};

%% Initialization population 
vnum = trainset.numAttributes() - 1;% 变量个数
%编码，种群
%rechrom = 1;
% while rechrom>0
%     %编码不能全为0
%     swarm.pos=round(rand(popnum,vnum)-(0.5-OrgOneP)); % get binary coded population
%     rechrom=length(find(sum(swarm.pos,2)==0));
%     rechrom
% end
swarm.pos=initialization(popnum,vnum);
eval_time = 0;
iter_time = 0;
stopflag = 1;
%% add non-dominated set to set NS
[swarm.trainfunc]=runclassifier(classifier, trainset, swarm.pos, infold);
eval_time = eval_time + popnum;
Cache.pos = swarm.pos;
Cache.trainfunc = swarm.trainfunc;
swarm = non_domination_sort_mod(swarm);
NS = find_sort(swarm,0);
NSnum = size(NS.trainfunc,1);
NS.alfa = zeros(NSnum,1) + alfaini;
NS.realpos = realpos(NS.pos, parameter.ubound, parameter.lbound, parameter.thred);

%% print
if outprint == 1
    fprintf('Iteration Report: \n\n');
    fprintf('| iter  | func eval_time | GA_success | dms_success | list size |     min alpha    |     max alpha    |\n');
    print_format = ('| %5d |    %6d      |    %2s      |     %2s      |   %5d   | %+13.8e | %+13.8e |\n');
    fprintf(print_format, iter_time, '--','--', NSnum, min(NS.alfa), max(NS.alfa));
end

%%
iter_this = [[0,eval_time],{NS.trainfunc}]; % Save the iterations informations
iter_result = iter_this;
   

while stopflag
    
    %% perform GA process
    [swarm_temp, GA_eval_time, Cache] = GA_process(swarm, classifier, trainset, crate, mrate, infold, Cache);
    eval_time = eval_time + popnum;
    pool = combine_particle(swarm_temp, NS);
    %pool = combine_particle(pool, swarm); % 加上之后类似NSGA-II
    pool = non_domination_sort_mod(pool);
    % get the new swarm for GA
    swarm = slice_sw(pool, 1:popnum);
       
    %% find the current  non-dominated set
    
    NS_old = NS; % NS_temp is the NS in last iteration   
    NSonum = size(NS_old.trainfunc, 1);
    NS = find_sort(pool, 0);
    NSnum = size(NS.trainfunc, 1);
    NS.alfa = zeros(NSnum,1) + alfaini;
    NS.realpos = NS.pos;
    sort_num = zeros(NSnum, 1);
    %% for test
%     if NSonum > 1
%         ffff = 0;
%     for mm = 1: NSonum-1        
%         for nn = mm+1 : NSonum
%              if isequal(NS_old.pos(mm,:), NS_old.pos(nn,:))
%                  disp(['chongfuNSold',num2str(mm),num2str(nn)]);
%                  disp([NS_old.pos(mm, :);NS_old.pos(nn, :)]);
%                  pause;
%                  ffff = 1;
%                  break;
%              end
%         end
%         if ffff ==1
%             break;
%         end
%     end
%     end
%     
%     if NSnum > 1
%         ffff = 0;
%     for mm = 1: NSnum-1        
%         for nn = mm+1 : NSnum
%              if isequal(NS.pos(mm,:), NS.pos(nn,:))
%                  disp(['chongfuNS',num2str(mm),num2str(nn)]);
%                  disp([NS.pos(mm, :);NS.pos(nn, :)]);
%                  pause;
%                  ffff = 1;
%                  break;
%              end
%         end
%         if ffff ==1
%             break;
%         end
%     end
%     end
 
    %%
    % determine if the current NS is changed
    update_GA = 0; % if update_GA = 1, then the GA process updated the NS
    for j = 1 : NSnum
        % get the index of point in NS_old
        pos_rep = repmat(NS.pos(j , :), NSonum, 1);
        index = find(sum(abs(pos_rep - NS_old.pos), 2) == 0, 1);
        if ~isempty(index) % if match
            NS.realpos(j , :) = NS_old.realpos(index, :);
            NS.alfa(j , :) = NS_old.alfa(index, :);
            sort_num(j) = index;
        else % not match
            % give new real position
            NS.realpos(j, :)= realpos(NS.pos(j, :) , parameter.ubound , parameter.lbound , parameter.thred);
            update_GA = 1;
            %sort_num(j) = j + NSonum; %add new  in the last
            sort_num(j) = -j; % add new  in the first
        end
    end
    % sort: new added in the last or first
    [~ , sorted] = sort(sort_num); 
    NS = slice_sw(NS, sorted, 1);
  
    %% fortest
%     if NSnum~= NSonum && update_GA ==0
%         disp('NS.pos');
%         disp(NS.pos);
%         disp('NS_old.pos');
%         disp(NS_old.pos);
%         pause;
%     end
   %% if GA_process fails perform DMS process
    success = 0; %for DMS
    
   %test
   
    if update_GA == 0
        if sum(NS.alfa > alfa_par_min) ==0 % if all alfas smaller than (or =) alfa_min don't perform DMS process            
            DMS_eval_time =0;
        else
            NS = sort_for_DMS( NS, alfa_par_min, usecd);
            [NS, success, DMS_eval_time] = DMS_process(NS, classifier, trainset, parameter, Cache);            
        end
        eval_time = eval_time + DMS_eval_time;        
    end    
    iter_time = iter_time + 1;
    
    iter_this = [[iter_time,eval_time],{NS.trainfunc}]; % Save the iterations informations
   
    iter_result = [iter_result; iter_this];
    
    %% for test
%     NStt = non_domination_sort_mod(NS);
%     sizett = size(NStt.trainfunc, 1);
%     sizeNStt = sum(NStt.front_dis(:,1) == 1);
%     if sizett ~= sizeNStt
%        disp(['sizett:',num2str(sizett)]);
%        disp(['sizeNStt:',num2str(sizeNStt)]);
%        NStt.front_dis
%        pause;
%     end
    %% update stop flag
    if stoptype(1) == 1 && eval_time >= stop_para(1) % func_eval time
        stopflag = 0;        
    end
    if stoptype(2) == 1 && iter_time >= stop_para(2) % iteration time
        stopflag = 0;
    end
    if stoptype(3) == 1 && sum(NS.alfa > alfa_par_min) == 0 % alfa_min
        stopflag =0 ;
    end
    
    %% print the evaluation results in this iteration
    if outprint == 1
        fprintf(print_format, iter_time, eval_time, num2str(update_GA), num2str(success), size(NS.trainfunc, 1), min(NS.alfa), max(NS.alfa));
    end
end
Solution = NS.pos;
Trainfunc = NS.trainfunc;
end

