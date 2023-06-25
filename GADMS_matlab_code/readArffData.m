% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com

function data=readArffData(x)
read=weka.core.converters.ArffLoader;
read.setFile(java.io.File (x));
data=read.getDataSet();
data.setClassIndex(data.numAttributes()-1);
%data=data2
end