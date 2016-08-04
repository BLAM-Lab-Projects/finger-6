classdef TimedResp < StateMachine

    properties
    % in order of appearance...
        ref_time % reference time for the entire block
        consts % consts for the experiment
        win % window/screen for Psychtoolbox
        aud % audio
        imgs % images
        keys % keyboard
        feed % keyboard feedback
        data_summary % for easy analyses (each row is a response)
        data_long % complete data, including times of onset for everything
        %data_nested % optional? nested-style data, which allows for varying
                    % numbers of events per trial
    end

    methods
        function self = TimedResp
            self = self@StateMachine;
            self.p.FunctionName = 'TimedResp';
            self.ref_time = GetSecs;

            consts = struct('win_size', [30 30 400 400], ...
                            'reversed', false)
            self.consts = consts;

        end

        function Setup(s)
            Screen('Preference', 'Verbosity', 1);
            if s.consts.reversed
                front_color = [0 0 0];
                back_color = [255 255 255];
            else
                front_color = [255 255 255];
                back_color = [0 0 0];
            end
            s.win = PsychWindow(0, true, 'rect', s.consts.win_size,...
                                'color', back_color, ...
                                'alpha_blending', true);

            % add audio
            snd1 = GenClick(1046, 0.45, 3); % from ptbutils
            load('misc/sounds/scaled_coin.mat');

            s.aud = PsychAudio('mode', 9);
            s.aud.AddSlave(1, 'channels', 2);
            s.aud.AddSlave(2, 'channels', 2);

            s.aud.FillBuffer([snd1; snd1]', 1);
            s.aud.FillBuffer([snd2; snd2]', 2);

            % add images
            if s.tgt.image_type(1)
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

            s.keys = BlamKeyboard(unique(s.tgt.finger_index));
            l_keys = length(s.keys.valid_indices);

            % add feedback
            s.feed = BlamKeyFeedback(l_keys, 'fill_color', back_color, ...
                                     'frame_color', front_color, ...
                                     'rel_x_scale', repmat(0.06, 1, l_keys));
        end % end setup

        function Execute(s)
            done = false;
            time_flip = GetSecs;
            state = 'intrial';
            neststate = 'prep';
            trial_count = 1;
            while ~(GetSecs - s.ref_time > 4200) || done
                loop_time = GetSecs;

                switch state
                    case 'intrial'
                        switch neststate
                            case 'prep'
                            % all pre-trial things
                                audio_played = false;
                                trial_time = aud.Play(GetSecs + 0.1, 1);
                                img_time = trial_time + s.tgt.image_time()

                                neststate = 'doneprep';

                            case 'doneprep'
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
                        trial_count = trial_count + 1;

                    otherwise
                        error('Invalid state.')

                end
                s.win.DrawingFinished();
                % collect button presses, write data... anything not timing critical
                time_flip = s.win.Flip(time_flip + (0.7 * s.win.flip_interval));
                if trial_count > max(s.tgt.trial)
                    done = true;
                end
            end

        end % end execute

        function Cleanup(self)
            BailPtb;
            %...
        end

    end % end methods
end % end classdef
