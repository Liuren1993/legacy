classdef WaveformLFM < WaveformTypical
    % WaveformLFM is a class for gernerating a Linear Frequency Modulation waveform model.
    %   A*sin( CapOmega*t + Theta(t) )
    %   sin( Theta(t) )
    % Note that if you wanna get A*sin( CapOmega*t + Theta(t) ), please follow these two steps:
    % 1.Make sure the CapOmega is big enough;
    % 2.Call the function GetLFM 
    %   mainly for inherit 
    % it contains:
    % Input Variables:
    % 1.FrequencyHead -The start frequency of the sweepband;
    % 2.SweepBand -The bandwidth of the LFM waveform;
    % 3.Mod_Period -The Modulation Period of the LFM waveform;
    % --Varibles:
    % 1.FrequencyTail -The end frequency of the sweepband;
    % 2.SweepBandScope -The scope of the sweepband;
    % 3.FrequencySlope -The slope of the linear frequency;
    % 4.Ins_Frequency -The Instantaneous Frequency sequence;
    % 5.Ins_Fre_Periodic -The cycle extended Instantaneous Frequency sequence;
    % 6.ThetaMod_LFM -The linear frequency modulation sequence : Theta(t);
    % 7.ThetaMod_LFM_Periodic -The cycle extended linear frequency modulation sequence;
    % --Another variables are shown in Superclass.
    %
    % History:
    % ---Original Version by Gnimuc 2013/6/27
    % ---Version 0.1 by Gnimuc 2013/6/28
    % * modify some functions for better code performance
    %
    %%
    properties
        %************* Variables *************
        FrequencyHead = 0;       % Hz
        SweepBand = 100;         % Hz
        Mod_Period = 1;          % s
        
    end
    properties( Dependent = true )
        %************* Mutual Dependent Variables ***********  
        FrequencyTail = 100;            % Hz
        SweepBandScope = [0 100];
        FrequencySlope = 1;             % s^-2
        
    end
    properties( Dependent = true , SetAccess = private ) 
        %********** Dependent and Private Variables **********
        Ins_Frequency = zeros(0,0);
        Ins_Fre_Periodic = zeros(0,0);
        ThetaMod_LFM = zeros(0,0);
        ThetaMod_LFM_Periodic = zeros(0,0);
        
    end
    properties( Dependent = true , SetAccess = private , Hidden = true)
        %********** Hidden Variables **********
        H_CycleTimes = 1;               % Cycle extended times
        
    end
    %%
    methods
        %******************************************************************
        %************** Restricting Hidden Variables **********************
        %******************************************************************
        function hcycletimes = get.H_CycleTimes(obj)
            scopelength = obj.TimeScope(end);
            modperiod = obj.Mod_Period;
            hcycletimes = ceil( scopelength / modperiod );
            
        end
        
        %******************************************************************
        %************** Restricting Mutual Dependent Varibales ************
        %******************************************************************
        function obj = set.FrequencyTail(obj,frequencytail)
            obj.SweepBand = frequencytail - obj.FrequencyHead ;
            
        end
        function frequencytail= get.FrequencyTail(obj)
            frequencytail = obj.FrequencyHead + obj.SweepBand ;
            
        end
        function obj = set.SweepBandScope(obj,sweepbandscope)
            obj.FrequencyHead = sweepbandscope(1) ;
            obj.FrequencyTail = sweepbandscope(2) ;
            
        end
        function sweepbandscope= get.SweepBandScope(obj)
            sweepbandscope =  [ obj.FrequencyHead , obj.FrequencyTail ] ;
            
        end
        function obj = set.FrequencySlope(obj,frequencyslope)
            obj.Mod_Period = obj.SweepBand / frequencyslope ;
            
        end
        function frequencyslope= get.FrequencySlope(obj)
            frequencyslope = obj.SweepBand / obj.Mod_Period ;
            
        end
        %**************************************************************************
        %*************** Restricting Dependent and Private Variables **************
        %**************************************************************************
        function insfrequency = get.Ins_Frequency(obj)
            %-------------- Used for better code performance by version 0.1 -------------
            k = obj.FrequencySlope;
            delta = obj.TimeDelta / obj.CDRatio;     
            t = ( 0: delta : obj.Mod_Period );
            %----------------------------------------------------------------------------
            insfrequency = k * t ;
            
        end
        function insfreperiodic = get.Ins_Fre_Periodic(obj)
            %-------------- Used for better code performance by version 0.1 -------------
            insfrequency = obj.Ins_Frequency;
            times = obj.H_CycleTimes;
            len = length(obj.TimeAxis);
            %----------------------------------------------------------------------------
            temp = insfrequency' * ones(1,times);
            temp = temp(:);
            temp = temp';
            insfreperiodic = temp(1:len);
            
            
        end        
        function thetamodlfm = get.ThetaMod_LFM(obj)
            %-------------- Used for better code performance by version 0.1 -------------
            k = obj.FrequencySlope;
            delta = obj.TimeDelta / obj.CDRatio;     
            t = ( 0: delta : obj.Mod_Period );
            %----------------------------------------------------------------------------
            thetamodlfm = pi * k * t.^2 ;
            
        end
        function thetamodlfmperiodic = get.ThetaMod_LFM_Periodic(obj)
            %-------------- Used for better code performance by version 0.1 -------------
            thetamodlfm = obj.ThetaMod_LFM;
            times = obj.H_CycleTimes;
            len = length(obj.TimeAxis);
            %----------------------------------------------------------------------------
            temp = thetamodlfm' * ones(1,times);
            temp = temp(:);
            temp = temp';
            thetamodlfmperiodic = temp(1:len);
            
            
        end   
        %******************************************************************
        %********** Restricting Properties to Specific Values *************
        %******************************************************************
        function obj = set.FrequencyHead(obj,frequencyhead)
            if frequencyhead < 0
                error('the frequency must be positive !')
            else
                obj.FrequencyHead = frequencyhead ;
            end
        end
        function obj = set.SweepBand(obj,sweepband)
            if sweepband < 0
                error('the frequency bandwidth must be positive !')
            else
                obj.SweepBand = sweepband  ;
            end
        end
        function obj = set.Mod_Period(obj,modperiod)
            if modperiod < 0
                error('the modulation period must be positive !')
            else
                obj.Mod_Period = modperiod  ;
            end
        end
        
    end
    %% Calls
    methods
        %******************************************************************
        %******************** Get Linear Waveform *************************
        %******************************************************************
        function obj = GetLFM(obj)
            len = length(obj.TimeAxis);
            lenLFM = length(obj.ThetaMod_LFM);
            if( lenLFM == len )
                obj.ThetaMod = obj.ThetaMod_LFM;
                disp('LFM')
            else
                obj.ThetaMod = obj.ThetaMod_LFM_Periodic;
                disp('Periodic')
            end
            
        end %end of funciton
       
    end %end of methods
end

