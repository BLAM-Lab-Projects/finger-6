classdef (Abstract) StateMachine < PsychHandle
    properties
        p;
        state;
        ref_time;
        summary_data;
        full_data;
        tgt;
        id;
    end
    methods
        function self = StateMachine()
            self.p = inputParser;
        end
        function Setup(self) end
        function Transition(self) end
        function Execute(self) end
        function Cleanup(self) end
    end

    methods (Static)
        function self = Factory(type)
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
