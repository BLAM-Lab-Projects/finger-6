function out_data = TimedResp(id, file_name, forces, fullscreen)
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
            if forces
                % figure out presses (need to compare current press data w/previous)
            else % keyboard
                [press_time, presses, release_time, releases] = kbrd.Check;
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
                        if tgt.finger_index(trial_counter) == first_press % nonexistant
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
