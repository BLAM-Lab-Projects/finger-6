classdef TimedResp < StateMachine
    properties
        trial_machine;
    end
    methods
        function self = TimedResp
            self = self@StateMachine;
            self.p.FunctionName = 'TimedResp';
            % inblock contains own state machine
            self.ref_time = GetSecs;

            consts = struct('win_size', [30 30 400 400], ...
                            'reversed', false)
            self.consts = consts;

        end

        function Setup(s, tgt, varargin)
            Screen('Preference', 'Verbosity', 1);
            if s.consts.reversed
                colour = [255 255 255];
            else
                colour = [0 0 0];
            end
            s.win = PsychWindow(0, true, 'rect', s.consts.win_size,...
                                'color', colour, ...
                                'alpha_blending', true);
            
        end

        function Execute(s)
            done = false;
            stop_conditions = (GetSecs - s.ref_time > 4200) || done;
            while 1
                if stop_conditions
                    break;
                end




            end
        end

    end % end methods
end % end classdef
