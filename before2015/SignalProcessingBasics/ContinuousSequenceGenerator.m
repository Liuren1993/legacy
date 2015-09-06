classdef ContinuousSequenceGenerator < CycleSequenceGenerator
    % ContinuousSequenceGenerator is a class for gernerating continuous sequences
    %   it contains what CycleSequenceGenerator contains and more:
    %     1.the number of the period 
    %     2.the BaseSequence of the periodic sequence
    %     3.the periodic sequence    
    %     4.the length of the BaseSequence
    %     5.the Scope of the periodic sequence
    %     6.the method to draw CycleSignalGraph
    %
%%
    properties
        %************* Variables *************
        SliceNumber = 1;
        
    end
    properties( Dependent = true , SetAccess = private )
        %************* Dependent Variables *******
        ContinuousSequence = zeros(0,0);
        DeltaSlice = 1; % the width of the Slice
        ContinuousSequenceScope = zeros(0,0);
        ConImpulseSequence = zeros(0,0);
        ConImpSeqShiftRightNSlot = zeros(0,0);
        ConStepSequence = zeros(0,0);
        ConStepSeqShiftRightNSlot = zeros(0,0);
        ConRealExpSequence = zeros(0,0);
        ConRealExpSeqShiftRightNSlot = zeros(0,0);
        ConComplexExpSequence = zeros(0,0);
        ConComplexExpSeqShiftRightNSlot = zeros(0,0);
        ConCosSequence = zeros(0,0);
        ConSinSequence = zeros(0,0);
        
    end
%%
    methods
        %*************** Restricting Dependent Variables **************
        function DeltaSlice = get.DeltaSlice(obj)
            DeltaSlice = 1 / obj.SliceNumber ;
            
        end
        function ContinuousSequenceScope = get.ContinuousSequenceScope(obj)
            ContinuousSequenceScope = obj.FirstSlotX : obj.DeltaSlice : obj.LastSlotX ;
            
        end
        function ConImpulseSequence = get.ConImpulseSequence(obj)
            ConImpulseSequence = (obj.ContinuousSequenceScope == 0);
            
        end
        function ConImpSeqShiftRightNSlot = get.ConImpSeqShiftRightNSlot(obj)
            ConImpSeqShiftRightNSlot = ( (obj.ContinuousSequenceScope - obj.ShiftRightNSlot) == 0);
            
        end
        function ConStepSequence = get.ConStepSequence(obj)
            ConStepSequence = (obj.ContinuousSequenceScope >= 0);
            
        end
        function ConStepSeqShiftRightNSlot = get.ConStepSeqShiftRightNSlot(obj)
            ConStepSeqShiftRightNSlot = ( (obj.ContinuousSequenceScope - obj.ShiftRightNSlot) >= 0);
            
        end
        function ConRealExpSequence = get.ConRealExpSequence(obj)
            ConRealExpSequence = (obj.Alpha).^obj.ContinuousSequenceScope;
            
        end
        function ConRealExpSeqShiftRightNSlot = get.ConRealExpSeqShiftRightNSlot(obj)
            ConRealExpSeqShiftRightNSlot = (obj.Alpha).^(obj.ContinuousSequenceScope - obj.ShiftRightNSlot*...
                ones(1,obj.SequenceLength) );
            
        end
        function ConComplexExpSequence = get.ConComplexExpSequence(obj)
            ConComplexExpSequence = exp( (obj.Sigma + obj.Omega*obj.Imag )*obj.ContinuousSequenceScope ) ;
            
        end
        function ConComplexExpSeqShiftRightNSlot = get.ConComplexExpSeqShiftRightNSlot(obj)
            ConComplexExpSeqShiftRightNSlot = exp( (obj.Sigma + obj.Omega*obj.Imag )*...
                (obj.ContinuousSequenceScope - obj.ShiftRightNSlot*ones(1,obj.SequenceLength)) );
            
        end
        function ConCosSequence = get.ConCosSequence(obj)
            ConCosSequence = obj.AmplitudeCos * cos(obj.OmegaZeroCos*obj.ContinuousSequenceScope + obj.PhiCos) ;
            
        end
        function ConSinSequence = get.ConSinSequence(obj)
            ConSinSequence = obj.AmplitudeSin * sin(obj.OmegaZeroSin*obj.ContinuousSequenceScope + obj.PhiSin) ;
            
        end
        
        %********** Restricting Properties to Specific Values **********
        function obj = set.SliceNumber(obj,slicenumber)
            if (isinteger(slicenumber))
                error('the number of the slice must be integer!')
            end
            if (slicenumber < 1)
                error('the number of the slice must be bigger than 1 !')
            end
            obj.SliceNumber = slicenumber;
            
        end

        %*************** Constructor **********************************
        function obj = ContinuousSequenceGenerator(firstslotofX,lastslotofX,shiftrightnslot,alpha,...
                sigma,omega,amplitudecos,omegazerocos,phicos,amplitudesin,omegazerosin,...
                phisin,periodnumber,slicenumber)
            if nargin == 0
                super_CycleSequenceGenerator_args = {};
            else
                super_CycleSequenceGenerator_args{1} = firstslotofX;
                super_CycleSequenceGenerator_args{2} = lastslotofX;
                super_CycleSequenceGenerator_args{3} = shiftrightnslot;
                super_CycleSequenceGenerator_args{4} = alpha;
                super_CycleSequenceGenerator_args{5} = sigma;
                super_CycleSequenceGenerator_args{6} = omega;
                super_CycleSequenceGenerator_args{7} = amplitudecos;
                super_CycleSequenceGenerator_args{8} = omegazerocos;
                super_CycleSequenceGenerator_args{9} = phicos;
                super_CycleSequenceGenerator_args{10} = amplitudesin;
                super_CycleSequenceGenerator_args{11} = omegazerosin;
                super_CycleSequenceGenerator_args{12} = phisin;
                super_CycleSequenceGenerator_args{12} = periodnumber;
            end %end of if
            obj = obj@CycleSequenceGenerator(super_CycleSequenceGenerator_args{:});
            if nargin > 0
                if (isinteger(slicenumber))
                    error('the number of the slice must be integer!')
                end
                if (slicenumber < 1)
                    error('the number of the slice must be bigger than 1 !')
                end
                obj.SliceNumber = slicenumber;
                
            end
            
        end %end of function
        
    end %end of methods
%% Calls
    methods
        %************* Get Continuous Signal Plot **********************
        function [graph,n] = ContinuousSignalGraph(obj,option)
            n = obj.ContinuousSequenceScope;
            switch option
                case 'ConImpulseSequence'
                    graph = obj.ConImpulseSequence;
                    plot(n,graph,'r')
                    grid on
                case 'ConImpSeqShiftRightNSlot'
                    graph = obj.ConImpSeqShiftRightNSlot;
                    plot(n,graph,'r')
                    grid on
                case 'ConStepSequence'
                    graph = obj.ConStepSequence;
                    plot(n,graph,'r')
                    grid on
                case 'ConStepSeqShiftRightNSlot'
                    graph = obj.ConStepSeqShiftRightNSlot;
                    plot(n,graph,'r')
                    grid on
                case 'ConRealExpSequence'
                    graph = obj.ConRealExpSequence;
                    plot(n,graph,'r')
                    grid on
                case 'ConRealExpSeqShiftRightNSlot'
                    graph = obj.ConRealExpSeqShiftRightNSlot;
                    plot(n,graph,'r')
                    grid on
                case 'ConComplexExpSequence'
                    graph = obj.ConComplexExpSequence;
                    magsignal = abs(graph);
                    angsignal = angle(graph);
                    realsignal = real(graph);
                    imagsignal = imag(graph);
                    subplot(2,2,1);
                    plot(n,magsignal,'r');
                    hold on
                    title('Magnitude Part');
                    grid on
                    subplot(2,2,3);
                    plot(n,angsignal,'r');
                    hold on
                    title('Angle Part');
                    grid on
                    subplot(2,2,2);
                    plot(n,realsignal,'r');
                    hold on
                    title('Real Part');
                    grid on
                    subplot(2,2,4);
                    plot(n,imagsignal,'r');
                    hold on
                    title('Imaginary Part');
                    grid on
                    
                case 'ConComplexExpSeqShiftRightNSlot'
                    graph = obj.ConComplexExpSeqShiftRightNSlot;
                    magsignal = abs(graph);
                    angsignal = angle(graph);
                    realsignal = real(graph);
                    imagsignal = imag(graph);
                    subplot(2,2,1);
                    plot(n,magsignal,'r');
                    hold on
                    title('Magnitude Part');
                    grid on
                    subplot(2,2,3);
                    plot(n,angsignal,'r');
                    hold on
                    title('Angle Part');
                    grid on
                    subplot(2,2,2);
                    plot(n,realsignal,'r');
                    hold on
                    title('Real Part');
                    grid on
                    subplot(2,2,4);
                    plot(n,imagsignal,'r');
                    hold on
                    title('Imaginary Part');
                    grid on
                case 'ConCosSequence'
                    graph = obj.ConCosSequence;
                    plot(n,graph,'r')
                    grid on
                case 'ConSinSequence'
                    graph = obj.ConSinSequence;
                    plot(n,graph,'r')
                    grid on
            end %end of switch
            
        end %end of function       
            
        
    end %end of methods
end %end of class
