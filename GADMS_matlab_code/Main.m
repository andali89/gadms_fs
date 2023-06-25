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

%%

clc;
%clear all;
close;
%% Add weka path
addwekapath;
%% run setting
seed=46;        
infold=5;
segnum=10;
%% classifier
classifier=weka.classifiers.bayes.NaiveBayes();
classifier.setUseKernelEstimator(0); % 1 or 0
%% read and normalize data
datapath=['wdbc.arff'];
data=readArffData(datapath);
data=dataNorm(data); 
fprintf('attribute num is %d\nnum of instances is %d\n',data.numAttributes()-1,data.numInstances());
numAttri=data.numAttributes()-1;
data.randomize(java.util.Random(seed));
data.stratify(segnum);
%% parameters for GADMS
setup.popnum = 100;
setup.crate = 0.9;
setup.mrate = 1/numAttri;
setup.OrgOneP = 0.5;
setup.infold = 5;
% dms
setup.alfaini = 1;   % Initial step size.
setup.usecd = 2; % if usecd=1 then use crowding distance sort before DMS process, 2 use alfa first cd second
setup.stoptype = [1, 0, 1]; % 1 func evalution time, 2 maximum iteration, 3 parmeter reach minimum thred
                           %  [1,0,1] means func evalution time and
                           % prameter min selected
setup.stop_para = [10000, 100]; % 1*2 , minimum thred = alfa_par_min;
setup.ubound = 1;
setup.lbound = 0;
setup.thred = 0.5;
%%
Start=tic;
Startcpu=cputime;
randseed = 1;


segfold = 0;
%for segfold=8:8
RandStream.setGlobalStream(RandStream('mt19937ar','seed',randseed));
Startin=tic;
Startincpu=cputime;
disp(['Running fold ',num2str(segfold)]);


trainset=data.trainCV(segnum,segfold);

testset=data.testCV(segnum,segfold);

                                    
[Solution,Trainfunc, iter_result]= GADMS(classifier,trainset,setup);

%% get the prediction accuracy for each solution in the final solution set

numsolution=size(Solution,1);
Conf_matrix=cell(numsolution,1);
pAcc=zeros(numsolution,1);
Sensitivity=zeros(numsolution,1);
Specificity=zeros(numsolution,1);
f1=zeros(numsolution,1);
for i=1:numsolution   
    trainsetr=FeatureSelect(trainset,Solution(i,:));
    testsetr=FeatureSelect(testset,Solution(i,:));
    [~,pAcc(i),Conf_matrix{i,1}]=trainclassify(classifier,trainsetr,testsetr);
     Sensitivity(i)=Conf_matrix{i,1}(1,1)/sum(Conf_matrix{i,1}(1,:));
    Specificity(i)=Conf_matrix{i,1}(2,2)/sum(Conf_matrix{i,1}(2,:));
    preci = Conf_matrix{i,1}(1,1)/sum(Conf_matrix{i,1}(:, 1));
    if (preci + Sensitivity(i)) ==0 || isnan(preci)
        f1(i) = 0;
    else
        f1(i) = ( 2* preci * Sensitivity(i))/ (preci + Sensitivity(i));      
    end
  
end

Performance=[Sensitivity,Specificity,pAcc, f1];



%% summarize
