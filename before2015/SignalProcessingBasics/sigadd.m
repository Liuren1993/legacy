function [ y , n ] = sigadd( x1 , n1 , x2 , n2 )
%implements y(n) = x1(n) + x2(n)
%   [ y , n ] = sigadd( x1 , n1 , x2 , n2)
% y = sum sequence over n,which include n1 and n2
% x1 = first sequence over n1
% x2 = second sequence over n2  (n2 can be different from n1)
%
if any(length(x1)~=length(n1) | length(x2)~=length(n2))
    error('the duration of x can not match n ; please check x(n)')
end
n = min(  min(n1),min(n2) ) : max(  max(n1),max(n2)  ); %duration of y
y1 = zeros(1,length(n));                                %initialization
y2 = y1;                                                %initialization
y1( find( [( n >= min(n1) )&( n <= max(n1) ) == 1] ) ) = x1;%y1(n) = x1(n)if x1!=0
y2( find( [( n >= min(n2) )&( n <= max(n2) ) == 1] ) ) = x2;%y2(n) = x2(n)if x2!=0
y = y1 + y2;

end

