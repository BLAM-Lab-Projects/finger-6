function dat = TimedResp(id, file_name, fullscreen)
% strong assumptions made (5 choice only!)
%
% Example:
%     data = TimedResp('misc/tgt/day1_block1.tgt', false, false);
%                           tgt file    force transducers  fullscreen
    try
        %% Setup

        SetupTr;

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
        trial_count = 1;
        frame_count = 1;
        state = 'pretrial';
        first_press = nan;

        window_time = win.Flip();
        block_start = window_time; % use
        dat.block_start = window_time;       

        % event loop/state machine
        while ~done
            if trial_count > length(tgt.trial)
                % end of experiment
                break;
            end

            % short-term (and unsophisticated) check for keyboard presses
            [~, presses, ~, releases] = kbrd.Check;

            if ~isnan(presses)
                resp_feedback.SetFill(find(presses), 'green');
            end
            if ~isnan(releases)
                resp_feedback.SetFill(find(releases), 'black');
            end
            
            % begin state machine
            switch state
                case 'pretrial'
                    % Dump non-relevant data elsewhere (but still
                    % accessible)
                    [~, ~, dat.trial(trial_count).between_data] = kbrd.CheckMid();
                    % schedule audio for next window flip onset
                    trial_start = Play(1, window_time + win.flip_interval);
                    dat.trial(trial_count).trial_start = trial_start - block_start;
                    state = 'intrial';
                case 'intrial'
                    % display the image
                    if GetSecs >= dat.trial(trial_count).time_image + trial_start
                        if tgt.image_index(trial_count) ~= -1
                            tmp_image = 1;
                            imgs.Draw(tgt.image_index(trial_count));
                            % figure out the actual time of stimulus
                            % presentation
                            dat.trial(trial_count).time_image_real = window_time + win.flip_interval - trial_start;
                        end
                    end
                    
                    % Wrap up trial if almost done
                    if GetSecs >= trial_start + last_beep + 0.2
                        [first_press, time_press, post_data] = kbrd.CheckMid();
                        dat.trial(trial_count).index_press = first_press;
                        dat.trial(trial_count).time_press = time_press - trial_start;
                        % force transducer times are relative to the start
                        % of the trial
                        post_data(:, 1) = post_data(:, 1) - trial_start;
                        dat.trial(trial_count).within_data = post_data;
                        
                        % handle catch trial 'correctness'
                        if tgt.image_index(trial_count) ~= -1
                            dat.trial(trial_count).catch_trial = false;
                            dat.trial(trial_count).correct = first_press == tgt.trial(trial_count).index_finger;
                        else
                            dat.trial(trial_count).catch_trial = true;
                            dat.trial(trial_count).correct = nan;
                        end
                            
                        state = 'feedback';
                        start_feedback = GetSecs;
                        stop_feedback = start_feedback + 0.2;
                    end
                case 'feedback'
                    % feedback for correct index
                    if tgt.image_index ~= -1
                        if dat.trial(trial_count).correct || ...
                                isnan(dat.trial(trial_count).correct) % nonexistant
                            resp_feedback.SetFill(first_press, 'green');
                        else
                            resp_feedback.SetFill(first_press, 'red');
                            resp_feedback.SetFrame(tgt.finger_index(trial_count), 'green');
                        end
                    end

                    % feedback for correct timing
                    if abs(time_press - last_beep) > 0.1
                        % bad
                    else
                        % good -- happy ding
                        aud.Play(2, 0);
                    end

                    if GetSecs >= stop_feedback
                        state = 'posttrial';
                                                
                        trial_count = trial_count + 1;
                        first_press = nan;
                        resp_feedback.Reset;
                        frame_count = 1;
                        next_trial = GetSecs + 0.4;
                    end
                case 'posttrial'
                    if GetSecs >= next_trial
                        state = 'pretrial';
                    end
            end % end state machine
            resp_feedback.Prime();
            resp_feedback.Draw();
            % optimize drawing?
            %Screen('DrawingFinished', win.pointer);
            window_time = win.Flip(window_time + 0.8 * win.flip_interval);
            frame_count = frame_count + 1;
            
            dat.trial(trial_count).frames(frame_count).push_data = kbrd.short_term;
            dat.trial(trial_count).frames(frame_count).state = state;
            dat.trial(trial_count).frames(frame_count).image = tmp_image;
            tmp_image = 0;
            dat.trial(trial_count).frames(frame_count).time_frame = window_time;
            
        end % end event loop, cleanup
        
        sca;
        PsychPortAudio('Close');
        kbrd.Close;
        aud.Close;
        imgs.Close;
        win.Close;


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
