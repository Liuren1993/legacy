classdef WaveformTypical < SequenceSin
    % WaveformTypical is a class for gernerating a typical waveform model.
    % A(t)*sin( CapOmega*t + Theta(t) )
    %   mainly for inherit
    % it contains:
    %    Input Variables:
    %    1.AmplitudeMod -Amplitude modulation of the RF carriar; Vector
    %    2.ThetaMod -Phase or Frequence modulation of the carriar; Vector
    %    3.CapOmega -The RF carriar frequence in radians per second; it can be a scalar or a vector
    %    4.TimeScope -The time scope of the waveform; it's a vector with two slots : [Start,End]
    %    5.TimeDelta -The Sample interval of the the discrete waveform; Scalar
    %    --Constant 
    %    1.CDRatio -The Ratio of length(TimeAxis) and length(DiscreteTimeAxis)    
    %    --Varibles
    %    1.TimeSlice -The number of the Slices of the time scope;  be tied by TimeDelta 
    %    2.Frequency -The RF carriar frequence in Hz
    %    3.TypWaveform -Typical transmitted waveform 
    %    4.TimeAxis 
    %    5.TypWaveformSample -Samples of the Typical transmitted waveform 
    %    6.DiscreteTimeAxis
    %
    % History:
    % ---Original Version by Gnimuc 2013/6/25
    %
    %%
    properties( Dependent = true )
        %************* Mutual Dependent Variables ***********
        AmplitudeMod = 1;  % be tied by Amplitude_Sin
        ThetaMod = 0;      % be tied by Phi_Sin
        CapOmega = 2*pi;   % be tied by OmegaZero_Sin
        Frequency = 1;     % be tied by Frequency_Sin
        
    end
    properties( Dependent = true , SetAccess = private )
        %********** Dependent and Private Variables **********
        TypWaveformSample = zeros(0,0);              
        DiscreteTimeAxis = zeros(0,0);         
        TypWaveform = zeros(0,0);          
        TimeAxis = zeros(0,0);           
        
    end
    %%
    methods
        %******************************************************************
        %************** Restricting Mutual Dependent Varibales ************
        %******************************************************************
        function obj = set.AmplitudeMod(obj,amplitudemod)
            lenX = length(obj.AxisX4ConSinSeq);
            if length(amplitudemod)~=lenX
                error('the length of AmplitudeMod must be equal to the length of TimeAxis ')
            else
                obj.Amplitude_Sin = amplitudemod ;
            end
            
        end
        function amplitudemod = get.AmplitudeMod(obj)
            amplitudemod = obj.Amplitude_Sin;
            
        end
        
        function obj = set.ThetaMod(obj,thetamod)
            lenX = length(obj.AxisX4ConSinSeq);
            if length(thetamod)~=lenX
                error('the length of ThetaMod must be equal to the length of TimeAxis ')
            else
                obj.Phi_Sin = thetamod;
            end

        end
        function thetamod = get.ThetaMod(obj)
            thetamod = obj.Phi_Sin;
            
        end
        
        function obj = set.CapOmega(obj,capomega)
            obj.OmegaZero_Sin = capomega;
            
        end
        function capomega = get.CapOmega(obj)
            capomega = obj.OmegaZero_Sin;
            
        end
        
        function obj = set.Frequency(obj,frequency)
            obj.Frequency_Sin = frequency;
            
        end
        function capomega = get.Frequency(obj)
            capomega = obj.Frequency_Sin;
            
        end
        %**************************************************************************
        %*************** Restricting Dependent and Private Variables **************
        %**************************************************************************
        function typwaveformsample = get.TypWaveformSample(obj)
            typwaveformsample = obj.SinSequence;
            
        end
        function discretetimeaxis = get.DiscreteTimeAxis(obj)
            discretetimeaxis = obj.AxisX4SinSeq;
            
        end
        function typwaveform = get.TypWaveform(obj)
            typwaveform = obj.Con_SinSequence;
            
        end
        function timeaxis = get.TimeAxis(obj)
            timeaxis = obj.AxisX4ConSinSeq;
            
        end
        %******************************************************************
        %************************** Constructor ***************************
        %******************************************************************
        function obj = WaveformTypical(amplitudemod,frequency,thetamod,...
                timescope,timedelta)
            if nargin == 0
                super_SequenceSin = {};
                
            else
                super_SequenceSin{1} = amplitudemod;
                super_SequenceSin{2} = frequency;
                super_SequenceSin{3} = thetamod ;
                super_SequenceSin{4} = timescope;
                super_SequenceSin{5} = timedelta;
                
            end
            obj = obj@SequenceSin(super_SequenceSin{:});
            
            if nargin > 0
                
                
            end
            
        end %end of function
        
    end %end of methods
    
end

