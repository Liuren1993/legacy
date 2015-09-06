classdef SequenceGenerator
    % SequenceGenerator is a class for gernerating common sequences
    %   it contains:
    %     1.the first slot of the x-axis
    %     2.the last slot of the x-axis eg:(firstslot,secondslot,...,lastslot)
    %     3.the length of the sequence
    %     4.the scope of the sequence (see it as a list whose every element is the second element of the Signal vector(Sx,St))
    %     5.the distance of the slot shifted to right (the way to choose to use which signal)
    %     6.the Impulse Sequence(see it as a list whose every element is the first element of the Signal vector(Sv,St))
    %     -- consider both 4.and 6.,we are about to find that the Signal vector is (certain signal value,certain time point).
    %     -- consider a list of the Signal vector just like ( (Sx,St)1,(Sx,St)2,...,(Sx,St)n ) called Signal vector list,
    %     -- it can represent a signal enough. So we can see 4.and 6. as a signal.
    %     7.the ImpSeqShiftRightNSlot (see both 4.and 7. as another signal )
    %     8.the Step Sequence
    %     9.the StepSeqShiftRightNSlot
    %    10.the Real Exp Sequence : (Alpha)^n
    %    11.the RealExpSeqShiftRightNSlot
    %    12.the Complex Exp Sequence : e^((Sigma+Omega*j)*n)
    %    13.the ComplexExpSeqShiftRightNSlot
    %    14.the Cos Sequence : Amplitude * cos(OmegaZero*n + Phi)
    %    15.the Sin Sequence : Amplitude * sin(OmegaZero*n + Phi)
    %
%%
    properties
        %************* Variables *************
        FirstSlotX = 0;
        LastSlotX = 0;
        ShiftRightNSlot = 0;
        Alpha = 0;
        Sigma = 0;
        Omega = 0;
        AmplitudeCos = 0;
        OmegaZeroCos = 0;
        PhiCos = 0;
        AmplitudeSin = 0;
        OmegaZeroSin = 0;
        PhiSin = 0;
        
    end
    properties( SetAccess = private )
        %************* Constant Variables *************
        Imag = sqrt(-1);
        
    end
    properties( Dependent = true , SetAccess = private )
        %************* Dependent Variables *******
        SequenceLength = 0;
        SequenceScope = zeros(0,0);
        ImpulseSequence = zeros(0,0);
        ImpSeqShiftRightNSlot = zeros(0,0);
        StepSequence = zeros(0,0);
        StepSeqShiftRightNSlot = zeros(0,0);
        RealExpSequence = zeros(0,0);
        RealExpSeqShiftRightNSlot = zeros(0,0);
        ComplexExpSequence = zeros(0,0);
        ComplexExpSeqShiftRightNSlot = zeros(0,0);
        CosSequence = zeros(0,0);
        SinSequence = zeros(0,0);
        
    end
%%
    methods
        %*************** Restricting Dependent Variables **************
        function SequenceLength = get.SequenceLength(obj)
            sizearray = size(obj.SequenceScope);
            SequenceLength = sizearray(2);
            
        end
        function SequenceScope = get.SequenceScope(obj)
            SequenceScope = obj.FirstSlotX:obj.LastSlotX;
            
        end
        function ImpulseSequence = get.ImpulseSequence(obj)
            ImpulseSequence = (obj.SequenceScope == 0);
            
        end
        function ImpSeqShiftRightNSlot = get.ImpSeqShiftRightNSlot(obj)
            ImpSeqShiftRightNSlot = ( (obj.SequenceScope - obj.ShiftRightNSlot) == 0);
            
        end
        function StepSequence = get.StepSequence(obj)
            StepSequence = (obj.SequenceScope >= 0);
            
        end
        function StepSeqShiftRightNSlot = get.StepSeqShiftRightNSlot(obj)
            StepSeqShiftRightNSlot = ( (obj.SequenceScope - obj.ShiftRightNSlot) >= 0);
            
        end
        function RealExpSequence = get.RealExpSequence(obj)
            RealExpSequence = (obj.Alpha).^obj.SequenceScope;
            
        end
        function RealExpSeqShiftRightNSlot = get.RealExpSeqShiftRightNSlot(obj)
            RealExpSeqShiftRightNSlot = (obj.Alpha).^(obj.SequenceScope - obj.ShiftRightNSlot*...
                ones(1,obj.SequenceLength) );
            
        end
        function ComplexExpSequence = get.ComplexExpSequence(obj)
            ComplexExpSequence = exp( (obj.Sigma + obj.Omega*obj.Imag )*obj.SequenceScope ) ;
            
        end
        function ComplexExpSeqShiftRightNSlot = get.ComplexExpSeqShiftRightNSlot(obj)
            ComplexExpSeqShiftRightNSlot = exp( (obj.Sigma + obj.Omega*obj.Imag )*...
                (obj.SequenceScope - obj.ShiftRightNSlot*ones(1,obj.SequenceLength)) );
            
        end
        function CosSequence = get.CosSequence(obj)
            CosSequence = obj.AmplitudeCos * cos(obj.OmegaZeroCos*obj.SequenceScope + obj.PhiCos) ;
            
        end
        function SinSequence = get.SinSequence(obj)
            SinSequence = obj.AmplitudeSin * sin(obj.OmegaZeroSin*obj.SequenceScope + obj.PhiSin) ;
            
        end
        
        %********** Restricting Properties to Specific Values **********
        function obj = set.FirstSlotX(obj,firstslotofX)
            if (isinteger(firstslotofX))
                error('the first slot of X-axis must be integer!')
            end
            if (firstslotofX > obj.LastSlotX) %#ok<MCSUP>
                error('the first slot of the X-axis must be smaller than the last slot of the X-axis')
            end
            obj.FirstSlotX = firstslotofX;
            
        end
        function obj = set.LastSlotX(obj,lastslotofX)
            if (isinteger(lastslotofX))
                error('the last slot of X-axis must be integer!')
            end
            if (lastslotofX < obj.FirstSlotX) %#ok<MCSUP>
                error('the last slot of the X-axis must be bigger than the first slot of the X-axis')
            end
            obj.LastSlotX = lastslotofX;
        end
        function obj = set.ShiftRightNSlot(obj,shiftrightnslot)
            if (isinteger(shiftrightnslot))
                error('the distance of the slot shifted to right must be integer!')
            end
            obj.ShiftRightNSlot = shiftrightnslot;
            
        end
        function obj = set.Alpha(obj,alpha)
            obj.Alpha = alpha;
            
        end
        function obj = set.Sigma(obj,sigma)
            obj.Sigma = sigma;
            
        end
        function obj = set.Omega(obj,omega)
            obj.Omega = omega;
            
        end
        function obj = set.AmplitudeCos(obj,amplitudecos)
            obj.AmplitudeCos = amplitudecos;
            
        end
        function obj = set.OmegaZeroCos(obj,omegazerocos)
            obj.OmegaZeroCos = omegazerocos;
            
        end
        function obj = set.PhiCos(obj,phicos)
            obj.PhiCos = phicos;
            
        end
        function obj = set.AmplitudeSin(obj,amplitudesin)
            obj.AmplitudeSin = amplitudesin;
            
        end
        function obj = set.OmegaZeroSin(obj,omegazerosin)
            obj.OmegaZeroSin = omegazerosin;
            
        end
        function obj = set.PhiSin(obj,phisin)
            obj.PhiSin = phisin;
            
        end
        
        %*************** Constructor **********************************
        function obj = SequenceGenerator(firstslotofX,lastslotofX,shiftrightnslot,alpha,...
                sigma,omega,amplitudecos,omegazerocos,phicos,amplitudesin,omegazerosin,...
                phisin)
            if nargin == 0
                
            else
                if (firstslotofX ~= ceil(firstslotofX))
                    error('the first slot of X-axis must be integer!')
                end
                if (lastslotofX ~= ceil(lastslotofX))
                    error('the last slot of X-axis must be integer!')
                end
                if (firstslotofX > obj.LastSlotX)
                    error('the first slot must be smaller than the last slot!')
                end
                if (lastslotofX < obj.FirstSlotX)
                    error('the last slot must be bigger than the first slot!')
                end
                obj.FirstSlotX = firstslotofX;
                obj.LastSlotX = lastslotofX;
                obj.ShiftRightNSlot = shiftrightnslot;
                obj.Alpha = alpha;
                obj.Sigma = sigma;
                obj.Omega = omega;
                obj.AmplitudeCos = amplitudecos;
                obj.OmegaZeroCos = omegazerocos;
                obj.PhiCos = phicos;
                obj.AmplitudeSin = amplitudesin;
                obj.OmegaZeroSin = omegazerosin;
                obj.PhiSin = phisin;
                
            end %end of if 
            
            
        end %end of function 
        
    end %end of method 
%% Calls
    methods
        %************* Get Signal Plot **********************
        function [graph,n] = SignalGraph(obj,option)
            n = obj.SequenceScope;
            switch option
                case 'ImpulseSequence'
                    graph = obj.ImpulseSequence;
                    stem(n,graph)
                    grid on
                case 'ImpSeqShiftRightNSlot'
                    graph = obj.ImpSeqShiftRightNSlot;
                    stem(n,graph)
                    grid on
                case 'StepSequence'
                    graph = obj.StepSequence;
                    stem(n,graph)
                    grid on
                case 'StepSeqShiftRightNSlot'
                    graph = obj.StepSeqShiftRightNSlot;
                    stem(n,graph)
                    grid on
                case 'RealExpSequence'
                    graph = obj.RealExpSequence;
                    stem(n,graph)
                    grid on
                case 'RealExpSeqShiftRightNSlot'
                    graph = obj.RealExpSeqShiftRightNSlot;
                    stem(n,graph)
                    grid on
                case 'ComplexExpSequence'
                    graph = obj.ComplexExpSequence;
                    magsignal = abs(graph);
                    angsignal = angle(graph);
                    realsignal = real(graph);
                    imagsignal = imag(graph);
                    subplot(2,2,1);
                    stem(n,magsignal);
                    hold on
                    title('Magnitude Part');
                    grid on
                    subplot(2,2,3);
                    stem(n,angsignal);
                    hold on
                    title('Angle Part');
                    grid on
                    subplot(2,2,2);
                    stem(n,realsignal);
                    hold on
                    title('Real Part');
                    grid on
                    subplot(2,2,4);
                    stem(n,imagsignal);
                    hold on
                    title('Imaginary Part');
                    grid on
                    
                case 'ComplexExpSeqShiftRightNSlot'
                    graph = obj.ComplexExpSeqShiftRightNSlot;
                    magsignal = abs(graph);
                    angsignal = angle(graph);
                    realsignal = real(graph);
                    imagsignal = imag(graph);
                    subplot(2,2,1);
                    stem(n,magsignal);
                    hold on
                    title('Magnitude Part');
                    grid on
                    subplot(2,2,3);
                    stem(n,angsignal);
                    hold on
                    title('Angle Part');
                    grid on
                    subplot(2,2,2);
                    stem(n,realsignal);
                    hold on
                    title('Real Part');
                    grid on
                    subplot(2,2,4);
                    stem(n,imagsignal);
                    hold on
                    title('Imaginary Part');
                    grid on
                case 'CosSequence'
                    graph = obj.CosSequence;
                    stem(n,graph)
                    hold on
                    grid on
                case 'SinSequence'
                    graph = obj.SinSequence;
                    stem(n,graph)
                    hold on
                    grid on
            end %end of switch
            
        end %end of function
    end %end of methods
    
end %end of class

