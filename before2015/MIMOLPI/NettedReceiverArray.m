classdef NettedReceiverArray < FMCW_RadarArray
    % NettedReceiverArray is a class of the FMCW netted system's Receiver array
    %   it contains what the class FMCW_Radar contains
    %   but we just use Receiver parameters 
    %   we develop a new class just for distinguishing
    %
%%
    properties
        
    end
%%   
    methods
        %*************** Constructor **********************************
        function obj = NettedReceiverArray(nettedreceiverarray)
            if nargin == 0
                super_FMCW_RadarArray_args = {};
            else
                super_FMCW_RadarArray_args{1} = nettedreceiverarray;
            end
            obj = obj@FMCW_RadarArray(super_FMCW_RadarArray_args{:});
        end           
        
    end
    
end


