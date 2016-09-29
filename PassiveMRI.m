function dat  = PassiveMRI(file_name, fullscreen, simulate, simulate_resp)
% dat = MRI(file_name, fullscreen, simulate_tr, simulate_resp)

     try
        %% Setup
        SetupPassiveMRI;
        
        info_txt.Draw();
        win.Flip();
        WaitSecs(2);
        
        % Send char to scanner, wait for first TR
        tr_length = 1; % in seconds
        done = false;
        trial_count = 1;
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

        Priority(win.priority);
        while ~done
            if trial_count > length(tgt.trial)
                break;
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
                
                if ~isnan(key_times) && any(ismember(key_vals, {'ESCAPE'}))
                    error('Bailing out...');
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
                    if GetSecs >= trial_start
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
                        dat.trial(trial_count).stim_on_time = window_time + win.flip_interval;
                        save_time_go = true;
                        state = 'gonogo';
                        stim_off_time = window_time + win_flip + 1.5;
                        dat.trial(trial_count).stim_off_time = stim_off_time;
                        end_time = go_time + 1; % when to stop the go cue
                    end
                    
                case 'gonogo'
                    if tgt.image_index(trial_count) ~= 0
                        if GetSecs <= stim_off_time
                            draw_imgs = true;
                        else
                            draw_go = true;
                        end
                    else % rest trial
                        draw_go = true;
                    end

                    if GetSecs >= stim_off_time
                        go_cue.Set('color', [255 255 255]);
                        draw_go = true;
                        disp(['Trial: ' num2str(trial_count)]);
                        disp(['Image index: ' num2str(tgt.image_index(trial_count))]);
                        disp(['Rest: ' num2str(tgt.image_index(trial_count) == 0)]);
                        
                        tmp_color = [255 255 255];
                        state = 'pretrial';
                        trial_count = trial_count + 1;
                    end
            end % end state machine

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
        imgs.Close;
        win.Close;
        Priority(0);
        if ~exist(data_dir, 'dir')
            mkdir(data_dir);
        end
        save(data_name, 'dat');
    catch ERR
        ShowCursor;
        sca;
        try
            if ~exist(data_dir, 'dir')
                mkdir(data_dir);
            end
            save(data_name, 'dat');
        catch
            disp('No data open yet.');
        end
        Priority(0);
        rethrow(ERR);
    end
end