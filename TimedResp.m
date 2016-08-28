function out_data = TimedResp(file_name, forces, fullscreen)
% strong assumptions made (5 choice only!)
%
% Example:
%     data = TimedResp('misc/tgt/day1_block1.tgt', false, false);
%                           tgt file    force transducers  fullscreen
    try
        Screen('Preference', 'Verbosity', 1);
        addpath(genpath('Psychoobox'));
        addpath(genpath('ptbutils'));
        tgt = ParseTgt(file_name, ',');

        imgs = PobImage;
        if tgt.image_type(1)
            subdir = 'shapes/';
        else
            subdir = 'hands/';
        end
        img_dir = ['misc/images/', subdir];
        img_names = dir([img_dir, '/*.jpg']);

        

        aud = PobAudio;
        info_txt = PobText;
        if forces
            error('Add force transducers.');
            % keybrd = BlamForces(6:10);
        else
            keybrd = BlamKeyboard(6:10);
        end
        resp_feedback = BlamKeyFeedback(length(keybrd.valid_indices), ...
                                        'fill_color', [0 0 0], ...
                                        'frame_color', [255 255 255], ...
                                        'rel_x_scale', 0.06);


        if fullscreen
            win_size = [];
        else
            win_size = [50 50 500 500];
        end

        win = PobWindow('screen', 0, ...
                        'color', [0 0 0], ...
                        'rect', win_size);
        imgs.Register(win.pointer);
        info_txt.Register(win.pointer);
        resp_feedback.Register(win.pointer);



    catch ERR
        sca;
        try
            PsychPortAudio('Close');
        catch
            warning('No audio device open.');
        end
        rethrow(ERR);
    end
end
