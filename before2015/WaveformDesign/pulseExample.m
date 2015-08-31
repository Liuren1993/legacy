classdef pulseExample
    %%
    properties %独立变量
        % 保留参数
        Pw = 0;
        Rf = 0;
        % 绘图参数
        PRI = 56;         % us
        ToAInit = 0;      % ToA初始值
        PA = 1;           % 幅值
        PulseNum = 128;   % 脉冲数
        time0 = 0;        % 时间起点
    end
    
    properties (Dependent = true)  %依赖变量
        t = 0;        % us
        timeEnd = 1;  % us
        ToA = 0;
        output = 0;   % y
    end
    %% calls
    methods
        % 给依赖变量赋值 从而能够当独立变量被修改时  相应的依赖变量的值随之修改
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
        % 给独立变量设置值得方法 主要用来判断用户给的值是否符合要求
        function obj = set.time0(obj,value)
            if value < 0
                disp('初始时间不能为负数')
            else
                obj.time0 = value;
            end
        end
        function obj = set.Pw(obj,value)
            if value < 0
                disp('暂时用不到 你给也白搭')
            else
                obj.Pw = value;
            end
        end
        function obj = set.Rf(obj,value)
            if value < 0
                disp('说了没用！')
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
        % 构造函数
        function obj = pulseExample(pw,rf,pri,toainit,pa,pulsenum,time0)
            if nargin == 0
                
            else
                obj.Pw = pw;
                obj.Rf = rf;
                % 绘图参数
                obj.PRI = pri;             % us
                obj.ToAInit = toainit;     % ToA初始值
                obj.PA = pa;               % 幅值
                obj.PulseNum = pulsenum;   % 脉冲数
                obj.time0 = time0;         % 时间起点
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

