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
        % Tack on sub-subdir here if need separate groups
        img_dir = ['misc/images/', subdir];
        img_names = dir([img_dir, '/*.jpg']);
		for ii = 1:length(img_names)
            tmpimg = imcomplement(...
                imread([img_dir, img_names(ii).name])...
                );
			imgs.Add(ii, 'original_matrix', {tmpimg}, ...
			         'rel_x_pos', 0.5, ...
					 'rel_y_pos', 0.5, ...
					 'rel_x_scale', 0.3, ...
					 'rel_y_scale', nan);
		end
        

        aud = PobAudio;
		snd0 = GenClick(1046, 0.45, 3);
		% 0.02 is the size of one beep (fixed!)
		last_beep = (length(snd0) - 0.02 * 44100)/44100;
		snd1 = audioread('misc/sounds/scaled_coin.wav');
		
		aud.Add('slave', 1);
		aud.Add('slave', 2);
		aud.Add('buffer', 1, 'audio', [snd0; snd0]);
		aud.Add('buffer', 2, 'audio', [snd1, snd1]');
		aud.Map(1, 1);
		aud.Map(2, 2);
        %time_out = aud.Play(index, time);
		
        info_txt = PobText('size', 30, ...
		                   'color', [255 255 255], ...
						   'rel_x_pos', 0.5, ...
						   'rel_y_pos', 0.5);
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
        imgs.Prime();
        % imgs.Draw(index); % to draw
        info_txt.Register(win.pointer);
        resp_feedback.Register(win.pointer);
        resp_feedback.Prime();
        % need to prime resp_feedback after each change??


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
