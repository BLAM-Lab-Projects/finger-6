classdef TimedResp < StateMachine
    properties
        trial_machine;
    end
    methods
        function self = TimedResp
            self = self@StateMachine;
            self.p.FunctionName = 'TimedResp';
            % inblock contains own state machine
            self.p.addParamValue('state', 'idle', @(x) any(not(cellfun('isempty', strfind(x, {'setup', 'inblock', 'postblock'})))));
            self.p.state = 'setup';
            self.p.trial_machine = TimedResp_trial;

        end

        function Setup(tgt, varargin)

        end

        function Transition(self, varargin)
            self.p.parse(varargin{:});
            opts = self.p.Results;

            if opts.state == 'postblock'
                % clean up
            end
        end

    end % end methods
end % end classdef
