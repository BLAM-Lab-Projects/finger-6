function dat = MRI(id, file_name, fullscreen, attentions)

    try
        %% Setup
        SetupMRI;
        
        info_text.Draw();
        win.Flip();
        WaitSecs(2);
        
        % Send char to scanner, wait for first TR
        done = false;
        trial_count = 1;
        frame_count = 1;
        state = 'pretrial'; % pretrial, prep, gonogo
        tr_count = 0;
        tr_time0 = nan; % get time of first TR
        
        % wait for the first tr
        while tr_count < 1
            [key_times, key_vals] = tr.Check;
            if any(ismember(key_vals, {'t', '5'}))
                tr_count = tr_count + 1;
                tr_struct.count(tr_count) = tr_count;
                tr_struct.times(tr_count) = key_times(ismember(key_vals, {'t', '5'}));
            end
        end
        
        window_time = win.Flip();
        block_start = window_time;
        dat.block_start = block_start;
        kbrd.Start;
        
        while ~done
            if trial_count > length(tgt.trial)
                break;
            end
            
            [~, presses, ~, releases] = kbrd.Check; % use for experimenter feedback
            [key_times, key_vals] = tr.Check;
            if any(ismember(key_vals, {'t', '5'}))
                tr_count = tr_count + 1;
                tr_struct.count(tr_count) = tr_count;
                tr_struct.times(tr_count) = key_times(ismember(key_vals, {'t', '5'}));
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
                    end
                    
                case 'gonogo'
                    imgs.Draw(tgt.image_index(trial_count));
                    % go?
                    if GetSecs >= tgt.go_delay(trial_count)
                        feedback.Set(1, 'frame_color', [97, 255, 77]);
                        if save_time_go
                            save_time_go = false;
                            dat.trial(trial_count).time_go = window_time + win.flip_interval;
                        end
                    end
                    
                    if GetSecs >= tgt.go_delay(trial_count) + 1
                        feedback.Set(1, 'frame_color', [255 255 255]);
                        state = 'post';
                    end
                case 'post'
                    
                    
            end % end state machine
            
        end % end infinite loop
            
        
        
    catch ERR
        ShowCursor;
        sca;
        try
            kbrd.Close();
        catch
            disp('No keyboard open.');
        end
        rethrow(ERR);
    end
end