function dat  = MRI(id, file_name, fullscreen, simulate, simulate_resp)
% dat = MRI(id, file_name, fullscreen, simulate_tr, simulate_resp)

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
        draw_imgs = false;
        draw_go = false;
        
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
                tr_struct.count(tr_count) = tr_count;
                tr_struct.times(tr_count) = key_times(ismember(key_vals, {'t', '5'}));
            end
            WaitSecs(.1); % rate limit for no good reason
            end
        end
        
        window_time = win.Flip();
        block_start = window_time;
        dat.block_start = block_start;
        if ~simulate_resp
            kbrd.Start;
        end
        
        Priority(win.priority);
        while ~done
            if trial_count > length(tgt.trial)
                break;
            end
            if ~simulate_resp
            [~, presses, ~, releases] = kbrd.Check; % use for experimenter feedback
            else
                presses = binornd(1, .2);
                if presses == 0
                    presses = nan;
                end
            end
            if ~isnan(presses)
               feedback.Set(1, 'frame_color', [150 150 150]); % gray
            else
               feedback.Set(1, 'frame_color', [255 255 255]);
            end
            
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
                    disp(['TR number: ', num2str(tr_count)]);
                    tr_struct.count(tr_count) = tr_count;
                    tr_struct.times(tr_count) = key_times(ismember(key_vals, {'t', '5'}));
                end     
            end
            
            switch state
                case 'pretrial'
                    draw_go = true;
                    % check if it's time to start the trial
                    if tr_count >= tgt.trnum(trial_count)
                        state = 'prep';
                        trial_start = GetSecs;
                        dat.trial(trial_count).trial_start = trial_start;
                        dat.trial(trial_count).trnum = tr_count;
                    end
                case 'prep'
                    % draw the image
                    draw_go = true;
                    if GetSecs >= tgt.stim_delay(trial_count) + trial_start
                        if ~simulate_resp
                            [~, ~, dat.trial(trial_count).between_data] = kbrd.CheckMid();                       
                        end
                        if tgt.image_index(trial_count) ~= 0
                            %imgs.Draw(tgt.image_index(trial_count));
                            draw_imgs = true;
                            draw_go = false;
                        else
                            draw_go = true;
                        end
                        dat.trial(trial_count).stim_time = window_time + win.flip_interval;
                        save_time_go = true;
                        state = 'gonogo';
                        go_time = GetSecs + tgt.go_delay(trial_count); % when to draw go cue
                        stop_img_time = go_time - 1;
                        end_time = go_time + 1; % when to stop the go cue
                    end
                    
                case 'gonogo'
                    if tgt.image_index(trial_count) ~= 0
                        if GetSecs <= stop_img_time
                            draw_imgs = true;
                        else
                            draw_go = true;
                        end
                        %imgs.Draw(tgt.image_index(trial_count));
                        % go?
                        if GetSecs >= go_time
                            if tgt.trial_type(trial_count)
                                go_cue.Set('color', [97, 255, 77]); % green
                            else
                                go_cue.Set('color', [255, 30, 63]); % red
                            end
                            draw_go = true;
                            if save_time_go
                                save_time_go = false;
                                dat.trial(trial_count).go_time = window_time + win.flip_interval;
                            end
                        end
                    else % rest trial
                        draw_go = true;
                    end

                    if GetSecs >= end_time
                        go_cue.Set('color', [255 255 255]);
                        draw_go = true;
                        if ~simulate_resp
                            [first_press, time_press, dat.trial(trial_count).within_data] = kbrd.CheckMid();
                        else
                            first_press = 1;
                            time_press = GetSecs;
                        end
                        disp(['Trial: ' num2str(trial_count)]);
                        disp(['Press: ' num2str(first_press)]);
                        disp(['Image index: ' num2str(tgt.image_index(trial_count))]);
                        disp(['Go/nogo: ' num2str(tgt.trial_type(trial_count))]);
                        disp(['Rest: ' num2str(tgt.image_index(trial_count) == 0)]);
                        if tgt.image_index(trial_count) ~= 0
                            go_cue.Set('color', [255 255 255]);
                            draw_go = true;
                            if any(first_press == tgt.intended_finger(trial_count)) && tgt.trial_type(trial_count)
                                dat.trial(trial_count).correct = true;
                                tmp_color = [97 255 77 255]; % green
                            elseif any(isnan(first_press)) && ~tgt.trial_type(trial_count)
                                dat.trial(trial_count).correct = nan;
                                tmp_color = [97 255 77 255]; % green
                            elseif any(first_press ~= tgt.intended_finger(trial_count)) && tgt.trial_type(trial_count)
                                dat.trial(trial_count).correct = false;
                                tmp_color = [255 30 63 255]; % red
                            else
                                dat.trial(trial_count).correct = nan;
                            end
                          %  imgs.Set(tgt.image_index(trial_count),...
                          %           'modulate_color', tmp_color);
                         %   imgs.Prime();
                            %draw_imgs = true;
                           % imgs.Draw(tgt.image_index(trial_count));
                        else % rest trial
                            draw_go = true;
                        end
                        state = 'feedback';
                        draw_go = true;
                        dat.trial(trial_count).press_index = first_press;
                        dat.trial(trial_count).press_time = time_press;
                        end_feedback = GetSecs + .5;
                    end
                case 'feedback'
                    draw_go = true;
                    % change image color based on correctness
                    if tgt.image_index(trial_count) ~= 0
                        %imgs.Draw(tgt.image_index(trial_count));
                        %draw_imgs = true;
                    end
                    if GetSecs >= end_feedback
                        if tgt.image_index(trial_count) ~= 0
                            imgs.Set(tgt.image_index(trial_count), ...
                                'modulate_color', [255 255 255 255]);
                            imgs.Prime();
                        end
                        trial_count = trial_count + 1;
                        state = 'pretrial';
                    end
            end % end state machine
%             feedback2.Prime();
%             feedback2.Draw(1);
            feedback.Prime();
            feedback.Draw(1);
            
            if draw_go
                go_cue.Draw();
                draw_go = false;
            end
            
            if draw_imgs
                imgs.Prime();
                imgs.Draw(tgt.image_index(trial_count));
                draw_imgs = false;
            end
            
            pause(1e-7);
            window_time = win.Flip(window_time + 0.8 * win.flip_interval);
            
        end % end infinite loop
            
        WaitSecs(0.5);
        sca;
        dat.tr = tr_struct;
        if ~simulate_resp
            dat.presses = kbrd.long_term;         
            kbrd.Stop;
            kbrd.Close;
        end
        imgs.Close;
        win.Close;
        Priority(0);
        dat.tgt = tgt;
        disp(['Percent correct: ' num2str(mean([dat.trial.correct], 'omitnan'))]);
        disp(['Jumped the gun: ' num2str(mean(ismember([dat.trial.trial_type], ~isnan([dat.trial.press_index]))))]);
        
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