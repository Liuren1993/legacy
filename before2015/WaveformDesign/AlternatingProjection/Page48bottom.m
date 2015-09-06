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
% FTM and Normalization
Lcoeff = 4;
Ncoeff = 32;
Kcoeff = 0 : Lcoeff*Ncoeff-1 ;
Omega = (2*pi*Kcoeff) / (Lcoeff*Ncoeff);
Fnormalized = 2*pi*F / 5000;
Gamma = sqrt( ESD(1:5001/(Lcoeff*Ncoeff):5001) ) /2.82 ; % 
% Convert to Log scale
log_scaleFTM = 10*log10(Gamma);
% Depiction
subplot(3,1,1);
plot(0:127,log_scaleFTM,'r-');
title('Fig2.8');
ylabel('FTM(dB)');
axis([ 0 127 -15 15]);

%% Synthesized signal
% N = 32 , M = 128 , N < M
M = 128;
a =  exp(1i * 2 * pi * rand(1,Ncoeff) ); % rand(N,1); % ;rand(N,1)  [1:32]
GD = a;                                  %  exp(1i * 2 * pi * rand(1,Ncoeff) );
% run Count times
Count = 150;
CostFun = zeros(1,Count);
CostFunGD = zeros(1,Count);
% algorithm 2 GSA for N <= M
Eta = sqrt(M);
Nstar = min(Ncoeff,(Lcoeff*Ncoeff));
n = [0:Nstar-1];
w = [0:M-1];
flag = 0;
for k = 1:Count
    % GSA
    aPre = a;
    Ua =  1/Eta * aPre *exp( -1i * (2*pi)/(Lcoeff*Ncoeff) ).^( n' * w  );  %
    UaAngle = angle(Ua);
    B = Gamma.*exp(1i*UaAngle);
    UhB =  1/Eta * B *exp( 1i * (2*pi)/(Lcoeff*Ncoeff) ).^( w' * n  );  %
    UhBAngle = angle(UhB);
    a = exp(1i*UhBAngle);
    % GD
    aPreGD = GD;
    UaGD =  1/Eta * aPreGD *exp( -1i * (2*pi)/(Lcoeff*Ncoeff) ).^( n' * w  );  %
    UaAngleGD = angle(UaGD);
    BGD = Gamma.*exp(1i*UaAngleGD);
    UhBGD =  1/Eta * BGD *exp( 1i * (2*pi)/(Lcoeff*Ncoeff) ).^( w' * n  );  %
    if flag == 0
        UhBAngleGD = angle(UhBGD);
        flag = 1;
    else
        UhBAngleGD = UhBAngleGD - 0.5 * imag(GD.*conj(UhBGD) );
    end
    GD = exp(1i*UhBAngleGD);
    
    % Depiction
    % GSA
    log_scale_A = 10*log10(abs(Ua));  % abs(Ua)/max(abs(Ua)
    
    subplot(3,1,2);
    plot((0:127),log_scale_A);
    title('Synthesized Signal-GSA');
    ylabel('FTM(dB)');
    axis([ 0 127 -15 15]);
    % GD
    log_scale_AGD = 10*log10(abs(UaGD));  %  abs(UaGD)/max(abs(UaGD))
    
    subplot(3,1,3);
    plot((0:127),log_scale_AGD);
    title('Synthesized Signal-GD');
    ylabel('FTM(dB)');
    axis([ 0 127 -15 15]);
    
    Frame(k) = getframe;
    
    % calculate the cost function
    % GSA
    CostUa =  1/Eta * a *exp( -1i * (2*pi)/(Lcoeff*Ncoeff) ).^( n' * w  ); %
    CostFun(k) = ( norm( abs(CostUa) - Gamma ) )^2; %   Gamma/max(Gamma)   abs(Ua)/max(abs(Ua))
    % GD
    CostUaGD =  1/Eta * GD *exp( -1i * (2*pi)/(Lcoeff*Ncoeff) ).^( n' * w  );  %  1/Eta *
    CostFunGD(k) = ( norm( abs(CostUaGD) - Gamma ) )^2; % abs(UaGD)/max(abs(UaGD)   Gamma/max(Gamma) 
    
    
end
% Average cost
figure
semilogx(0:Count-1,CostFun / CostFun(2),'-.' , 0:Count-1,CostFunGD / CostFunGD(2) );
axis([ 0 Count-1 0 1]);
title(['N=',num2str(Ncoeff),',M=',num2str(M)]);
xlabel('Iteration number');
ylabel('Average Normalized Cost');
legend('GSA','GD')


