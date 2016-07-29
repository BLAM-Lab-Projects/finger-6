classdef TimedResp < StateMachine
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
            for ii = 1:length(name_array)
                img = imread([img_dir, img_names(ii).name]);
                s.imgs.AddImage(img, s.win.pointer, ii,...
                                'rel_x_pos', 0.5, ...
                                'rel_y_pos', 0.5, ...
                                'rel_x_scale', 0.23);
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
            time_flip = GetSecs;
            state = 'intrial';
            neststate = 'prep';
            while ~(GetSecs - s.ref_time > 4200) || done
                loop_time = GetSecs;

                switch state
                    case 'intrial'
                        switch neststate
                            case 'prep'

                            case 'doneprep'
                                if loop_time >= audio_time && audio_not_played

                                end

                                if loop_time >= img_time

                                end
                        end

                        % draw press feedback
                        if loop_time >= endtrial_time
                            state = 'feedback';
                        end

                    case 'feedback'

                        % draw correctness feedback

                    case 'between'

                    otherwise
                        error('Invalid state.')

                end


                time_flip = s.win.Flip(time_flip + (0.7 * s.win.flip_interval));
                if trial_count > max(s.tgt.trial)
                    done = true;
                end
            end

        end

        function Cleanup(self)
            BailPtb;
            %...
        end

    end % end methods
end % end classdef
