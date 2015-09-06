function [ y,m] = dnsample( x,n,M )
%Downsample sequence x(n) by a factor M to obtain y(m)
%  
y = x( find(n/M == round(n/M))) ;
m = n( find(n/M == round(n/M))) ;
m = min(m)/M : max(m)/M;
end

