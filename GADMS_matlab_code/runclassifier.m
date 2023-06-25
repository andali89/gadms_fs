% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com

% inner K-fold CV for wrapper-based feature selection
function [obj]=runclassifier(classifier,Datain,population,infold)
    Data=weka.core.Instances(Datain);
    popsize=size(population,1);
    numInstan=zeros(infold,1);
    %fullFeature = Data.numAttributes()-1;%%
    sma=Data.numClasses();
    sensi_speciy=zeros(infold,sma);
    Avg_sensi=zeros(popsize,sma); %
    FeatureNum=zeros(popsize,1);
    %maxQC = zeros(popsize,1); %%
    %meanQC = zeros(popsize,1);
    cAcc=zeros(infold,1);
    Avg_Acc=zeros(popsize,1);
    Data.stratify(infold);
  
    for p=1:popsize   
        if sum(population(p,:))~=0
            DataS=FeatureSelect(Data,population(p,:));
            for k=1:infold
                TrainDataS=DataS.trainCV(infold,k-1);
                TestDataS=DataS.testCV(infold,k-1);
                numInstan(k)=TestDataS.numInstances();
                [~,cAcc(k),matrix]=trainclassify(classifier,TrainDataS,TestDataS);             
                           
                for i=1:sma
                   sensi_speciy(k,i)= matrix(i,i)/sum(matrix(i,:));
                end
                
            end
            Avg_sensi(p,:)=sum(sensi_speciy.*repmat((numInstan),1,2))/sum(numInstan);
            Avg_Acc(p)=sum(cAcc.*numInstan)/sum(numInstan);
            FeatureNum(p)=sum(population(p,:));
         
        else
            Avg_Acc(p)=0;
            Avg_sensi(p,:)=zeros(1,sma);       
            FeatureNum(p) = 1000;
      
        end
    end
  
  obj=[1-((Avg_sensi(:,1).*Avg_sensi(:,2)).^0.5),FeatureNum];
 
  
end