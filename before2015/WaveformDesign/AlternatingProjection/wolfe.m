function[alpha xk1] =wolfe(xk,pk,Eta,Gamma,mu,sigma)
%Wolfe不精确一维搜索。根据最优化方法（天津大学出版社）24页算法1.4.6编写。
%v1.0 author: liuxi BIT
%alpha为要求的步长，xk1为x(k+1)是得出的下一个点，xk为初始点,pk为方向，mu和sigma为参数，
%一般mu属于（0，1/2）,sigma属于(mu,1)
if nargin<=4
    mu=0.1;%默认设置
    sigma=0.5;
end

a=0;b=inf;alpha=0.1;j=0;%step1 j用来标记迭代次数 Inf表示无穷大
xk1=xk+alpha*pk;%step2 xk1代表算法里的x(k+1) , fk1代表f(k+1), gk1代表g(k+1)
fk1= 1/Eta * exp(-1i * xk1') ;  % 
gk1= gradient(abs(fk1)/max(abs(fk1)) - Gamma/max(Gamma) )';
fk= 1/Eta * exp(-1i * xk') ;  % 
gk= gradient(abs(fk)/max(abs(fk)) - Gamma/max(Gamma) )';

while  norm(fk-fk1)<-mu*alpha*gk*pk'
    j=j+1;
    b=alpha;
    alpha=0.5*(alpha+a);
    xk1=xk+alpha*pk;
    fk1=f(xk1);
    %gk1=g(xk1);
end

while gk1*pk'<sigma*gk*pk'
    j=j+1;
    a=alpha;
    alpha=min([2*alpha 0.5*(a+b)]);
    xk1=xk+alpha*pk;
    %fk1=f(xk1);
    gk1=g(xk1);
end
xk1=xk+alpha*pk;

end

