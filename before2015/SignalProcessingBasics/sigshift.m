function [ y , n ] = sigshift( x , m , k )
%implements y(n) = x( n-k )
%  
%[y,n] = sigshift(x,m,k)
% m is the old n-sequence;
% k is the distance that m move to right 
n = m + k;  % n is the new n-sequence 
y = x ;

end

