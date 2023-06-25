% Copyright (c) 2020, An-Da Li
% All rights reserved. Please read the "license.txt" for license terms.
% Coded by An-Da Li
% Email: andali1989@163.com

function datao=dataNorm(data,scale,translation)
    if nargin<2
       %nomalize to [-1£¬1]
       scale=2;
       translation=-1;
    end
    normer=weka.filters.unsupervised.attribute.Normalize();
    normer.setOptions({'-S',num2str(scale),'-T',num2str(translation)});
    normer.setInputFormat(data);
    datao=weka.filters.Filter.useFilter(data,normer);
end

