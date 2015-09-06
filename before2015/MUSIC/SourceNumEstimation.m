classdef SourceNumEstimation
    %%
    properties
        %************* Variables *************
        LinearArrayNum = 12;
        SignalArray = zeros(3,1);
        Lamda = 1;
        Azimuth = zeros(1,3);
        NoisePower = 1;
        
    end
    properties( Dependent = true , SetAccess = private)  %   % hide properties in subclass
        %********** Dependent and Private Variables **********
        SignalLen = 0;        % Dependent on SignalArray
        SignalNum = 0;        % Dependent on SignalArray
        ArrayInterval =0.5;   % Dependent on lamda
        MatrixA = zeros(8,3);
        MatrixN = zeros(8,3);
        MatrixX = zeros(8,3);
        MatrixR = zeros(8,3);
        
    end
    properties( Dependent = true , SetAccess = private , Hidden = true)
        %********** Hidden Variables **********
        
    end
    %%
    methods
        %**************************************************************************
        %*************** Restricting Dependent and Private Variables **************
        %**************************************************************************
        function SignalNum = get.SignalNum(obj)
            [r,~] = size(obj.SignalArray);
            SignalNum = r ;
            
        end
        function SignalLen = get.SignalLen(obj)
            [~,c] = size(obj.SignalArray);
            SignalLen = c ;
            
        end
        function ArrayInterval = get.ArrayInterval(obj)
            ArrayInterval = 1/2 * obj.Lamda ;
            
        end
        function MatrixA = get.MatrixA(obj)
            lamda = obj.Lamda;
            len = obj.LinearArrayNum;
            theta = obj.Azimuth;
            d = obj.ArrayInterval;
            MatrixA = exp(-1j*2*pi/lamda*(0:len-1)'*d*sin(theta));
            
        end
        function MatrixN = get.MatrixN(obj)
            len = obj.LinearArrayNum;
            slen = obj.SignalLen;
            Repart = randn(len,slen);
            Imgpart = randn(len,slen);
            MatrixN = Repart + 1j*Imgpart;
            
        end
        function MatrixX = get.MatrixX(obj)
            A = obj.MatrixA;
            S = obj.SignalArray;
            noisepower = obj.NoisePower;
            N = obj.MatrixN;
            MatrixX = A * S + noisepower * N;
            
        end
        function MatrixR = get.MatrixR(obj)
            X = obj.MatrixX;
            len = obj.SignalLen;
            MatrixR = X*X' / len ;
            
        end
        %******************************************************************
        %********** Restricting Properties to Specific Values *************
        %******************************************************************
        function obj = set.LinearArrayNum(obj,lineararraynumber)
            obj.LinearArrayNum = lineararraynumber ;
            
        end
        function obj = set.SignalArray(obj,signalarray)
            obj.SignalArray = signalarray ;
            
        end
        function obj = set.Lamda(obj,lamda)
            obj.Lamda = lamda ;
            
        end
        function obj = set.Azimuth(obj,azimuth)
            obj.Azimuth = azimuth ;
            
        end
        function obj = set.NoisePower(obj,niosepower)
            obj.NoisePower = niosepower ;
            
        end
        %******************************************************************
        %************************** Constructor ***************************
        %******************************************************************
        function obj = SourceNumEstimation
            if nargin == 0
                
            else
                
            end %end of if
            
            
        end %end of function
    end
    %% Calls
    methods
        function [SENum,MDL,HQ] = Trial(obj)
            Rx = obj.MatrixR;
            LAN = obj.LinearArrayNum;
            len = obj.SignalLen;
            %             d = obj.ArrayInterval;
            %             lamda = obj.Lamda;
            [~,D]=eig(Rx);  %[V,D]=eig(Rx);
            %             [~,index] = sort((diag(D)));
            %信息论方法AIC准则
            AIC = zeros(1,LAN);
            MDL = zeros(1,LAN);
            HQ = zeros(1,LAN);
            [lambda,~]=sort(diag(D),'descend');
            for k=0:LAN-1
                up=sum(lambda(k+1:LAN))/(LAN-k);
                down=prod(lambda(k+1:LAN))^(1/(LAN-k));
                GreekA=up/down;
                AIC(k+1)=2*len*(LAN-k)*log10(GreekA)+k*(2*LAN-k);
                MDL(k+1)=2*len*(LAN-k)*log10(GreekA)+0.5*k*(2*LAN-k)*log10(len);
                HQ(k+1)=2*len*(LAN-k)*log10(GreekA)+0.5*k*(2*LAN-k)*log(log(len));
            end
            [~,SENum] = min(AIC);
            [~,MDL] = min(MDL);
            [~,HQ] = min(HQ);
            SENum = SENum - 1;
            MDL = MDL - 1;
            HQ = HQ - 1;
            %MUSIC搜索
            %             Us=V(:,index(1:SENum));
            %             theta=-pi/2:pi/180:pi/2;
            %             Pmusic = zeros(length(theta));
            %             MUSICSteer=exp(-1j*2*pi/lamda*([0:LAN-1]'*d)*sin(theta));
            %             for m = 1:length(theta)
            %                 Pmusic(m)=1/((MUSICSteer(:,m)'* (Us*Us') * MUSICSteer(:,m)));
            %             end
            %             Pmusic = 10*log10(abs(Pmusic)/max(abs(Pmusic)));%
            %             figure(1)
            %             plot(theta*180/pi,Pmusic);title('入射角估计')
            %             xlabel('方位角（°）')
            %             ylabel('MUSIC谱（dB）')
            
        end
        
    end %end of methods
end

