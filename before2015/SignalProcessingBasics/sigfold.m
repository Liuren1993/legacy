function [ y , n ] = sigfold( x , n)
%implements y(n) = x(-n)
%  [y,n] = sigfold(x,n)
%please help fliplr
%
y = fliplr(x);
n= -fliplr(n);


end

