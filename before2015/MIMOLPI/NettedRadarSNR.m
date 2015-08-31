classdef NettedRadarSNR
    % NettedRadarSNR calculates the countour graph of the netted Radar's SNR
    %   (very similar to RadarSNR)
    %   it contains:
    %     1. the resolution of the graph                   (None)
    %     2. the start of X axis                           (Km)
    %     3. the end of X axis                             (Km)
    %     4. the start of Y axis                           (Km)
    %     5. the end of Y axis                             (Km)
    %     6. the point interval of X axis                  (Km)
    %     7. the point interval of Y axis                  (Km)
    %     8. the RadiatedPowerSum which used to draw radiated power graph
    %     9.the SNR_Pond which used to draw SNR graph
    %     10.the Grid_X and Grid_Y give the meshgrid of X and Y
    %     11.the size of CommonRadarArray is [1,N]
    %   and calls:
    %     1.the Convert2dB which used to draw dB-graph or Mag-graph
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
        %*************** Graph ****************
        Resolution = 200;     % None
        XboundaryStart = 0;   % Km
        XboundaryEnd = 100;   % Km
        YboundaryStart = 0;   % Km
        YboundaryEnd = 100;   % Km
        %********** Variables *****************
        CommonRadarArray
        GraphPond = 0;
        
    end
    properties( Dependent = true , SetAccess = private )
        %********** Dependent Variables *******
        XPointInterval = 0;   % Km
        YPointInterval = 0;   % Km
        RadiatedPowerSum = 0;
        SNR_Pond = 0;
        Grid_X = 0;
        Grid_Y = 0;
    end
    
%%
    methods
        %*************** Restricting Dependent Variables **************
        function GraphPond = get.GraphPond(obj)
            GraphPond = zeros( obj.Resolution , obj.Resolution);
            
        end
        function XPointInterval = get.XPointInterval(obj)
            XPointInterval = ( obj.XboundaryEnd - obj.XboundaryStart ) /...
                obj.Resolution;
            
        end
        function YPointInterval = get.YPointInterval(obj)
            YPointInterval = ( obj.YboundaryEnd - obj.YboundaryStart ) /...
                obj.Resolution;
            
        end
        function Grid_X = get.Grid_X(obj)
            [X,~] = meshgrid(obj.XboundaryStart+obj.XPointInterval : obj.XPointInterval: obj.XboundaryEnd ,...
                obj.YboundaryStart+obj.YPointInterval : obj.YPointInterval : obj.YboundaryEnd );
            Grid_X = X;
        end
        function Grid_Y = get.Grid_Y(obj)
            [~,Y] = meshgrid(obj.XboundaryStart+obj.XPointInterval : obj.XPointInterval: obj.XboundaryEnd ,...
                obj.YboundaryStart+obj.YPointInterval : obj.YPointInterval : obj.YboundaryEnd );
            Grid_Y = Y;
        end
        function RadiatedPowerSum = get.RadiatedPowerSum(obj)
            CRArray = obj.CommonRadarArray;
            TransmitterNumber = size(CRArray,2);
            XboundaryS = obj.XboundaryStart;
            YboundaryS = obj.YboundaryStart;
            resolution = obj.Resolution;
            XPointInterval = obj.XPointInterval;
            YPointInterval = obj.YPointInterval;
            RadiatedPowerSum = zeros( resolution , resolution );
            
            for k = 1 : TransmitterNumber
                TransmitterPositionX = CRArray(1,k).RadarArray.TransmitterPositionX;
                TransmitterPositionY = CRArray(1,k).RadarArray.TransmitterPositionY;
                ERP = CRArray(1,k).RadarArray.ERP;
                for m = 1 : resolution
                    for n = 1 : resolution    % go though everypoint
                        % R(Km) = [ (X1-X2)^2 + (Y1-Y2)^2 ] ^ 0.5
                        range = ( (TransmitterPositionX - (XboundaryS +...
                            m*XPointInterval) )^2 +(TransmitterPositionY -...
                            (YboundaryS + n*YPointInterval))^2 )^0.5;
                        ExtremenValue = ( XPointInterval + YPointInterval)/4;
                        range = max( range , ExtremenValue ) ;
                        % power of point(m,n) by the transmitter
                        PowerOfCertainPoint = ERP / ( 4*pi*(range * 1000)^2 ) ;
                        RadiatedPowerSum(m,n) = PowerOfCertainPoint + RadiatedPowerSum(m,n);
                        
                    end
                end
            end
            
        end
        function SNR_Pond = get.SNR_Pond(obj)
            CRArray = obj.CommonRadarArray;
            ReceiverNumber = size(CRArray,2);
            XboundaryS = obj.XboundaryStart;
            YboundaryS = obj.YboundaryStart;
            resolution = obj.Resolution;
            XPointInterval = obj.XPointInterval;
            YPointInterval = obj.YPointInterval;
            RadiatedPowerSum = obj.RadiatedPowerSum;
            Pond = zeros( resolution , resolution );
            for k = 1 : ReceiverNumber
                ReceiverPositionX = CRArray(1,k).RadarArray.ReceiverPositionX;
                ReceiverPositionY = CRArray(1,k).RadarArray.ReceiverPositionY;
                Gain_Receiver = CRArray(1,k).RadarArray.Gain_Receiver;         % None
                BandWidth = CRArray(1,k).RadarArray.BandWidth;                 % Hz
                NoiseTemperature = CRArray(1,k).RadarArray.NoiseTemperature;   % K
                NoiseFigure = CRArray(1,k).RadarArray.NoiseFigure;             % None
                Lambda = CRArray(1,k).RadarArray.Lambda;                       % m
                RCS = CRArray(1,k).RadarArray.RCS;                             % m^2
                Loss = CRArray(1,k).RadarArray.Loss;                           % None
                ConstantK = 1.38*10^-23;                                       % J/K
                for m = 1 : resolution
                    for n = 1 : resolution    % go though everypoint
                        % R(Km) = [ (X1-X2)^2 + (Y1-Y2)^2 ] ^ 0.5
                        range = (( ReceiverPositionX - (XboundaryS + m*XPointInterval))^2 +...
                            ( ReceiverPositionY - (YboundaryS + n*YPointInterval) )^2 )^0.5;
                        ExtremenValue = ( XPointInterval + YPointInterval)/4;
                        range = max( range ,  ExtremenValue );
                        % Received power of point(m,n) by the receiver
                        PowerOfCertainPoint = RadiatedPowerSum(m,n) / ( 4*pi*(range * 1000)^2 ) ;
                        parameters = (Gain_Receiver*RCS*(Lambda)^2) /...
                            (4*pi*ConstantK*NoiseTemperature*BandWidth*NoiseFigure*Loss);
                        Pond(m,n) = (PowerOfCertainPoint*parameters) + Pond(m,n);
                    end
                end
            end
            SNR_Pond = Pond;
        end
        
        %********** Restricting Properties to Specific Values **********
        function obj = set.Resolution(obj,resolution)
            if (resolution < 0)
                error('the Resolution of the Graph must be positive!')
            end
            obj.Resolution = resolution;
            
        end
        function obj = set.XboundaryStart(obj,Xboundarystart)
            obj.XboundaryStart = Xboundarystart;
            
        end
        function obj = set.XboundaryEnd(obj,Xboundaryend)
            obj.XboundaryEnd = Xboundaryend;
            
        end
        function obj = set.YboundaryStart(obj,Yboundarystart)
            obj.YboundaryStart = Yboundarystart;
            
        end
        function obj = set.YboundaryEnd(obj,Yboundaryend)
            obj.YboundaryEnd = Yboundaryend;
            
        end
        function obj = set.CommonRadarArray(obj,commonradararray)
            obj.CommonRadarArray = commonradararray;
            
        end
        %*************** Constructor **********************************
        function obj = NettedRadarSNR(resolution,Xboundarystart,Xboundaryend,...
                Yboundarystart,Yboundaryend,commonradararray)
            if nargin == 0
                
            else
                obj.Resolution = resolution;
                obj.XboundaryStart = Xboundarystart;
                obj.XboundaryEnd = Xboundaryend;
                obj.YboundaryStart = Yboundarystart;
                obj.YboundaryEnd = Yboundaryend;
                obj.CommonRadarArray = commonradararray;
                
            end
            
        end
  
    end
%% Calls
    methods
        %************* Convert value to dB or not **********************
        function GraphPond = Convert2dB(obj, option)
            SNR_Pond = obj.SNR_Pond;
            if strcmp(option,'Mag')
                GraphPond = obj.SNR_Pond;
            end
            if strcmp(option,'LogdB')
                ExtremeValue = 1E-50;
                SNR_Pond( SNR_Pond<ExtremeValue) = 0;
                GraphPond = 10*log10(SNR_Pond);
            end
            
        end
    end
    
end

