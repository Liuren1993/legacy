classdef ESMReceiverArray < FMCW_RadarArray
    % ESMReceiverArray is a class of the ESM Receiver array
    %   it contains what the class FMCW_Radar contains
    %   but we just use ESMReceiver parameters 
    %   we develop a new class just for distinguishing
    %
%%
    properties
        
    end
%%   
    methods
        %*************** Constructor **********************************
        function obj = ESMReceiverArray(esmreceiverarray)
            if nargin == 0
                super_FMCW_RadarArray_args = {};
            else
                super_FMCW_RadarArray_args{1} = esmreceiverarray;
            end
            obj = obj@FMCW_RadarArray(super_FMCW_RadarArray_args{:});
        end           
        
    end
    
end