function dat = TimedResp(id, file_name, fullscreen)
% strong assumptions made (5 choice only!)
%
% Example:
%     data = TimedResp('misc/tgt/day1_block1.tgt', false, false);
%                           tgt file    force transducers  fullscreen
%     try
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
        tmp_image = 0;
        save_time = false;

        window_time = win.Flip();
        block_start = window_time; % use
        dat.block_start = window_time;     
        kbrd.Start;

        % event loop/state machine
        while ~done
            if trial_count > length(tgt.trial)
                % end of experiment
                break;
            end

            % short-term (and unsophisticated) check for keyboard presses
            [~, presses, ~, releases] = kbrd.Check;

            if ~isnan(presses)
                resp_feedback.SetFill(find(presses), 'gray');
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
                    trial_start = aud.Play(1, window_time + win.flip_interval);
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
                            if save_time
                                save_time = false;
                                dat.trial(trial_count).time_image_real = window_time + win.flip_interval - trial_start;
                            end
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
                        
                        dat.trial(trial_count).time_preparation = dat.trial(trial_count).time_press - ...
                                                                  dat.trial(trial_count).time_image_real;
                        % handle catch trial 'correctness'
                        if tgt.image_index(trial_count) ~= -1
                            dat.trial(trial_count).catch_trial = false;
                            dat.trial(trial_count).correct = first_press == tgt.finger_index(trial_count);
                        else
                            dat.trial(trial_count).catch_trial = true;
                            dat.trial(trial_count).correct = nan;
                        end
                            
                        state = 'feedback';
                        start_feedback = GetSecs;
                        stop_feedback = start_feedback + 0.2;                    
                        % feedback for correct timing
                        if abs(time_press - last_beep - trial_start) > 0.1 || isnan(time_press)
                            % bad
                            disp('nobeep');
                            disp((time_press - last_beep - trial_start));
                        else
                            % good -- happy ding
                            aud.Play(2, 0);
                        end
                    end
                case 'feedback'
                    % feedback for correct index
                    aud.Stop(1);
                    if tgt.image_index ~= -1
                        if dat.trial(trial_count).correct || ...
                                isnan(dat.trial(trial_count).correct) % nonexistant
                            resp_feedback.SetFill(first_press, 'green');
                        else
                            if ~isnan(first_press)
                                resp_feedback.SetFill(first_press, 'red');
                            end
                            resp_feedback.SetFrame(tgt.finger_index(trial_count), 'green');
                        end
                    end

                    if GetSecs >= stop_feedback
                        state = 'posttrial';
                                                
                        trial_count = trial_count + 1;
                        first_press = nan;
                        resp_feedback.Reset;
                        frame_count = 1;
                        next_trial = GetSecs + 0.4;
                        save_time = true;
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
            pause(1e-5);
            
            dat.trial(trial_count).frames(frame_count).push_data = kbrd.short_term;
            dat.trial(trial_count).frames(frame_count).state = state;
            dat.trial(trial_count).frames(frame_count).image = tmp_image;
            tmp_image = 0;
            dat.trial(trial_count).frames(frame_count).time_frame = window_time;
            frame_count = frame_count + 1;

            
        end % end event loop, cleanup
        
        WaitSecs(.3);
        sca;
        PsychPortAudio('Close');
        kbrd.Stop;
        kbrd.Close;
        aud.Close;
        imgs.Close;
        win.Close;

% 
%     catch ERR
%         % try to clean up resources
%         sca;
%         try 
%             kbrd.Close;
%         catch
%             disp('No keyboard open');
%         end
%         try
%             PsychPortAudio('Close');
%         catch
%             disp('No audio device open.');
%         end
%         rethrow(ERR);
%     end
end
