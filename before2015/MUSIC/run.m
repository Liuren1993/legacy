clc
clear all
%% profiler
% profile on
tic
%% initialization
du = pi/180;
w=[pi/6 pi/3 pi/2]';
a = SourceNumEstimation;
a.Azimuth = [ -20*du 30*du 60*du ];
a.Lamda = 0.15;

%% trial A
pause;
disp('This trial will cost almost 15 seconds. Press any key to continue... ')
a.LinearArrayNum = 12;
S=[1.3*cos(w(1)*(0:1/1999:1));...
    1.0*sin(w(2)*(0:1/1999:1));...
    1.0*sin(w(3)*(1:1/1999:2))];
NoisePowerRangedB = -20:10; % dB
NoisePowerRange = 10.^(NoisePowerRangedB/10);
SNR = linspace(-10,20,31);
len = length(NoisePowerRangedB);
TruePercent = zeros(3,len);
for i = 1:len;
    a.NoisePower = NoisePowerRange(i);
    a.SignalArray = S;
    TrueCount = zeros(3,1);
    FalseCount = zeros(3,1);
    for j = 1:100
        [EsNum,MDL,HQ] = a.Trial;
        if EsNum ==3
            TrueCount(1,1) = TrueCount(1,1)+1;
        else
            FalseCount(1,1) = FalseCount(1,1)+1;
        end
        if MDL ==3
            TrueCount(2,1) = TrueCount(2,1)+1;
        else
            FalseCount(2,1) = FalseCount(2,1)+1;
        end
        if HQ ==3
            TrueCount(3,1) = TrueCount(3,1)+1;
        else
            FalseCount(3,1) = FalseCount(3,1)+1;
        end
        
    end
    TruePercent(1,len+1-i) = TrueCount(1,1) / 100;
    TruePercent(2,len+1-i) = TrueCount(2,1) / 100;
    TruePercent(3,len+1-i) = TrueCount(3,1) / 100;
    
end
figure(1)
plot(SNR,TruePercent(1,:),'-*',SNR,TruePercent(2,:),'-o',SNR,TruePercent(3,:),'-x')
l = legend('AIC','MDL','HQ');
title('信息论准则性能与信噪比的关系')
xlabel('SNR/dB');
ylabel('成功率');
%% trial B
pause;
disp('This trial will cost almost 10 seconds. Press any key to continue... ')
a.LinearArrayNum = 12;
a.NoisePower = 10^-0.5;
Lnum =[100,250,500,1000,2000,2500,4000,5000,6000,8000,10000];
len = length(Lnum);
TruePercent = zeros(3,len);
for i = 1:len;
    L = 1/Lnum(i);
    S=[1.3*cos(w(1)*(0:L:1));...
        1.0*sin(w(2)*(0:L:1));...
        1.0*sin(w(3)*(1:L:2))];
    a.SignalArray = S;
    TrueCount = zeros(3,1);
    FalseCount = zeros(3,1);
    for j = 1:100
        [EsNum,MDL,HQ] = a.Trial;
        if EsNum ==3
            TrueCount(1,1) = TrueCount(1,1)+1;
        else
            FalseCount(1,1) = FalseCount(1,1)+1;
        end
        if MDL ==3
            TrueCount(2,1) = TrueCount(2,1)+1;
        else
            FalseCount(2,1) = FalseCount(2,1)+1;
        end
        if HQ ==3
            TrueCount(3,1) = TrueCount(3,1)+1;
        else
            FalseCount(3,1) = FalseCount(3,1)+1;
        end
        
    end
    TruePercent(1,i) = TrueCount(1,1) / 100;
    TruePercent(2,i) = TrueCount(2,1) / 100;
    TruePercent(3,i) = TrueCount(3,1) / 100;
    
end
figure(2)
plot(log10(Lnum),TruePercent(1,:),'-*',log10(Lnum),TruePercent(2,:),'-o',log10(Lnum),TruePercent(3,:),'-x');
l = legend('AIC','MDL','HQ');
title('信息论准则性能与快拍数的关系')
xlabel('lg(快拍数)（取x轴为对数坐标）');
ylabel('成功率');
%% trial C
pause;
disp('This trial will cost almost 30 seconds. Press any key to continue... ')
S=[1.3*cos(w(1)*(0:1/1999:1));...
    1.0*sin(w(2)*(0:1/1999:1));...
    1.0*sin(w(3)*(1:1/1999:2))];
a.NoisePower = 10^-0.5;
ArrayNum = 1:50;
a.SignalArray = S;
len = length(ArrayNum);
TruePercent = zeros(3,len);
for i = 1:len;
    a.LinearArrayNum = ArrayNum(i);
    TrueCount = zeros(3,1);
    FalseCount = zeros(3,1);
    for j = 1:100
        [EsNum,MDL,HQ] = a.Trial;
        if EsNum ==3
            TrueCount(1,1) = TrueCount(1,1)+1;
        else
            FalseCount(1,1) = FalseCount(1,1)+1;
        end
        if MDL ==3
            TrueCount(2,1) = TrueCount(2,1)+1;
        else
            FalseCount(2,1) = FalseCount(2,1)+1;
        end
        if HQ ==3
            TrueCount(3,1) = TrueCount(3,1)+1;
        else
            FalseCount(3,1) = FalseCount(3,1)+1;
        end
        
    end
    TruePercent(1,i) = TrueCount(1,1) / 100;
    TruePercent(2,i) = TrueCount(2,1) / 100;
    TruePercent(3,i) = TrueCount(3,1) / 100;
    
end
figure(1)
plot(ArrayNum,TruePercent(1,:),'-*',ArrayNum,TruePercent(2,:),'-o',ArrayNum,TruePercent(3,:),'-x')
l = legend('AIC','MDL','HQ');
title('信息论准则性能与阵元数的关系')
xlabel('阵元数');
ylabel('成功率');
%% profiler
% profile viewer
% profile off
toc