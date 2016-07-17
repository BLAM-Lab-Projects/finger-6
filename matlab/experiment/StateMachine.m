classdef (Abstract) StateMachine < PsychHandle
    properties
        p;
        state;
        ref_time;
        summary_data;
        full_data;
        tgt;
    end
    methods
        function self = StateMachine()
            self.p = inputParser;
        end
        function Setup() end
        function Transition() end
        function Execute() end
        function Cleanup() end
    end

    methods (Static)
        function Factory(type)
            switch lower(type)
            case 'timedresp'
                self = TimedResp;
            case 'freeresp'
                self = FreeResp;
            otherwise
                error('Unknown experiment type.');
            end
        end % end Factory
    end % end static methods
end
