classdef pulseExample
    %%
    properties %��������
        % ��������
        Pw = 0;
        Rf = 0;
        % ��ͼ����
        PRI = 56;         % us
        ToAInit = 0;      % ToA��ʼֵ
        PA = 1;           % ��ֵ
        PulseNum = 128;   % ������
        time0 = 0;        % ʱ�����
    end
    
    properties (Dependent = true)  %��������
        t = 0;        % us
        timeEnd = 1;  % us
        ToA = 0;
        output = 0;   % y
    end
    %% calls
    methods
        % ������������ֵ �Ӷ��ܹ��������������޸�ʱ  ��Ӧ������������ֵ��֮�޸�
        function timeEnd = get.timeEnd(obj)
            timeEnd = obj.PRI * obj.PulseNum;
            
        end
        function t = get.t(obj)
            t = obj.time0:obj.timeEnd-1;
            
        end
        function ToA = get.ToA(obj)
            for i = 1:obj.PulseNum
                ToA(i) = obj.ToAInit + i*obj.PRI;
            end 
        end
        function output = get.output(obj)
            output(obj.ToA) = obj.PA ;
            
        end
        % ��������������ֵ�÷��� ��Ҫ�����ж��û�����ֵ�Ƿ����Ҫ��
        function obj = set.time0(obj,value)
            if value < 0
                disp('��ʼʱ�䲻��Ϊ����')
            else
                obj.time0 = value;
            end
        end
        function obj = set.Pw(obj,value)
            if value < 0
                disp('��ʱ�ò��� ���Ҳ�״�')
            else
                obj.Pw = value;
            end
        end
        function obj = set.Rf(obj,value)
            if value < 0
                disp('˵��û�ã�')
            else
                obj.Rf = value;
            end
        end
        function obj = set.PulseNum(obj,value)
            obj.PulseNum = value;
            
        end
        function obj = set.PRI(obj,value)
            obj.PRI = value;
            
        end
        function obj = set.ToAInit(obj,value)
            obj.ToAInit = value;
            
        end
        function obj = set.PA(obj,value)
            obj.PA = value;
            
        end
        % ���캯��
        function obj = pulseExample(pw,rf,pri,toainit,pa,pulsenum,time0)
            if nargin == 0
                
            else
                obj.Pw = pw;
                obj.Rf = rf;
                % ��ͼ����
                obj.PRI = pri;             % us
                obj.ToAInit = toainit;     % ToA��ʼֵ
                obj.PA = pa;               % ��ֵ
                obj.PulseNum = pulsenum;   % ������
                obj.time0 = time0;         % ʱ�����
            end
        end %end of if
    end
    %%
    methods
        function Wanna2see(obj)
            stem(obj.t,obj.output)
            xlabel('Time/us')
            ylabel('Amplitude')
            
        end %end of funciton
    end
    
end

