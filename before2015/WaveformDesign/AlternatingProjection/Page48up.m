clear all 
clc
%% Reproduce
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
ESD(ESD==0) = 1e-10;
% Convert to Log scale
log_scale = 10*log10(ESD);
% Depiction
plot(F,log_scale)
xlabel('Frequency');
ylabel('ESD(dB)');
title('Fig in Page36');
axis([ -2500 2500 -40 40])
 
%% Figure 2.8
% Desired FTM(q) for the N < M example corresponding to N = 32 , L = 4 ,
% M = 128 and Gamma = {0,1,...,127}.

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
ESD(ESD==0) = 1e-10;
% Sample
M = 5001/128;
SampleESD = ESD(1:M:5001);
% Convert to Log scale
log_scale = 10*log10(SampleESD);
% Depiction
plot([0:127],log_scale);
xlabel('Frequency');
ylabel('FTM(dB)');
title('Fig2.8');
axis([ 0 128 -20 10])