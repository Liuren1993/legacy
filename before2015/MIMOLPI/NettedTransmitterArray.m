classdef NettedTransmitterArray < FMCW_RadarArray
    % NettedTransmitterArray is a class of the FMCW netted system's Transmitter array
    %   it contains what the class FMCW_Radar contains
    %   but we just use transmitter parameters 
    %   we develop a new class just for distinguishing
    %
%%
    properties
        
    end
%%   
    methods
        %*************** Constructor **********************************
        function obj = NettedTransmitterArray(nettedtransmitterarray)
            if nargin == 0
                super_FMCW_RadarArray_args = {};
            else
                super_FMCW_RadarArray_args{1} = nettedtransmitterarray;
            end
            obj = obj@FMCW_RadarArray(super_FMCW_RadarArray_args{:});
        end           
        
    end
    
end

