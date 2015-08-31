classdef LPI_NettedSystemSNR < FMCW_NettedSystemSNR
    % LPI_NettedSystemSNR calculates the countour graph of the beta
    %
%%
    properties
        ESMRadarArray
        BetaPond = 0;
    end
    properties( Dependent = true , SetAccess = private )
        %********** Dependent Variables *******
        RadiatedPower2ESM = 0;
        RadiatedPower2Re = 0;
        beta = 0;
        
    end
%%
    methods
        %*************** Restricting Dependent Variables **************
        function beta = get.beta(obj)
            TrArray = obj.NettedTransmitterArray;
            ReArray = obj.NettedReceiverArray;
            ESMArray = obj.ESMRadarArray;
            TrArray(1) = [];
            ReArray(1) = [];
            ESMArray(1) = [];
            ESMRe_Gain = ESMArray(1).FMCWRadarArray.Gain_Receiver;
            %             ESMTr_Gain = ESMArray(1).FMCWRadarArray.Gain_Transmitter;
            ESMLoss = ESMArray(1).FMCWRadarArray.Loss;
            ESMBandwidth = ESMArray(1).FMCWRadarArray.BandWidth;
            ESMNioseFigure = ESMArray(1).FMCWRadarArray.NoiseFigure;
            ESMNoiseTemperature = ESMArray(1).FMCWRadarArray.NoiseTemperature;
            %             ESMCompressRatio = ESMArray(1).FMCWRadarArray.CompressRatio;
            
            TransmitterNumber = size(TrArray,2);
            ReceiverNumber = size(ReArray,2);
            XboundaryS = obj.XboundaryStart;
            YboundaryS = obj.YboundaryStart;
            resolution = obj.Resolution;
            XPointInterval = obj.XPointInterval;
            YPointInterval = obj.YPointInterval;
            beta = zeros( resolution , resolution );
            TransmitterPositionX = zeros(1,TransmitterNumber);
            TransmitterPositionY = zeros(1,TransmitterNumber);
            ERParray = zeros(1,TransmitterNumber);
            Tr_Gainarray = zeros(1,TransmitterNumber);
            
            ReceiverPositionX = zeros(1,ReceiverNumber);
            ReceiverPositionY = zeros(1,ReceiverNumber);
            Re_Gainarray = zeros(1,ReceiverNumber);
            Lossarray = zeros(1,ReceiverNumber);
            Bandwidtharray = zeros(1,ReceiverNumber);
            NioseFigurearray = zeros(1,ReceiverNumber);
            NoiseTemperaturearray = zeros(1,ReceiverNumber);
            CompressRatioarray = zeros(1,ReceiverNumber);
            RCSarray = zeros(1,ReceiverNumber);
            
            for k = 1 : TransmitterNumber
                TransmitterPositionX(k) = TrArray(1,k).FMCWRadarArray.TransmitterPositionX;
                TransmitterPositionY(k)= TrArray(1,k).FMCWRadarArray.TransmitterPositionY;
                ERParray(k) = TrArray(1,k).FMCWRadarArray.ERP;
                Tr_Gainarray(k) = TrArray(1,k).FMCWRadarArray.Gain_Transmitter;
            end
            for k = 1 : ReceiverNumber
                ReceiverPositionX(k) = ReArray(1,k).FMCWRadarArray.ReceiverPositionX;
                ReceiverPositionY(k) = ReArray(1,k).FMCWRadarArray.ReceiverPositionY;
                Re_Gainarray(k) = ReArray(1,k).FMCWRadarArray.Gain_Receiver;
                Lossarray(k) = ReArray(1,k).FMCWRadarArray.Loss;
                Bandwidtharray(k) = ReArray(1,k).FMCWRadarArray.BandWidth;
                NioseFigurearray(k) = ReArray(1,k).FMCWRadarArray.NoiseFigure;
                NoiseTemperaturearray(k) = ReArray(1,k).FMCWRadarArray.NoiseTemperature;
                CompressRatioarray(k) = ReArray(1,k).FMCWRadarArray.CompressRatio;
                RCSarray(k) = ReArray(1,k).FMCWRadarArray.RCS;
                
            end
            
            MinTrNum = zeros(resolution,resolution);
            MinReNum = zeros(resolution,resolution);
            ReceiverRange = zeros(resolution,resolution);
            for m = 1 : resolution
                for n = 1 : resolution    % go though everypoint
                    TrangeTemp = 10000000;
                    RrangeTemp = 10000000;
                    MinTrNumTemp = 0;
                    MinReNumTemp = 0;
                    ReceiverRangeMinTemp = 0;
                    
                    for k = 1 : TransmitterNumber
                        % R(Km) = [ (X1-X2)^2 + (Y1-Y2)^2 ] ^ 0.5
                        range = ( ((XboundaryS + m*XPointInterval ) - TransmitterPositionX(k))^2 +...
                            ((YboundaryS + n*YPointInterval ) - TransmitterPositionY(k))^2  )^0.5;
                        if (range <= TrangeTemp)
                            TrangeTemp = range ;
                            MinTrNumTemp = k;
                        end
                    end
                    for k = 1 : ReceiverNumber
                        % R(Km) = [ (X1-X2)^2 + (Y1-Y2)^2 ] ^ 0.5
                        range = (  ((XboundaryS + m*XPointInterval ) - ReceiverPositionX(k))^2 +...
                            ((YboundaryS + n*YPointInterval ) - ReceiverPositionY(k))^2   )^0.5;
                        if (range <= RrangeTemp)
                            RrangeTemp = range ;
                            MinReNumTemp = k;
                        end
                        ReceiverRangeMinTemp = RrangeTemp;
                    end
                    MinTrNum(m,n) = MinTrNumTemp;
                    MinReNum(m,n) = MinReNumTemp;
                    ReceiverRange(m,n) = ReceiverRangeMinTemp;
                end
            end
            for m = 1 : resolution
                for n = 1 : resolution    % go though everypoint
                    ERPmin = ERParray(MinTrNum(m,n));
                    ERPall = sum(ERParray);
                    Re_Gain = Re_Gainarray(MinReNum(m,n));
                    %Tr_Gain = Tr_Gainarray(MinTrNum(m,n));
                    Loss = Lossarray(MinReNum(m,n));
                    Bandwidth = Bandwidtharray(MinReNum(m,n));
                    NioseFigure = NioseFigurearray(MinReNum(m,n));
                    NoiseTemperature = NoiseTemperaturearray(MinReNum(m,n));
                    % CompressRatio = CompressRatioarray(MinReNum(m,n));
                    RCS = RCSarray(MinReNum(m,n));
                    
                    parameterUp = 4*pi*...
                        ESMRe_Gain*Loss*Bandwidth*NioseFigure*NoiseTemperature;
                    % CompressRatio**ESMCompressRatio*Tr_Gain*ESMTr_Gain*ERPmin*ERPall
                    parameterDown =Re_Gain*RCS*ESMBandwidth*...
                        ESMNioseFigure*ESMNoiseTemperature*ESMLoss;
                    
                    beta(m,n) = ReceiverRange(m,n)*1000*(parameterUp/parameterDown)^0.5;
                    
                    
                end
            end
        end
        
        %*************** Constructor **********************************
        function obj = LPI_NettedSystemSNR(resolution,Xboundarystart,Xboundaryend,...
                Yboundarystart,Yboundaryend,trradararray,reradararray,esmradararry)
            if nargin == 0
                super_FMCW_NettedSystemSNR_args = {};
            else
                super_FMCW_NettedSystemSNR_args{1} = resolution;
                super_FMCW_NettedSystemSNR_args{2} = Xboundarystart;
                super_FMCW_NettedSystemSNR_args{3} = Xboundaryend;
                super_FMCW_NettedSystemSNR_args{4} = Yboundarystart;
                super_FMCW_NettedSystemSNR_args{5} = Yboundaryend;
                super_FMCW_NettedSystemSNR_args{6} = trradararray;
                super_FMCW_NettedSystemSNR_args{7} = reradararray;
            end
            obj = obj@FMCW_NettedSystemSNR(super_FMCW_NettedSystemSNR_args{:});
            if nargin > 0
                obj.ESMRadarArray = esmradararry;
            end
        end
    end
%% Calls
    methods
        %************* Convert value to dB or not **********************
        function BetaPond = Convert2dB(obj, option)
            beta = obj.beta;
            if strcmp(option,'Mag')
                BetaPond = obj.beta;
            end
            if strcmp(option,'LogdB')
                ExtremeValue = 1E-50;
                beta( beta<ExtremeValue) = 0;
                BetaPond = 10*log10(beta);
            end
            
        end
    end
    
    
    
end

