classdef RadarSNR < CommonRadar
    % RadarSNR calculates the countour graph of the Radar's SNR
    %   it contains:
    %     1. the resolution of the graph                   (None)
    %     2. the start of X axis                           (Km)
    %     3. the end of X axis                             (Km)
    %     4. the start of Y axis                           (Km)
    %     5. the end of Y axis                             (Km)
    %     6. the point interval of X axis                  (Km)
    %     7. the point interval of Y axis                  (Km)
    %     8. the RadiatedPower which used to draw radiated power graph
    %     9.the ReceivedPower which used to draw received power graph
    %     10.the SNR_Pond which used to draw SNR graph
    %     11.the Grid_X and Grid_Y give the meshgrid of X and Y
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
        GraphPond = 0;
        
    end
    properties( Dependent = true , SetAccess = private )
        %********** Dependent Variables *******
        XPointInterval = 0;   % Km
        YPointInterval = 0;   % Km
        RadiatedPower = 0;
        ReceivedPower = 0;
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
        function RadiatedPower = get.RadiatedPower(obj)
            TransmitterPositionX = obj.TransmitterPositionX;
            XPointInterval = obj.XPointInterval;
            TransmitterPositionY = obj.TransmitterPositionY;
            YPointInterval = obj.YPointInterval;
            ERP = obj.ERP;
            XboundaryS = obj.XboundaryStart;
            YboundaryS = obj.YboundaryStart;
            resolution = obj.Resolution;
            RadiatedPower = zeros( resolution , resolution );
            
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
                    RadiatedPower(m,n) = PowerOfCertainPoint;
                    
                end
            end
            
        end
        function ReceivedPower = get.ReceivedPower(obj)
            ReceiverPositionX = obj.ReceiverPositionX;
            XPointInterval = obj.XPointInterval;
            ReceiverPositionY = obj.ReceiverPositionY;
            YPointInterval = obj.YPointInterval;
            XboundaryS = obj.XboundaryStart;
            YboundaryS = obj.YboundaryStart;
            resolution = obj.Resolution;
            RadiatedPower = obj.RadiatedPower;
            ReceivedPower = zeros( resolution , resolution );
            for m = 1 : resolution
                for n = 1 : resolution    % go though everypoint
                    % R(Km) = [ (X1-X2)^2 + (Y1-Y2)^2 ] ^ 0.5
                    range = (( ReceiverPositionX - (XboundaryS + m*XPointInterval))^2 +...
                        ( ReceiverPositionY - (YboundaryS + n*YPointInterval) )^2 )^0.5;
                    ExtremenValue = ( XPointInterval + YPointInterval)/4;
                    range = max( range ,  ExtremenValue );
                    % Received power of point(m,n) by the receiver
                    PowerOfCertainPoint = RadiatedPower(m,n) / ( 4*pi*(range * 1000)^2 ) ;
                    ReceivedPower(m,n) = PowerOfCertainPoint;
                end
            end
        end
        function SNR_Pond = get.SNR_Pond(obj)
            ReceivedPower = obj.ReceivedPower;         % Watt
            Gain_Receiver = obj.Gain_Receiver;         % None
            BandWidth = obj.BandWidth;                 % Hz
            NoiseTemperature = obj.NoiseTemperature;   % K
            NoiseFigure = obj.NoiseFigure;             % None
            Lambda = obj.Lambda;                       % m
            RCS = obj.RCS;                             % m^2
            Loss = obj.Loss;                           % None
            k = 1.38*10^-23;                           % J/K
            SNR_Pond = (ReceivedPower*Gain_Receiver*RCS*(Lambda)^2) /...
                (4*pi*k*NoiseTemperature*BandWidth*NoiseFigure*Loss);
            
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
        %*************** Constructor **********************************
        function obj = RadarSNR(TrcoordinateX,TrcoordinateY,avg_power,...
                transmitter_gain,frequency,RecoordinateX,RecoordinateY,receiver_gain,...
                bandwidth,noisetemperature,noisefigure,rcs,loss,resolution,...
                Xboundarystart,Xboundaryend,Yboundarystart,Yboundaryend)
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
                obj.Resolution = resolution;
                obj.XboundaryStart = Xboundarystart;
                obj.XboundaryEnd = Xboundaryend;
                obj.YboundaryStart = Yboundarystart;
                obj.YboundaryEnd = Yboundaryend;
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

