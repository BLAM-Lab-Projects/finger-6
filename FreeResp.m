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