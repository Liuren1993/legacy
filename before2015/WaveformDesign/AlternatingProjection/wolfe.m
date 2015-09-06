function[alpha xk1] =wolfe(xk,pk,Eta,Gamma,mu,sigma)
%Wolfe����ȷһά�������������Ż�����������ѧ�����磩24ҳ�㷨1.4.6��д��
%v1.0 author: liuxi BIT
%alphaΪҪ��Ĳ�����xk1Ϊx(k+1)�ǵó�����һ���㣬xkΪ��ʼ��,pkΪ����mu��sigmaΪ������
%һ��mu���ڣ�0��1/2��,sigma����(mu,1)
if nargin<=4
    mu=0.1;%Ĭ������
    sigma=0.5;
end

a=0;b=inf;alpha=0.1;j=0;%step1 j������ǵ������� Inf��ʾ�����
xk1=xk+alpha*pk;%step2 xk1�����㷨���x(k+1) , fk1����f(k+1), gk1����g(k+1)
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

