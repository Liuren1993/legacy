classdef CommonRadarArray
    % CommonRadarArray is a class of the simplest radar pattern Array
    %   it contains what the class CommonRadar contans:
    %     1.the RCS of the target                            (m^2)
    %     2.the system loss of the radar                     (None)
    %   and inherits from CommonTransmitter:
    %     1.the Positon information of the transmitter(2-D)  (Km)  
    %     2.the average power transmitted by the transmitter (Watt)
    %     3.the transmitter antenna gain                     (None)
    %     4.the ERP of the transmitter                       (Watt)
    %     5.the Frequency of the transmitted waveform        (GHz)
    %     6.the Wavelength of the transmitted waveform       (m)
    %   and inherits from CommonReceiver:
    %     1.the Positon information of the Receiver(2-D)     (Km)
    %     2.the receiver antenna gain                        (None)  
    %     3.the bandwidth of the receiver                    (Hz)
    %     4.the noise temperature of the receiver            (K)
    %     5.the noise figure of the receiver                 (None)
    %
%%
    properties
        RadarArray
    end
%%    
    methods
        %*************** Constructor **********************************
        function obj = CommonRadarArray(commonradararray)
            if nargin == 0
                
            else
                m = size(commonradararray,1);
                n = size(commonradararray,2);
                obj(m,n) = CommonRadarArray; % Preallocate object array
                for i = 1:m
                   for j = 1:n
                      obj(i,j).RadarArray = commonradararray(i,j);
                   end
                end
               
            end
            
        end        
    end
    
end

