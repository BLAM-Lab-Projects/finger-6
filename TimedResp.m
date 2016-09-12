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
                    dat.trial(trial_count).trial_start = Play(1, window_time + win.flip_interval) - block_start;
                    trial_start = dat.trial(trial_count).trial_start;
                    state = 'intrial';
                case 'intrial'
                    % display the image
                    if GetSecs - block_start >= dat.trial(trial_count).time_image
                        if tgt.image_index ~= -1
                            imgs.Draw(tgt.image_index(trial_count));
                            dat.trial(trial_count).time_image_real = window_time + win.flip_interval - trial_start;
                        end
                    end

                    if GetSecs >= ref_trial_time + last_beep + 0.2
                        [first_press, time_press, post_data] = kbrd.CheckMid();
                        dat.trial(trial_count).index_press = first_press;
                        dat.trial(trial_count).time_press = time_press - ;
                        state = 'feedback';
                        start_feedback = GetSecs;
                        stop_feedback = start_feedback + 0.2;
                    end
                case 'feedback'
                    % feedback for correct index
                    if tgt.image_index ~= -1
                        if tgt.finger_index(trial_count) == first_press % nonexistant
                            resp_feedback.SetFill(first_press, 'green');
                        else
                            resp_feedback.SetFill(first_press, 'red');
                            resp_feedback.SetFrame(tgt.finger_index(trial_count), 'green');
                        end
                    end

                    % feedback for correct timing

                    if GetSecs >= stop_feedback
                        state = 'posttrial';
                        trial_count = trial_count + 1;
                        first_press = nan;
                        resp_feedback.Reset;
                        next_trial = GetSecs + 0.5;
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
