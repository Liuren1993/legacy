classdef SequenceSin
    % SequenceSin is a class for gernerating sinusoidal sequences 
    % A(t)*sin( 2*pi*F(t)*t + Phi(t) )
    %   mainly for inherit
    % it contains:
    %    --Variables
    %    1.Amplitude_Sin the Amplitude of the sinusodial sequence; it can be a scalar or a vector 
    %    2.Frequency_Sin the Frequency of the sinusodial sequence; it can be a scalar or a vector
    %    3.Phi_Sin       the Phase of the sinusodial sequence; it can be a scalar or a vector
    %    4.TimeScope     the Time scope of the sinusodial sequence; it's a vector with two slots : [Start,End]
    %    5.TimeDelta     the Sample interval of the the Discrete sequence; Scalar
    %    --Constant 
    %    1.CDRatio       the Ratio of length(Continuous Sequence) and length(Discrete Sequence)
    %    --Dependent
    %    1.OmegaZero_Sin the Angular Frequency of the sinusodial sequence; it equals 2*pi*Frequency_Sin
    %    2.TimeSlice     the number of the Slices of the time scope;  be tied by TimeDelta 
    %    --Another private or hidden variables are not shown here.
    %
    % History:
    % ---Original Version by Gnimuc 2013/6/22
    % ---Version 0.1 by Gnimuc 2013/6/24
    % * use function "linspace" instead of the colon operator ':' 
    % * change 'Amplitude_Sin' 'Frequency_Sin' 'Phi_Sin' from scalar to vector in order to increase degree of freedom
    % ---Version 0.2 by Gnimuc 2013/6/25
    % * modify some functions for better code performance 
    % * hide some properties in subclass  
    %
    %%
    properties( Hidden = true ) %  % hide properties in subclass
        %************* Variables *************
        Amplitude_Sin = 1;       %
        Frequency_Sin = 1;       % Hz
        Phi_Sin = 0;             % radian
        
    end
    properties
        %************* Variables *************
        TimeScope = 0:1 ;        % s
        TimeDelta = 1e-2;        % s  
        
    end
    properties( Constant = true )
        %************* Constant *************  
        CDRatio = 100;      % the sample number of the "Continuous Sequence"(red) divided by that of the Discrete Sequence  
                              
    end
    properties( Dependent = true ) 
        %************* Mutual Dependent Variables ***********
        TimeSlice = 100;    % be tied by TimeDelta
        
    end
    properties( Dependent = true , Hidden = true ) %  % hide properties in subclass
        %************* Mutual Dependent Variables ***********
        OmegaZero_Sin = 0;  % be tied by Frequency_Sin % radian
       
        
    end
    properties( Dependent = true , SetAccess = private , Hidden = true)  %   % hide properties in subclass
        %********** Dependent and Private Variables **********
        Period_Sin = 1;                         % obviously the Reciprocal of Frequency_Sin
        SinSequence = zeros(0,0);               % Discrete Sequence 
        AxisX4SinSeq = zeros(0,0);              % Discrete Axis of the Discrete Sequence 
        Con_SinSequence = zeros(0,0);           % "Continuous Sequence" 
        AxisX4ConSinSeq = zeros(0,0);           % Discrete Axis (more points than Above) of the "Continuous Sequence" 
        
    end
    properties( Dependent = true , SetAccess = private , Hidden = true)
        %********** Hidden Variables **********
        H_SampleAmpSin = zeros(0,0);            % used for matching Discrete Sequence 
        H_SampleOmegSin = zeros(0,0);           % used for matching Discrete Sequence 
        H_SamplePhiSin = zeros(0,0);            % used for matching Discrete Sequence 
        H_LengthSinSeqX = 1;                    % the length of the AxisX4SinSeq
        H_Amp = zeros(0,0);                     % match length for calculation
        H_Omega = zeros(0,0);                   % match length for calculation
        H_Phi = zeros(0,0);                     % match length for calculation
        H_LengthConSinSeqX = 1;                 % the length of the AxisX4ConSinSeq
        H_ConAmp = zeros(0,0);                  % match length for calculation
        H_ConOmega = zeros(0,0);                % match length for calculation 
        H_ConPhi = zeros(0,0);                  % match length for calculation
        
    end
    %%
    methods
        %******************************************************************
        %************** Restricting Hidden Variables **********************
        %******************************************************************
        function hsampleampsin = get.H_SampleAmpSin(obj)
            %-------------- Used for better code performance by version 0.2 -------------
            ratio = obj.CDRatio;
            conamp = obj.H_ConAmp;
            %----------------------------------------------------------------------------
            hsampleampsin = conamp(1:ratio:end);
            
        end
        function hsampleomegsin = get.H_SampleOmegSin(obj)
            %-------------- Used for better code performance by version 0.2 -------------
            ratio = obj.CDRatio;
            conomega = obj.H_ConOmega;
            %----------------------------------------------------------------------------
            hsampleomegsin = conomega(1:ratio:end);
            
        end 
        function hsamplephisin = get.H_SamplePhiSin(obj)
            %-------------- Used for better code performance by version 0.2 -------------
            ratio = obj.CDRatio;
            sample = obj.H_ConPhi;
            %----------------------------------------------------------------------------
            hsamplephisin = sample(1:ratio:end);
            
        end
        function hlengthsinsewx = get.H_LengthSinSeqX(obj)
            %-------------- Used for better code performance by version 0.2 -------------
            sample = obj.AxisX4SinSeq;
            %----------------------------------------------------------------------------
            hlengthsinsewx = length(sample);
            
        end
        function hamp = get.H_Amp(obj)
            hamp = ones(1,obj.H_LengthSinSeqX);
            %-------------- Used for better code performance by version 0.2 -------------
            sample = obj.H_SampleAmpSin;
            len = length(sample);
            %----------------------------------------------------------------------------
            hamp(1,(1:len) ) = sample;
            hamp(1,(len+1:end) ) = sample(end);
            
        end
        function homega = get.H_Omega(obj)
            homega = 2*pi*ones(1,obj.H_LengthSinSeqX);
            %-------------- Used for better code performance by version 0.2 -------------
            sample = obj.H_SampleOmegSin;
            len = length(sample);
            %----------------------------------------------------------------------------
            homega(1,(1:len) ) = sample;
            homega(1,(len+1:end) ) = sample(end);
            
        end
        function hphi = get.H_Phi(obj)
            hphi = zeros(1,obj.H_LengthSinSeqX);
            %-------------- Used for better code performance by version 0.2 -------------
            sample = obj.H_SamplePhiSin;
            len = length(sample);
            %----------------------------------------------------------------------------
            hphi(1,(1:len) ) = sample;
            hphi(1,(len+1:end) ) = sample(end);
            
        end
        function hlengthconsinsewx = get.H_LengthConSinSeqX(obj)
            %-------------- Used for better code performance by version 0.2 -------------
            axisconsinseq = obj.AxisX4ConSinSeq;
            %----------------------------------------------------------------------------
            hlengthconsinsewx = length(axisconsinseq);
            
        end
        function hconamp = get.H_ConAmp(obj)
            hconamp = ones(1,obj.H_LengthConSinSeqX);
            %-------------- Used for better code performance by version 0.2 -------------
            sample = obj.Amplitude_Sin;
            len = length(sample);
            %----------------------------------------------------------------------------
            hconamp(1,(1:len) ) = sample;
            hconamp(1,(len+1:end) ) = sample(end);
            
        end
        function hconomega = get.H_ConOmega(obj)
            hconomega = 2*pi*ones(1,obj.H_LengthConSinSeqX);
            %-------------- Used for better code performance by version 0.2 -------------
            sample = obj.OmegaZero_Sin;
            len = length(sample);
            %----------------------------------------------------------------------------
            hconomega(1,(1:len) ) = sample;
            hconomega(1,(len+1:end) ) = sample(end);
            
        end
        function hconphi = get.H_ConPhi(obj)
            hconphi = zeros(1,obj.H_LengthConSinSeqX);
            %-------------- Used for better code performance by version 0.2 -------------
            sample = obj.Phi_Sin;
            len = length(sample);
            %----------------------------------------------------------------------------
            hconphi(1,(1:len) ) = sample;
            hconphi(1,(len+1:end) ) = sample(end);
            
        end
        %******************************************************************
        %************** Restricting Mutual Dependent Varibales ************
        %******************************************************************
        function obj = set.OmegaZero_Sin(obj,omegazero)
            if (omegazero < 0)
                error('the angular frequency must be positive!')
            else
                obj.Frequency_Sin = omegazero / (2*pi); 
            end
            
        end
        function omegazero_sin = get.OmegaZero_Sin(obj)
            omegazero_sin = 2*pi * obj.Frequency_Sin;
            
        end
        
        function obj = set.TimeSlice(obj,timeslice)
            %-------------- Used for better code performance by version 0.2 -------------
            timescopeE = obj.TimeScope(end);
            timescopeS = obj.TimeScope(1);     
            %----------------------------------------------------------------------------
            if (timeslice < 1)
                error('the number of the slice must be bigger than 1 !')
            else
                obj.TimeDelta =( timescopeE - timescopeS )/ timeslice;
            end
        end
        function timeslice = get.TimeSlice(obj)
            %-------------- Used for better code performance by version 0.2 -------------
            timescopeE = obj.TimeScope(end);
            timescopeS = obj.TimeScope(1);     
            %----------------------------------------------------------------------------
            timeslice = ( timescopeE - timescopeS )/ obj.TimeDelta;
            
        end
        %**************************************************************************
        %*************** Restricting Dependent and Private Variables **************
        %**************************************************************************
        function period = get.Period_Sin(obj)
            period = 1 ./ obj.Frequency_Sin ;
            
        end
        function sinsequence = get.SinSequence(obj)
            %             sinsequence = obj.Amplitude_Sin * sin(obj.OmegaZero_Sin * obj.AxisX4SinSeq + obj.Phi_Sin) ; %old Original version
            %-------------- Used for better code performance by version 0.2 -------------
            h_Amp = obj.H_Amp;
            h_Omega = obj.H_Omega;
            h_SinSeq = obj.AxisX4SinSeq;
            h_Phi = obj.H_Phi;
            %----------------------------------------------------------------------------
            sinsequence = h_Amp .* sin( h_Omega .* h_SinSeq + h_Phi) ;
            
        end
        function consinsequence = get.Con_SinSequence(obj)
            %             consinsequence = obj.Amplitude_Sin * sin(obj.OmegaZero_Sin * obj.AxisX4ConSinSeq + obj.Phi_Sin) ; %old Original version 
            %-------------- Used for better code performance by version 0.2 -------------
            h_ConAmp = obj.H_ConAmp;
            h_ConOmega = obj.H_ConOmega;
            h_ConSinSeq = obj.AxisX4ConSinSeq;
            h_ConPhi = obj.H_ConPhi; 
            %----------------------------------------------------------------------------
            consinsequence = h_ConAmp .* sin( h_ConOmega .* h_ConSinSeq + h_ConPhi) ;
            
        end
        function axisx4sinseq = get.AxisX4SinSeq(obj)
            %             axisx4sinseq = obj.TimeScope(1) : obj.TimeDelta : obj.TimeScope(end); %old Original version
            %-------------- Used for better code performance by version 0.2 -------------
            timescopeS = obj.TimeScope(1);
            timescopeE = obj.TimeScope(end);
            timeslice = obj.TimeSlice;
            %----------------------------------------------------------------------------
            axisx4sinseq = linspace(timescopeS,timescopeE,timeslice+1);
            
        end
        function axisx4consinseq = get.AxisX4ConSinSeq(obj)
            %             axisx4consinseq = obj.TimeScope(1) : obj.TimeDelta/obj.CDRatio : obj.TimeScope(end); %old Original version
            %-------------- Used for better code performance by version 0.2 -------------
            timescopeS = obj.TimeScope(1);
            timescopeE = obj.TimeScope(end);
            timeslice = obj.TimeSlice;
            ratio = obj.CDRatio; 
            %----------------------------------------------------------------------------
            axisx4consinseq = linspace(timescopeS,timescopeE,timeslice*ratio+1);
            
        end
        %******************************************************************
        %********** Restricting Properties to Specific Values *************
        %******************************************************************
        function obj = set.Frequency_Sin(obj,frequencysin)
            %             if (frequencysin < 0)                                %old Original version
            %                 error('the frequency must be positive!')
            %             else
            %                 obj.Frequency_Sin = frequencysin;
            %             end
            if (frequencysin < 0)
                error('the frequency must be positive!')
            else
                lenX = length(obj.AxisX4ConSinSeq); %#ok<MCSUP>
                if length(frequencysin)>lenX
                    error('the length of frequencysin is too long! Please restricting it no bigger than the length of AxisX4ConSinSeq ')
                else
                    obj.Frequency_Sin = frequencysin ;
                end
                
                
            end
            
        end
        function obj = set.Phi_Sin(obj,phisin)
            lenX = length(obj.AxisX4ConSinSeq); %#ok<MCSUP>
            if length(phisin)>lenX
                error('the length of phisin is too long! Please restricting it no bigger than the length of AxisX4ConSinSeq ')
            else
                obj.Phi_Sin = phisin ;
            end
            
        end
        function obj = set.Amplitude_Sin(obj,amplitudesin)
            lenX = length(obj.AxisX4ConSinSeq); %#ok<MCSUP>
            if length(amplitudesin)>lenX
                error('the length of amplitudesin is too long! Please restricting it no bigger than the length of AxisX4ConSinSeq ')
            else
                obj.Amplitude_Sin = amplitudesin ;
            end
            
        end
        function obj = set.TimeDelta(obj,timedelta)
            if (timedelta < 0)
                error('the timedelta must be positive !')
            end
            obj.TimeDelta = timedelta;
            
        end
        %******************************************************************
        %************************** Constructor ***************************
        %******************************************************************
        function obj = SequenceSin(ampitudesin,frequencysin,phisin,...
                timescope,timedelta)
            if nargin == 0
                
            else
                if (frequencysin < 0)
                    error('the frequency must be positive!')
                end
                if (timedelta < 0)
                    error('the timedelta must be positive !')
                end
                obj.Amplitude_Sin = ampitudesin;        %
                obj.Frequency_Sin = frequencysin;       % Hz
                obj.Phi_Sin = phisin;                   % radian
                obj.TimeScope = timescope ;             % s
                obj.TimeDelta = timedelta;              % s
                
            end %end of if
            
            
        end %end of function
    end
    %% Calls
    methods
        %******************************************************************
        %************* Get Continuous Signal Plot *************************
        %******************************************************************
        function Wanna2see(obj)
            sin = obj.SinSequence;
            Xsin = obj.AxisX4SinSeq;
            Csin = obj.Con_SinSequence;
            Xcsin =obj.AxisX4ConSinSeq;
            amp = obj.H_ConAmp;
            stem(Xsin,sin)
            hold on
            plot(Xcsin,Csin,'r')
            xlabel('Time/s')
            ylabel('Amplitude')
            plot(Xcsin,amp,'--','color',[1 0.6 0.4])
            hold off
            
        end %end of funciton
        %******************************************************************
        %************* Get Parameters of the Sequence *********************
        %******************************************************************
        function Parameter2show(obj)
            fprintf( 'Original_Amplitude   %g \n',obj.Amplitude_Sin(1) ) ;
            fprintf( 'Original_Frequency   %g kHz \n',obj.Frequency_Sin(1)/1000) ;
            fprintf( ' Original_Period     %g ms \n',obj.Period_Sin(1)*1000 ) ;
            fprintf( '   Original_Phi      %g \n',obj.Phi_Sin(1) ) ;
            fprintf( 'The scope is from %gms to %gms \n',obj.TimeScope(1)*1000,obj.TimeScope(end)*1000 ) ;
            fprintf( 'The sample interval \x0394t is %g ms \n',obj.TimeDelta*1000 ) ;
            
        end
    end %end of methods
end

