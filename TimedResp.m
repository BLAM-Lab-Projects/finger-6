function out_data = TimedResp(file_name, forces, fullscreen)
% strong assumptions made (5 choice only!)
%
% Example:
%     data = TimedResp('misc/tgt/day1_block1.tgt', false, false);
%                           tgt file    force transducers  fullscreen
    try
        %% Setup
        Screen('Preference', 'Verbosity', 1);
        addpath(genpath('Psychoobox'));
        addpath(genpath('ptbutils'));
        tgt = ParseTgt(file_name, ',');

        imgs = PobImage;
        if tgt.image_type(1)
            img_dir = 'misc/images/shapes/';
            img_names = dir('misc/images/shapes/*.png');
        else
            img_dir = 'misc/images/hands/';
            img_names = dir('misc/images/hands/*.jpg');
        end

		for ii = 1:length(img_names)
            tmpimg = imcomplement(...
                imread([img_dir, img_names(ii).name])...
                );
			imgs.Add(ii, 'original_matrix', {tmpimg}, ...
			         'rel_x_pos', 0.5, ...
					 'rel_y_pos', 0.5, ...
					 'rel_x_scale', 0.3, ...
					 'rel_y_scale', nan);
		end


        aud = PobAudio;
		snd0 = GenClick(1046, 0.45, 3);
		% 0.02 is the size of one beep (fixed!)
		last_beep = (length(snd0) - 0.02 * 44100)/44100;
		snd1 = audioread('misc/sounds/scaled_coin.wav');

		aud.Add('slave', 1);
		aud.Add('slave', 2);
		aud.Add('buffer', 1, 'audio', [snd0; snd0]);
		aud.Add('buffer', 2, 'audio', [snd1, snd1]');
		aud.Map(1, 1);
		aud.Map(2, 2);
        % audio warmup
        aud.Play(1, 0);
        aud.Stop(1);
        %time_out = aud.Play(index, time);

        helptext = ['This experiment is\nTimed Response.\n', ...
                    'Here is more text'];

        info_txt = PobText('value', helptext, 'size', 30, ...
		                   'color', [255 255 255], ...
						   'rel_x_pos', 0.5, ...
						   'rel_y_pos', 0.5);
        if forces
            error('Add force transducers.');
            % keybrd = BlamForces(6:10);
        else
            keybrd = BlamKeyboard(6:10);
        end
        resp_feedback = BlamKeyFeedback(length(keybrd.valid_indices), ...
                                        'fill_color', [0 0 0], ...
                                        'frame_color', [255 255 255], ...
                                        'rel_x_scale', 0.1);


        if fullscreen
            win_size = [];
        else
            win_size = [50 50 500 500];
        end

        win = PobWindow('screen', 0, ...
                        'color', [0 0 0], ...
                        'rect', win_size);
        imgs.Register(win.pointer);
        imgs.Prime();
        % imgs.Draw(index); % to draw
        info_txt.Register(win.pointer);
        resp_feedback.Register(win.pointer);
        resp_feedback.Prime();
        resp_feedback.Draw();

        info_txt.Draw();
        win.Flip();
        WaitSecs(2);

        for ii = 1:3
            helptext = ['Experiment starting in\n', ...
                        num2str(4 - ii), ' seconds'];
            info_txt.Set('value', helptext);
            info_txt.Draw();
            resp_feedback.Draw();
            win.Flip;
            WaitSecs(1);
        end
        % need to prime resp_feedback after each change??
        done = false;
        trial_counter = 1;
        state = 'pretrial';
        first_press = nan;

        window_time = win.Flip();


        % event loop/state machine
        while ~done
            if trial_counter > length(tgt.trial)
                % end of experiment
                break;
            end
            [press_time, presses, release_time, releases] = kbrd.Check;
            if forces
                % figure out presses (need to compare current press data w/previous)
            end
            if ~isnan(presses)
                resp_feedback.SetFill(find(presses), 'green');
                if state == 'intrial' && isnan(first_press)
                    first_press = find(presses);
                    time_first_press = press_time;
                end
            end
            if ~isnan(releases)
                resp_feedback.SetFill(find(releases), 'black');
            end

            switch state
                case 'pretrial'
                    % schedule audio for next window flip onset
                    aud.Play(1, window_time + win.flip_interval);
                    state = 'intrial';
                case 'intrial'
                    % image_time is a **proportion of the last beep**
                    if GetSecs >= ref_trial_time + tgt.image_time(trial_counter)*last_beep
                        if tgt.image_index ~= -1
                            imgs.Draw(tgt.image_index(trial_counter));
                        end
                    end

                    if GetSecs >= ref_trial_time + last_beep + 0.2
                        state = 'feedback';
                        start_feedback = GetSecs;
                        stop_feedback = start_feedback + 0.2;
                    end
                case 'feedback'
                    % feedback for correct index
                    if tgt.image_index ~= -1
                        if tgt.image_index(trial_counter) == first_press % nonexistant
                            resp_feedback.SetFill(first_press, 'green');
                        else
                            resp_feedback.SetFill(first_press, 'red');
                            resp_feedback.SetFrame(tgt.finger_index(trial_counter), 'green');
                        end

                        if GetSecs >= stop_feedback
                            state = 'posttrial';
                            trial_counter = trial_counter + 1;
                            first_press = nan;
                            resp_feedback.Reset;
                            next_trial = GetSecs + 0.5;
                        end
                    end % end feedback
                case 'posttrial'
                    if GetSecs >= next_trial
                        state = 'pretrial';
                    end
            end % end state machine
            resp_feedback.Prime();
            resp_feedback.Draw();
            window_time = win.Flip(window_time + 0.5 * win.flip_interval);

        end % end event loop, cleanup


    catch ERR
        % try to clean up resources
        sca;
        try
            PsychPortAudio('Close');
        catch
            disp('No audio device open.');
        end
        KbQueueRelease;
        rethrow(ERR);
    end
end
