% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com

function [predictedClass,rate,conf_matrix]=trainclassify(bayes,trainset,testset)

     bayes.buildClassifier(trainset);
             %test naive bayes
     if nargout==2
        [predictedClass,rate]=classify(bayes,testset);
     elseif nargout==3
        [predictedClass,rate,conf_matrix]=classify(bayes,testset); 
     end
end