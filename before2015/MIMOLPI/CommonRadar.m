classdef CommonRadar < CommonTransmitter & CommonReceiver
    % CommonRadar is a class of the simplest Radar pattern
    %   it contains:
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
        %************* Variables *************
        RCS = 0;                % m^2
        Loss = 1;               % None
        
    end
%%    
    methods
        %********** Restricting Properties to Specific Values **********
        function obj = set.RCS(obj,rcs)
            if (rcs < 0)
                error('the RCS of the radar must be positive!')
            end
            obj.RCS = rcs;
            
        end
        function obj = set.Loss(obj,loss)
            if (loss < 0)
                error('the loss of the radar must be positive!')
            end
            obj.Loss = loss;
        end
        %*************** Constructor **********************************
        function obj = CommonRadar(TrcoordinateX,TrcoordinateY,avg_power,...
                transmitter_gain,frequency,RecoordinateX,RecoordinateY,receiver_gain,...
                bandwidth,noisetemperature,noisefigure,rcs,loss)
             if nargin == 0
                super_CommonTr_args = {};
                super_CommonRe_args = {};
             else
                super_CommonTr_args{1} = TrcoordinateX;
                super_CommonTr_args{2} = TrcoordinateY;
                super_CommonTr_args{3} = avg_power;
                super_CommonTr_args{4} = transmitter_gain;
                super_CommonTr_args{5} = frequency;
                super_CommonRe_args{1} = RecoordinateX;
                super_CommonRe_args{2} = RecoordinateY;
                super_CommonRe_args{3} = receiver_gain;
                super_CommonRe_args{4} = bandwidth;
                super_CommonRe_args{5} = noisetemperature;
                super_CommonRe_args{6} = noisefigure;    
             end
             obj = obj@CommonTransmitter(super_CommonTr_args{:});
             obj = obj@CommonReceiver(super_CommonRe_args{:});
             if nargin > 0
                if (rcs < 0)
                   error('the RCS of the radar must be positive!')
                end 
                if (loss < 0)
                   error('the loss of the radar must be positive!')
                end
                obj.RCS = rcs;
                obj.Loss = loss; 
             end
         
        end
        
    end
    
end

