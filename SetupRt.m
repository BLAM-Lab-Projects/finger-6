addpath(genpath('Psychoobox'));
addpath(genpath('ptbutils'));
tgt = ParseTgt(file_name, ',');
tgt = struct2table(tgt); % R2013b ++!

%% Set up screen
Screen('Preference', 'Verbosity', 1);
if fullscreen
    win_size = [];
else
    win_size = [50 50 500 500];
end

win = PobWindow('screen', 0, ...
                'color', [0 0 0], ...
                'rect', win_size);

%% Set up audio
aud = PobAudio;
aud.Add('slave', 1);

snd0 = GenBeep(1046);
aud.Add('buffer', 1, 'audio', [snd0; snd0]);
aud.Map(1, 1);
% reward sounds
aud_names = dir('misc/sounds/orch*.wav');
for ii = 2:length(aud_names) + 1
    tmp = audioread(['misc/sounds/', aud_names(ii - 1).name]);
    aud.Add('slave', ii);
    aud.Add('buffer', ii, 'audio', tmp.');
    aud.Map(ii, ii);
end
% audio warmup
aud.Play(1, 0);
aud.Stop(1);

%% Set up images
imgs = PobImage;
if tgt.image_type(1)
    img_dir = 'misc/images/shapes/';
    img_names = dir('misc/images/shapes/*.png');
else
    img_dir = 'misc/images/hands/';
    img_names = dir('misc/images/hands/*.jpg');
end

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

%% Set up text
helptext = ['This experiment is\nFree Reaction Time.\n', ...
            'Here is more text'];

info_txt = PobText('value', helptext, 'size', 30, ...
                   'color', [255 255 255], ...
                   'rel_x_pos', 0.5, ...
                   'rel_y_pos', 0.5);
               
%% Set up responses & feedback
kbrd = BlamForceboard(6:10);

resp_feedback = BlamKeyFeedback(length(kbrd.valid_indices), ...
                                'fill_color', [0 0 0], ...
                                'frame_color', [255 255 255], ...
                                'rel_x_scale', 0.1);

%% Register relative to window
imgs.Register(win.pointer);
imgs.Prime();
% imgs.Draw(index); % to draw
info_txt.Register(win.pointer);
resp_feedback.Register(win.pointer);

%% Construct data
frames(1:350) = struct('push_data', [], ... % complete push data (timestamps, etc...)
                       ...                  % timestamps relative to the experiment starts
                       'state', [],... % state at the current frame
                       'image', 0, ... % image on during this frame?
                       'time_frame', []); % Time relative to block start

trial(1:length(tgt.trial)) = struct('trial_start', [], ... % trial time relative to the start of the experiment
                      'time_press', [], ... % time of press relative to time_start
                      'index_image', [], ... % image index
                      'index_press', [], ...  % which finger pressed
                      'index_finger', [], ...
                      'correct', [], ... % index_press == index_finger
                      'frames', frames, ...
                      'between_data', [], ... % data dump for between trials
                      'within_data', [], ... % data dump for within the trial
                      'sub_swap', []); 
% fill in trial-specific information
for ii = 1:length(tgt.trial)
    trial(ii).index_image = tgt.image_index(ii);
    trial(ii).index_finger = tgt.finger_index(ii);
    if (tgt.image_index(ii) == tgt.swap_index_1(ii)) || (tgt.image_index(ii) == tgt.swap_index_2(ii))
        trial(ii).sub_swap = true;
    else
        trial(ii).sub_swap = false;
    end
end
dat = struct('trial', trial, ...
             'id', [], ...
             'shapes', [], ...
             'swaps', [], ...
             'block_start', [], ... % absolute start time
             'tgt', table2struct(tgt)); % time of the last beep, relative to the onset of audio
clear trial frame