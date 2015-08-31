classdef CommonTransmitter
    % CommonTransmitter is a class of the simplest transmitter pattern
    %  it contains:
    %     1.the Positon information of the transmitter(2-D)  (Km)
    %     2.the average power transmitted by the transmitter (Watt)
    %     3.the transmitter antenna gain                     (None)
    %     4.the ERP of the transmitter                       (Watt)
    %     5.the Frequency of the transmitted waveform        (GHz)
    %     6.the Wavelength of the transmitted waveform       (m)
    %
%%
    properties
        %************* Position *************
        TransmitterPositionX = 0;       % Km
        TransmitterPositionY = 0;       % Km
        %************* Variables *************
        PowerAVG = 0;              % Watt
        Gain_Transmitter = 0;      % None
        Frequency = 1;             % GHz
        
    end
    
    properties( Dependent = true , SetAccess = private )
        %************* Dependent Variables *******
        ERP = 0;             % Watt
        Lambda = 0;          % m
    end
%%
    methods
        %*************** Restricting Dependent Variables **************
        function ERP = get.ERP(obj)
            ERP = obj.PowerAVG * obj.Gain_Transmitter;
            
        end
        
        function Lambda = get.Lambda(obj)
            Lambda = (3*10^8)/(obj.Frequency*10^9);
            
        end
        
        %********** Restricting Properties to Specific Values **********
        function obj = set.TransmitterPositionX(obj,transmittercoordinateX)
            obj.TransmitterPositionX = transmittercoordinateX;
            
        end
        
        function obj = set.TransmitterPositionY(obj,transmittercoordinateY)
            obj.TransmitterPositionY = transmittercoordinateY;
            
        end
        
        function obj = set.PowerAVG(obj,avg_power)
            if (avg_power < 0)
                error('the average power of the transmitter must be positive!')
            end
            obj.PowerAVG = avg_power;
            
        end
        
        function obj = set.Gain_Transmitter(obj,transmitter_gain)
            if (transmitter_gain < 0)
                error('the transmitter antenna gain must be positive!')
            end
            obj.Gain_Transmitter = transmitter_gain;
            
        end
        function obj = set.Frequency(obj,frequency)
            if (frequency < 0)
                error('the waveform Frequency must be positive!')
            end
            obj.Frequency = frequency;
            
        end
        %*************** Constructor **********************************
        function obj = CommonTransmitter(transmittercoordinateX,transmittercoordinateY,...
                avg_power,transmitter_gain,frequency)
            if nargin == 0
                
            else
                if (transmitter_gain < 0)
                    error('the transmitter antenna gain must be positive!')
                end
                if (avg_power < 0)
                    error('the average power of the transmitter must be positive!')
                end
                if (frequency < 0)
                    error('the waveform Frequency must be positive!')
                end
                obj.TransmitterPositionX = transmittercoordinateX;
                obj.TransmitterPositionY = transmittercoordinateY;
                obj.PowerAVG = avg_power;
                obj.Gain_Transmitter = transmitter_gain;
                obj.Frequency = frequency;
            end
            
            
        end
        
    end
    
    
    
    
end

