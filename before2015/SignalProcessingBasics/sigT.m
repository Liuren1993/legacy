function [ x ] = sigT( fundamental_cycle , times )
%Generates a cycle sequence 
%fundamental_cycle is a vector
%
x = fundamental_cycle' * ones(1,times);
x = x(:);
x = x';


end

