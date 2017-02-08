function dat = TimedResp(file_name, fullscreen)
% strong assumptions made (5 choice only!)
%
% Example:
%     data = TimedResp('misc/tgt/day1_block1.tgt', false);
%                           tgt file              fullscreen
    try
        %% Setup

        SetupTr;

        info_txt.Draw();
        win.Flip();
        WaitSecs(1);

        for ii = fliplr(1:5)
            helptext = ['Experiment starting in\n', ...
                        num2str(ii), ' seconds'];
            info_txt.Set('value', helptext);
            info_txt.Draw();
            win.Flip;
            WaitSecs(1);
        end
        % need to prime resp_feedback after each change??
        done = false;
        trial_count = 0;
        frame_count = 1;
        state = 'pretrial';
        first_press = nan;
        tmp_image = 0;
        save_image_time = true;
        goodjob = true;
        draw_feedback_txt = false;
        aud_feedback = true;

        window_time = win.Flip();
        block_start = window_time; % use
        dat.block_start = window_time;
        kbrd.Start;
        Priority(win.priority);

        %% event loop/state machine
        while ~done
            % check for end of block
            if trial_count > length(tgt.trial)
                % end of experiment
                break;
            end
			
			% bailout - hold escape
			[kd] = KbCheck();
			if kd
			    break;
			end

            % short-term (and unsophisticated) check for keyboard presses
            [~, presses, ~, releases] = kbrd.Check;

            if ~isnan(presses)
                feedback.Set(1, 'frame_color', [150 150 150]); % gray
            else
                feedback.Set(1, 'frame_color', [255 255 255]);
            end

            % begin state machine
            switch state
                case 'pretrial'
                    % Dump non-relevant data elsewhere (but still
                    % accessible)
                    startdev = true;
                    % schedule audio for next window flip onset
                    trial_start = aud.Play(1, window_time + win.flip_interval);
                    % absolute start of the trial
                    trial_count = trial_count + 1;
                    dat.trial(trial_count).trial_start = trial_start;
                    state = 'intrial';
                case 'intrial'
                    % display the image
                    if GetSecs >= dat.trial(trial_count).time_image + trial_start
                        if ~isnan(tgt.image_index(trial_count))
                            tmp_image = 1; % written to frame-specific data
                            imgs.Draw(tgt.image_index(trial_count));
                            % figure out the actual time of stimulus
                            % presentation
                            if save_image_time
                                save_image_time = false;
                                dat.trial(trial_count).time_image_real = window_time + win.flip_interval;
                            end
                        end
                    end

                    % Wrap up trial if almost done
                    if GetSecs >= trial_start + last_beep + 0.3
                        [first_press, time_press, post_data, max_press, t_max_press] = kbrd.CheckMid();
                        dat.trial(trial_count).index_press = first_press;
                        dat.trial(trial_count).time_press = time_press;
                        dat.trial(trial_count).max_press = max_press;
                        dat.trial(trial_count).time_max_press = t_max_press;
                        disp('First press: ');
                        disp(first_press);
                        disp('Requested finger: ');
                        disp(tgt.intended_finger(trial_count));
                        disp('Image index: ');
                        disp(tgt.image_index(trial_count));

                        
                        % force transducer times are relative to the start
                        % of the trial
                        post_data(:, 1) = post_data(:, 1);
                        dat.trial(trial_count).within_data = post_data;

                        dat.trial(trial_count).time_preparation = dat.trial(trial_count).time_press - ...
                                                                  dat.trial(trial_count).time_image_real;
                        % handle catch trial 'correctness'
                        if ~isnan(tgt.image_index(trial_count))
                            dat.trial(trial_count).catch_trial = false;
                            dat.trial(trial_count).correct = first_press == tgt.intended_finger(trial_count);
                        else
                            dat.trial(trial_count).time_image_real = nan;
                            dat.trial(trial_count).time_preparation = nan;
                            dat.trial(trial_count).catch_trial = true;
                            dat.trial(trial_count).correct = nan;
                        end

                        state = 'feedback';
                        start_feedback = GetSecs;
                        stop_feedback = start_feedback + 0.3;

                        % feedback for correct timing
                        if abs(last_beep - (min(t_max_press) - trial_start)) > 0.1 || isnan(time_press)
                            % bad
                            disp(last_beep - (min(t_max_press) - trial_start))
                            if last_beep - (min(t_max_press) - trial_start) > 0.1
                                feedback_txt.Set('value', 'Too early.');
                            else % too early
                                feedback_txt.Set('value', 'Too late.');
                            end
                            feedback_txt.Draw();
                            draw_feedback_txt = true;
                            goodjob = false;
                        end
                    end
                case 'feedback'
                    % feedback for correct index
                    aud.Stop(1);
                    if draw_feedback_txt
                        feedback_txt.Draw();
                    end

                    if ~isnan(tgt.image_index(trial_count))
                        imgs.Draw(tgt.image_index(trial_count));
                        if dat.trial(trial_count).correct
                                feedback.Set(1, 'frame_color', [97, 255, 77]); % green
                        else
                            if ~isnan(first_press)
                                feedback.Set(1, 'frame_color', [255, 30, 63]); %red
                                goodjob = false;
                            end
                        end
                    else % catch trial feedback
                        if isnan(first_press)
                            feedback.Set(1, 'frame_color', [255, 30, 63]); %red
                            goodjob = false;
                        else
                            feedback.Set(1, 'frame_color', [97, 255, 77]); % green
                        end
                    end
                    
                    if goodjob && aud_feedback
                        aud_feedback = false;
                        aud.Play(2, 0);
                    end

                    if GetSecs >= stop_feedback
                        if isnan(first_press)
                            if ~isnan(presses)% at least made one press
                                state = 'posttrial';
                                next_trial = GetSecs + 0.6;
                                save_image_time = true;
                            end
                        else
                            state = 'posttrial';
                            next_trial = GetSecs + 0.6;
                            save_image_time = true;
                        end
                    end
                case 'posttrial'
                    if GetSecs >= next_trial
                        state = 'pretrial';
                        first_press = nan;
                        feedback.Set(1, 'frame_color', [255 255 255]); % white
                        frame_count = 0;
                        goodjob = true;
                        draw_feedback_txt = false;
                        aud_feedback = true;
                    end
            end % end state machine
            feedback.Prime();
            feedback.Draw(1);
            % optimize drawing?
            Screen('DrawingFinished', win.pointer);
            if startdev
                [~, ~, dat.trial(trial_count).between_data] = kbrd.CheckMid();
                startdev = false;
            end
            pause(1e-5);
            frame_count = frame_count + 1;
            dat.trial(trial_count).frames(frame_count).push_data = kbrd.short_term;
            dat.trial(trial_count).frames(frame_count).state = state;
            dat.trial(trial_count).frames(frame_count).image = tmp_image;
            tmp_image = 0;
            dat.trial(trial_count).frames(frame_count).time_frame = window_time;
            window_time = win.Flip(window_time + 0.8 * win.flip_interval);

        end % end event loop, cleanup

        WaitSecs(0.5);
        dat.presses = kbrd.long_term;
        sca;
        PsychPortAudio('Close');
        kbrd.Stop;
        kbrd.Close;
        aud.Close;
        imgs.Close;
        win.Close;
        Priority(0);
        if ~exist(data_dir, 'dir')
            mkdir(data_dir);
        end
        save(data_name, 'dat');


    catch ERR
        % try to clean up resources
        ShowCursor;
        Priority(0);
        sca;
        try
            kbrd.Close;
        catch
            disp('No keyboard open');
        end
        try
            PsychPortAudio('Close');
        catch
            disp('No audio device open.');
        end
        if ~exist(data_dir, 'dir')
            mkdir(data_dir);
        end
        save(data_name, 'dat');
        
        rethrow(ERR);
    end
end
