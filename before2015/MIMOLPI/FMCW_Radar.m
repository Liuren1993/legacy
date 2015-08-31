classdef FMCW_Radar < CommonRadar
    % FMCW_Radar is a class of the Frequency Modulated Continuous Waveform Radar
    %   it contains:
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
        %************* Variables *************        
        CompressRatio = 1;      %(None)
        
    end
%%
    methods
        %********** Restricting Properties to Specific Values **********
        function obj = set.CompressRatio(obj,compressratio)
            if (compressratio < 0)
                error('the CompressRatio of the radar must be positive!')
            end
            obj.CompressRatio = compressratio;
            
        end
       %*************** Constructor **********************************
        function obj = FMCW_Radar(TrcoordinateX,TrcoordinateY,avg_power,...
                transmitter_gain,frequency,RecoordinateX,RecoordinateY,receiver_gain,...
                bandwidth,noisetemperature,noisefigure,rcs,loss,compressratio)
             if nargin == 0
                super_CommonRadar_args = {};

             else
                super_CommonRadar_args{1} = TrcoordinateX;
                super_CommonRadar_args{2} = TrcoordinateY;
                super_CommonRadar_args{3} = avg_power;
                super_CommonRadar_args{4} = transmitter_gain;
                super_CommonRadar_args{5} = frequency;
                super_CommonRadar_args{6} = RecoordinateX;
                super_CommonRadar_args{7} = RecoordinateY;
                super_CommonRadar_args{8} = receiver_gain;
                super_CommonRadar_args{9} = bandwidth;
                super_CommonRadar_args{10} = noisetemperature;
                super_CommonRadar_args{11} = noisefigure;   
                super_CommonRadar_args{12} = rcs; 
                super_CommonRadar_args{13} = loss; 
             end
             obj = obj@CommonRadar(super_CommonRadar_args{:});
             if nargin > 0
                if (compressratio < 0)
                   error('the CompressRatio of the radar must be positive!')
                end 
                obj.CompressRatio = compressratio;
                
             end
         
        end        
    end
    
end

