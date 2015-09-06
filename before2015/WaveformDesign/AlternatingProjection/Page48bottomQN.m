clear all
clc
%% Figure 2.8  
% Desired FTM(q) for the N < M example corresponding to N = 32 , 
% L = 4 , M = 128 and Gamma = {0,1,...,127}.

% Frequency range
F = -2500:2500;
% Clutter PSD 
% see "Optimal Signal Design for Detection of Gaussian Point Targets in 
% Stationary Gaussian Clutter/Reverberation" Page 36 
Pn = 100*exp( (-1/2)*1e-4 *(F - 1000*ones(1,5001)).^2 ) +...
    100*exp( (-1/2)*1e-4 * (F - 500*ones(1,5001)).^2 ) +...
    1000*exp( (-1/2)*1e-4 * (F + 250*ones(1,5001)).^2 ) + 1;
lamda = 0.0699;   
% Formula (11)
MaxFn = sqrt(Pn/lamda) - Pn ;    
ESD = max(MaxFn,0);
% Fake zero
ESD(ESD==0) = 1e-16;
% The FTM and Normalization
Lcoeff = 4;
Ncoeff = 32;
Kcoeff = 0 : Lcoeff*Ncoeff-1 ;
Omega = (2*pi*Kcoeff) / (Lcoeff*Ncoeff);
Fnormalized = 2*pi*F / 5000;
Gamma = ESD(1:5001/(Lcoeff*Ncoeff):5001);
% Convert to Log scale
log_scaleFTM = 10*log10(Gamma/max(Gamma));
% Depiction
subplot(2,1,1);
plot(0:127,log_scaleFTM,'r-');
title('Fig2.8');
ylabel('FTM(dB)');
axis([ 0 127 -20 5]);

%% Synthesized signal
% N = 32 , M = 128 , N < M
M = 128;
a =  exp(1i * 2 * pi * rand(1,Ncoeff) ); % rand(N,1); % ;rand(N,1) 
% run Count times
Count = 3;
CostFunGD = zeros(1,Count);
% algorithm 2 GSA for N <= M
Eta = sqrt(M);
Nstar = min(Ncoeff,(Lcoeff*Ncoeff));
n = [0:Nstar-1];
w = [0:M-1];
Phi = (angle(a)* (2*pi)/(Lcoeff*Ncoeff) * ( n' * w  ) )';   
HesseMat = eye(M);
flag = 0;
for k = 1:Count
    %step 1
    Oa =  1/Eta * exp(-1i * Phi) ; 
    OptFun = abs(Oa)/max(abs(Oa)) - Gamma'/max(Gamma); 
    Gzero = gradient(OptFun);
    %step 6
    if flag == 0
        flag = 1;
    else
    YeK = Gzero - GzeroK;
    BigD = (YeK * YeK')/(YeK*Skey);
    BigE = (GzeroK*GzeroK')/(GzeroK*Dekey');
    HesseMat = HesseMat + BigD + BigE ;
    end
    %step 3
    Dekey = -1*HesseMat*Gzero;
    %step 4
%     alpha = 1;
%     Phiadk = (Phi*(2*pi)/(Lcoeff*Ncoeff)*( n' * w  ))';
%     OaNext = 1/Eta * exp(-1i * Phiadk') ;  % 
%     OptFunNext = abs(OaNext)/max(abs(OaNext)) - Gamma/max(Gamma) ;
%     Distance = norm(OptFunNext - OptFun) ;
%     DistanceF = 1/3 * alpha * Gzero'*Dekey ;
    [alpha, xk1] = wolfe(Phi,Dekey,Eta,Gamma);
    %step 5
    Phi = Phi + alpha * Dekey;
    %step 6
    Skey = alpha * Dekey';
    GzeroK = Gzero;
    
  
    % Depiction
    % Convert to log scale
    log_scale_A = 10*log10(abs(Oa)/max(abs(Oa)));
    subplot(2,1,2);
    plot((0:127),log_scale_A);
    title('Synthesized Signal');
    ylabel('FTM(dB)');
    axis([ 0 127 -20 5]);
    
    Frame(k) = getframe;

    
end
% Average cost
% figure
% semilogx(0:Count-1,  CostFunGD / CostFunGD(2) );  
% axis([ 0 Count-1 0 1]);