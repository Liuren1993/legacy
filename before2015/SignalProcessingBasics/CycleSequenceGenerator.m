classdef CycleSequenceGenerator < SequenceGenerator
    % CycleSequenceGenerator is a class for gernerating cycle sequences
    %   it contains what SequenceGenerator contains and more:
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
        PeriodNumber = 1;
        BaseSequence = zeros(1,1);
        
    end
    properties( Dependent = true , SetAccess = private )
        %************* Dependent Variables *******
        CycleSequence = zeros(0,0);
        BaseSequenceLength = 0;
        CycleSequenceScope = zeros(0,0);
        
    end
%%
    methods
        %*************** Restricting Dependent Variables **************
        function CycleSequence = get.CycleSequence(obj)
            temp = obj.BaseSequence' * ones(1,obj.PeriodNumber);
            temp = temp(:);
            CycleSequence = temp';
            
        end
        function BaseSequenceLength = get.BaseSequenceLength(obj)
            sizearray = size(obj.BaseSequence);
            BaseSequenceLength = sizearray(2);
            
        end
        function CycleSequenceScope = get.CycleSequenceScope(obj)
            if obj.BaseSequenceLength == obj.SequenceLength
                CycleSequenceScope = obj.FirstSlotX:(obj.LastSlotX+...
                    (obj.SequenceLength*(obj.PeriodNumber-1)));
            else
                CycleSequenceScope = 0:(obj.BaseSequenceLength*obj.PeriodNumber)-1;
            end
            
        end
        %********** Restricting Properties to Specific Values **********
        function obj = set.PeriodNumber(obj,periodnumber)
            if (isinteger(periodnumber))
                error('the number of the Expanded Period must be integer!')
            end
            if (periodnumber < 1)
                error('the number of the Expanded Period  must be bigger than 1 !')
            end
            obj.PeriodNumber = periodnumber;
            
        end
        function obj = set.BaseSequence(obj,basesequence)
            obj.BaseSequence = basesequence;
            
        end
        %*************** Constructor **********************************
        function obj = CycleSequenceGenerator(firstslotofX,lastslotofX,shiftrightnslot,alpha,...
                sigma,omega,amplitudecos,omegazerocos,phicos,amplitudesin,omegazerosin,...
                phisin,periodnumber)
            if nargin == 0
                super_SequenceGenerator_args = {};
            else
                super_SequenceGenerator_args{1} = firstslotofX;
                super_SequenceGenerator_args{2} = lastslotofX;
                super_SequenceGenerator_args{3} = shiftrightnslot;
                super_SequenceGenerator_args{4} = alpha;
                super_SequenceGenerator_args{5} = sigma;
                super_SequenceGenerator_args{6} = omega;
                super_SequenceGenerator_args{7} = amplitudecos;
                super_SequenceGenerator_args{8} = omegazerocos;
                super_SequenceGenerator_args{9} = phicos;
                super_SequenceGenerator_args{10} = amplitudesin;
                super_SequenceGenerator_args{11} = omegazerosin;
                super_SequenceGenerator_args{12} = phisin;
            end %end of if
            obj = obj@SequenceGenerator(super_SequenceGenerator_args{:});
            if nargin > 0
                if (isinteger(periodnumber))
                    error('the number of the Expanded Period must be integer!')
                end
                if (periodnumber < 1)
                    error('the number of the Expanded Period  must be bigger than 1 !')
                end
                obj.PeriodNumber = periodnumber;
                
            end
            
        end %end of function
        
    end %end of methods
%% Calls
    methods
        %************* Set Base Sequence **********************
        function [graph,n] = CycleSignalGraph(obj)
            n = obj.CycleSequenceScope;
            graph = obj.CycleSequence;
            if (imag(graph)== 0)
                stem(n,graph)
                grid on
            else
                magsignal = abs(graph);
                angsignal = angle(graph);
                realsignal = real(graph);
                imagsignal = imag(graph);
                subplot(2,2,1);
                stem(n,magsignal);
                title('Magnitude Part');
                grid on
                subplot(2,2,3);
                stem(n,angsignal);
                title('Angle Part');
                grid on
                subplot(2,2,2);
                stem(n,realsignal);
                title('Real Part');
                grid on
                subplot(2,2,4);
                stem(n,imagsignal);
                title('Imaginary Part');
                grid on
            end
            
            
        end %end of function
    end %end of methods
end %end of class


