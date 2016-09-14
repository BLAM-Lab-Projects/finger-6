function dat = FreeResp(id, file_name, fullscreen)
% strong assumptions made (5 choice only!)
%
% Example:
%     data = FreeResp('misc/tgt/day1_block1.tgt', false, false);
%                           tgt file    force transducers  fullscreen
    try
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
        first_press = nan;
        num_tries = 1; % number of guesses attempted
        c_c_combo = 1;

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
                resp_feedback.SetFill(find(presses), 'gray');
            end
            if ~isnan(releases)
                resp_feedback.SetFill(find(releases), 'black');
            end

            switch state
                case 'pretrial'
                    [~, ~, dat.trial(trial_count).between_data] = kbrd.CheckMid();
                    trial_start = Play(1, window_time + win.flip_interval);
                    dat.trial(trial_count).trial_start = trial_start - block_start;
                    imgs.Draw(tgt.image_index(trial_count));
                    state = 'intrial';
                case 'intrial'
                    switch substate
                        case 'allgood'
                            if ~isnan(presses)
                                if tgt.trial(trial_count).index_finger == kbrd.valid_indices(logical(presses))
                                    resp_feedback.SetFill(kbrd.valid_indices(logical(presses)), 'green');
                                    wrong = false;
                                    state = 'feedback';
                                    feedback_time = GetSecs + 0.2;
                                else
                                    % only allow a few guesses
                                    if num_tries < 3
                                        substate = 'doghouse';
                                        num_tries = num_tries + 1;
                                        wrong_img.Draw(1);
                                        resp_feedback.SetFill(kbrd.valid_indices(logical(presses)), 'red');

                                        stop_penalty = GetSecs + 1;
                                    else
                                        wrong = true;
                                        state = 'feedback';
                                        feedback_time = GetSecs + 0.2;

                                    end
                                end

                            end
                        case 'doghouse'

                            if GetSecs >= stop_penalty
                                substate = 'allgood';
                            else
                                resp_feedback.SetFill(kbrd.valid_indices(logical(presses)), 'red');
                                wrong_img.Draw(1);
                            end
                    end

                case 'feedback'
                    if wrong
                        c_c_combo = 1;
                        resp_feedback.SetFill(find(tgt.trial(trial_count).index_finger == kbrd.valid_indices), 'blue');
                    else
                        resp_feedback.SetFill(kbrd.valid_indices(logical(presses)), 'green');
                        if num_tries == 1
                            c_c_combo = c_c_combo + 1;
                            if c_c_combo > 8
                                c_c_combo = 8;
                            end
                            aud.Stop(1);
                            aud.Play(c_c_combo + 1, 0);
                        end
                    end

                    if GetSecs >= feedback_time
                        state = 'pretrial';
                        frame_count = 1;
                        trial_count = trial_count + 1;
                        first_press = nan;
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
