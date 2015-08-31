classdef CommonReceiver
    % CommonReceiver is a class of the simplest Receiver pattern
    %  it contains:
    %     1.the Positon information of the Receiver(2-D)     (Km)
    %     2.the receiver antenna gain                        (None)
    %     3.the bandwidth of the receiver                    (Hz)
    %     4.the noise temperature of the receiver            (K)
    %     5.the noise figure of the receiver                 (None)
    %
%%
    properties
        %************* Position *************
        ReceiverPositionX = 0;          % Km
        ReceiverPositionY = 0;          % Km
        %************* Variables *************
        Gain_Receiver = 0;      % None
        BandWidth = 1;          % Hz
        NoiseTemperature = 290; % K
        NoiseFigure = 1;        % None
        
    end
%%
    methods
        %********** Restricting Properties to Specific Values **********
        function obj = set.ReceiverPositionX(obj,receivercoordinateX)
            obj.ReceiverPositionX = receivercoordinateX;
            
        end
        function obj = set.ReceiverPositionY(obj,receivercoordinateY)
            obj.ReceiverPositionY = receivercoordinateY;
            
        end
        function obj = set.Gain_Receiver(obj,receiver_gain)
            if (receiver_gain < 0)
                error('the receiver antenna gain must be positive!')
            end
            obj.Gain_Receiver = receiver_gain;
            
        end
        function obj = set.BandWidth(obj,bandwidth)
            if (bandwidth < 0)
                error('the bandwidth of the receiver must be positive!')
            end
            obj.BandWidth = bandwidth;
            
        end
        function obj = set.NoiseTemperature(obj,noisetemperature)
            if (noisetemperature < 0)
                error('the noise temperature of the receiver must be positive!')
            end
            obj.NoiseTemperature = noisetemperature;
            
        end
        function obj = set.NoiseFigure(obj,noisefigure)
            if (noisefigure < 0)
                error('the noise figure of the receiver must be positive!')
            end
            obj.NoiseFigure = noisefigure;
            
        end
        %*************** Constructor **********************************
        function obj = CommonReceiver(receivercoordinateX,receivercoordinateY,...
                receiver_gain,bandwidth,noisetemperature,noisefigure)
            
            if nargin == 0
                
            else
                
                if (receiver_gain < 0)
                    error('the receiver antenna gain must be positive!')
                end
                if (bandwidth < 0)
                    error('the bandwidth of the receiver must be positive!')
                end
                if (noisetemperature < 0)
                    error('the noise temperature of the receiver must be positive!')
                end
                if (noisefigure < 0)
                    error('the noise figure of the receiver must be positive!')
                end
                obj.ReceiverPositionX = receivercoordinateX;
                obj.ReceiverPositionY = receivercoordinateY;
                obj.Gain_Receiver = receiver_gain;
                obj.BandWidth = bandwidth;
                obj.NoiseTemperature = noisetemperature;
                obj.NoiseFigure = noisefigure;
                
            end
            
        end
        
    end
    
end

