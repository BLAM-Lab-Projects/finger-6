function [dat, tr_struct]  = MRI(id, file_name, fullscreen, simulate)

%     try
        %% Setup
        SetupMRI;
        
        info_txt.Draw();
        win.Flip();
        WaitSecs(2);
        
        % Send char to scanner, wait for first TR
        tr_length = 1; % in seconds
        done = false;
        trial_count = 1;
        frame_count = 1;
        state = 'pretrial'; % pretrial, prep, gonogo
        tr_count = 0;
        
        if simulate
            baseline = GetSecs;
        else
            tr.Start();
        end
        
        % wait for the first tr
        while tr_count < tr_length
            if simulate
                if GetSecs - baseline > tr_length
                    tr_count = tr_count + 1;
                    tr_struct.count(tr_count) = tr_count;
                    baseline = GetSecs;
                    tr_struct.times(tr_count) = baseline;
                end
            else
            [key_times, key_vals] = tr.Check;
            if ~isnan(key_vals) && any(ismember(key_vals, {'t', '5'}))
                tr_count = tr_count + 1;
                tr_struct.count(tr_count - 1) = tr_count;
                tr_struct.times(tr_count - 1) = key_times(ismember(key_vals, {'t', '5'}));
            end
            WaitSecs(.1); % rate limit for no good reason
            end
        end
        
        window_time = win.Flip();
        block_start = window_time;
        dat.block_start = block_start;
        kbrd.Start;
        
        Priority(win.priority);
        while ~done
            if trial_count > length(tgt.trial)
                break;
            end
            
            [~, presses, ~, releases] = kbrd.Check; % use for experimenter feedback
%             if ~isnan(presses)
%                feedback2.Set(1, 'frame_color', [150 150 150]); % gray
%             else
%                feedback2.Set(1, 'frame_color', [255 255 255]);
%             end
            
            if simulate
                if GetSecs - baseline > 1
                    tr_count = tr_count + 1;
                    disp(['TR number: ', num2str(tr_count)]);
                    baseline = GetSecs;
                    tr_struct.count(tr_count) = tr_count;
                    tr_struct.times(tr_count) = baseline;
                end
            else
                [key_times, key_vals] = tr.Check;
                if ~isnan(key_times) && any(ismember(key_vals, {'t', '5'}))
                    tr_count = tr_count + 1;
                    tr_struct.count(tr_count) = tr_count;
                    tr_struct.times(tr_count) = key_times(ismember(key_vals, {'t', '5'}));
                end     
            end
            
            switch state
                case 'pretrial'
                    % check if it's time to start the trial
                    if tr_count == tgt.trnum(trial_count)
                        state = 'prep';
                    end
                case 'prep'
                    % draw the image
                    if GetSecs >= tgt.stim_delay(trial_count)
                        [~, ~, dat.trial(trial_count).between_data] = kbrd.CheckMid();                       
                        imgs.Draw(tgt.image_index(trial_count));
                        dat.trial(trial_count).time_image_real = window_time + win.flip_interval;
                        save_time_go = true;
                        state = 'gonogo';
                        go_time = GetSecs + tgt.go_delay(trial_count); % when to draw go cue
                        end_time = go_time + 1; % when to stop the go cue
                    end
                    
                case 'gonogo'
                    imgs.Draw(tgt.image_index(trial_count));
                    % go?
                    if GetSecs >= go_time
                        if tgt.trial_type(trial_count)
                            feedback.Set(1, 'frame_color', [97, 255, 77]);
                        else
                            feedback.Set(1, 'frame_alpha', 0);
                        end
                        if save_time_go
                            save_time_go = false;
                            dat.trial(trial_count).time_go = window_time + win.flip_interval;
                        end
                    end
                    
                    if GetSecs >= end_time
                        feedback.Set(1, 'frame_color', [255 255 255]);
                        state = 'feedback';
                        [first_press, time_press, post_data] = kbrd.CheckMid();
                        if first_press == tgt.finger_index(trial_count)
                            tmp_color = [97 255 77 255];
                        else
                            tmp_color = [255, 30, 63 255];
                        end
                        imgs.Set(tgt.image_index(trial_count),...
                                 'modulate_color', tmp_color);
                        imgs.Prime();
                        imgs.Draw(tgt.image_index(trial_count));
                        end_feedback = GetSecs + .5;
                    end
                case 'feedback'
                    % change image color based on correctness
                    if GetSecs >= end_feedback
                        feedback.Set(1, 'frame_alpha', 255);
                        imgs.Set(tgt.image_index(trial_count), ...
                            'modulate_color', [255 255 255 255]);
                        imgs.Prime();
                        trial_count = trial_count + 1;
                        state = 'pretrial';
                    end
            end % end state machine
%             feedback2.Prime();
%             feedback2.Draw(1);
            feedback.Prime();
            feedback.Draw(1);
            
            pause(1e-7);
            window_time = win.Flip(window_time + 0.8 * win.flip_interval);
            
        end % end infinite loop
            
        WaitSecs(0.5);
        dat.presses = kbrd.long_term;
        sca;
        kbrd.Stop;
        kbrd.Close;
        imgs.Close;
        win.Close;
        
%     catch ERR
%         ShowCursor;
%         sca;
%         try
%             kbrd.Close();
%         catch
%             disp('No keyboard open.');
%         end
%         rethrow(ERR);
%     end
end