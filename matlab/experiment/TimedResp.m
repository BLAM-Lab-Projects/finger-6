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
                front_color = [0 0 0];
                back_color = [255 255 255];
            else
                front_ccolor = [255 255 255];
                back_color = [0 0 0];
            end
            s.win = PsychWindow(0, true, 'rect', s.consts.win_size,...
                                'color', back_color, ...
                                'alpha_blending', true);

            % add audio
            snd1 = wavread('misc/sounds/beep.wav');
            snd2 = wavread('misc/sounds/smw_coin.wav');

            s.aud = PsychAudio('mode', 9);
            s.aud.AddSlave(1, 'channels', 2);
            s.aud.AddSlave(2, 'channels', 2);

            s.aud.FillBuffer([snd1; snd1]', 1);
            s.aud.FillBuffer([snd2; snd2]', 2);

            % add images
            if tgt.image_type(1)
                subdir = 'shapes/';
            else
                subdir = 'hands/';
            end
            img_dir = ['misc/images/', subdir];
            img_names = dir([img_dir, '/*.jpg']);

            s.imgs = PsychTextures;
            img_rect = 0.2 * s.win.Get('rect');
            img_rect = CenterRectOnPoint(img_rect, s.win.center(1), s.win.center(2));
            for ii = 1:length(name_array)
                img = imread([img_dir, img_names(ii).name]);
                s.imgs.AddImage(img, s.win.pointer, ii,...
                                'draw_rect', img_rect);
            end

            % add feedback
            s.feed = PressFeedback(unique(tgt.finger_index), ...
                                   'fill_color', back_color,...
                                   'frame_color', front_color, ...
                                   'rect', , ...
                                   'pen_width', 2);
        end % end setup

        function Execute(s)
            done = false;
            stop_conditions = (GetSecs - s.ref_time > 4200) || done;
            while ~stop_conditions

            end

        end

    end % end methods
end % end classdef
