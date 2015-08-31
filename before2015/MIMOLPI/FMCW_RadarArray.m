classdef FMCW_RadarArray
    % FMCW_RadarArray is a class of the FMCW radar array
    %   it contains what the class FMCW_Radar contains:
    %     1.the Compress Ratio of the radar                  (None)  
    %   and inherits from CommonRadar:
    %     1.the RCS of the target                            (m^2)
    %     2.the system loss of the radar                     (None)
    %     1.the Positon information of the transmitter(2-D)  (Km)  
    %     2.the average power transmitted by the transmitter (Watt)
    %     3.the transmitter antenna gain                     (None)
    %     4.the ERP of the transmitter                       (Watt)
    %     5.the Frequency of the transmitted waveform        (GHz)
    %     6.the Wavelength of the transmitted waveform       (m)    
    %     1.the Positon information of the Receiver(2-D)     (Km)
    %     2.the receiver antenna gain                        (None)  
    %     3.the bandwidth of the receiver                    (Hz)
    %     4.the noise temperature of the receiver            (K)
    %     5.the noise figure of the receiver                 (None)
    %
%%
    properties
        FMCWRadarArray        
    end
%%    
    methods
        %*************** Constructor **********************************
        function obj = FMCW_RadarArray(fmcwradararray)
            if nargin == 0
                
            else
                m = size(fmcwradararray,1);
                n = size(fmcwradararray,2);
%               obj(m,n) = FMCW_RadarArray; % Preallocate object array
                for i = 1:m
                   for j = 1:n
                      obj(i,j).FMCWRadarArray = fmcwradararray(i,j);
                   end
                end
               
            end
            
        end               
    end
    
end

