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
        
        window_time = win.Flip();
        block_start = window_time;
        dat.block_start = window_time;
        kbrd.Start;
        
        while ~done
            if trial_count > length(tgt.trial)
                break;
            end
            
            [~, presses, ~, releases] = kbrd.Check; % use for experimenter feedback
            
            switch state
                case 'pretrial'
                    
                    if 
                    
                case 'prep'
                    
                case 'gonogo'
                    
            end
            
        end
            
        
        
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