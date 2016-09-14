function dat = FreeResp(id, file_name, fullscreen)
% strong assumptions made (5 choice only!)
%
% Example:
%     data = FreeResp('misc/tgt/day1_block1.tgt', false, false);
%                           tgt file    force transducers  fullscreen
%     try
        %% Setup

        SetupRt;

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
        substate = 'allgood'; % allgood, doghouse (ignore responses)
        num_tries = 1; % number of guesses attempted
        c_c_combo = 1;

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

            switch state
                case 'pretrial'
                    [~, ~, dat.trial(trial_count).between_data] = kbrd.CheckMid();
                    trial_start = aud.Play(1, window_time + win.flip_interval);
                    dat.trial(trial_count).trial_start = trial_start - block_start;
                    imgs.Draw(tgt.image_index(trial_count));
                    state = 'intrial';
                case 'intrial'
                    imgs.Draw(tgt.image_index(trial_count));
                    switch substate
                        case 'allgood'
                            if ~isnan(presses)
                                dat.trial(trial_count).guesses(num_tries) = find(presses);
                                if tgt.finger_index(trial_count) == find(presses)
                                    resp_feedback.SetFill(find(presses), 'green');
                                    tmp_press_index = find(presses);
                                    wrong = false;
                                    state = 'feedback';
                                    feedback_time = GetSecs + 0.2;
                                    feed = true;
                                else
                                    % only allow a few guesses
                                    if num_tries < 3
                                        substate = 'doghouse';
                                        num_tries = num_tries + 1;
                                        wrong_img.Draw(1:2);
                                        resp_feedback.SetFill(find(presses), 'red');
                                        tmp_press_index = find(presses);
                                        stop_penalty = GetSecs + 1;
                                    else
                                        wrong = true;
                                        state = 'feedback';
                                        feedback_time = GetSecs + 0.4;
                                        feed = true;

                                    end
                                end

                            end
                        case 'doghouse'

                            if GetSecs >= stop_penalty
                                substate = 'allgood';
                            else
                                resp_feedback.SetFill(kbrd.valid_indices(tmp_press_index), 'red');
                                wrong_img.Draw(1:2);
                            end
                    end

                case 'feedback'
                    if feed
                        [first_press, time_press, post_data] = kbrd.CheckMid();
                        dat.trial(trial_count).within_data = post_data;
                        dat.trial(trial_count).time_press = time_press - trial_start;
                        dat.trial(trial_count).index_press = first_press;
                        if wrong
                            c_c_combo = 1;
                            dat.trial(trial_count).correct = false;
                        else
                            if num_tries == 1
                                dat.trial(trial_count).correct = true;
                                c_c_combo = c_c_combo + 1;
                                if c_c_combo > 8
                                    c_c_combo = 8;
                                end
                                aud.Stop(1);
                                aud.Play(c_c_combo + 1, 0);
                            else
                                c_c_combo = 1;
                                dat.trial(trial_count).correct = false;
                            end
                        end
                        feed = false;
                        num_tries = 1;
                    end
                    if wrong
                        resp_feedback.SetFill(tgt.finger_index(trial_count), 'blue');
                    else
                        resp_feedback.SetFill(tmp_press_index, 'green');
                    end

                    if GetSecs >= feedback_time
                        state = 'pretrial';
                        substate = 'allgood';
                        frame_count = 1;
                        trial_count = trial_count + 1;
                    end
            end % end state machine
            resp_feedback.Prime();
            resp_feedback.Draw();
            window_time = win.Flip(window_time + 0.8 * win.flip_interval);
            frame_count = frame_count + 1;
            pause(1e-5);

            dat.trial(trial_count).frames(frame_count).push_data = kbrd.short_term;
            dat.trial(trial_count).frames(frame_count).state = state;
            dat.trial(trial_count).frames(frame_count).time_frame = window_time;
        end % end event loop, cleanup

        WaitSecs(0.3);
        sca;
        PsychPortAudio('Close');
        kbrd.Stop;
        dat.presses = kbrd.long_term;
        kbrd.Close;
        aud.Close;
        imgs.Close;
        win.Close;


%     catch ERR
%         % try to clean up resources
%         sca;
%         try
%             PsychPortAudio('Close');
%         catch
%             disp('No audio device open.');
%         end
%         KbQueueRelease;
%         rethrow(ERR);
%     end
end
