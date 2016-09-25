Screen('Preference', 'SkipSyncTests', 1);
addpath(genpath('Psychoobox'));
addpath(genpath('ptbutils'));
tgt = ParseTgt(file_name, ',');
tgt = struct2table(tgt); % R2013b ++!

%% Set up screen
HideCursor;
Screen('Preference', 'Verbosity', 1);
if fullscreen
    win_size = [];
else
    win_size = [50 50 500 500];
end

win = PobWindow('screen', max(Screen('screens')), ...
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

% punishment sounds
snd1 = audioread('misc/sounds/barrierBeep.wav');
aud.Add('slave', 10);
aud.Add('buffer', 10, 'audio', [snd1, snd1]');
aud.Map(10, 10);
% audio warmup
aud.Play(1, 0);
aud.Stop(1);

%% Set up images
imgs = PobImage;
if tgt.image_type(1)
    img_dir = 'misc/images/shapes/';
    img_names = dir('misc/images/shapes/*.jpg');
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

feedback = PobRectangle();

feedback.Add(1, 'rel_x_pos', 0.5, ...
             'rel_y_pos', 0.5, ...
             'rel_x_scale', 0.35, ...
             'rel_y_scale', nan, ...
             'fill_color', [255 255 255], ...
             'fill_alpha', 0, ...
             'frame_color', [255 255 255]);

%% Set up text
helptext = ['This experiment is\nFree Reaction Time.\n', ...
            'Here is more text'];

info_txt = PobText('value', helptext, 'size', 50, ...
                   'color', [255 255 255], ...
                   'rel_x_pos', 0.5, ...
                   'rel_y_pos', 0.5,...
                   'style', 'bold');

%% Set up responses & feedback
kbrd = BlamForceboard(1:5);

%% Register relative to window
imgs.Register(win.pointer);
imgs.Prime();

info_txt.Register(win.pointer);
feedback.Register(win.pointer);
feedback.Prime();

%% Construct data
frames(1:350) = struct('push_data', [], ... % complete push data (timestamps, etc...)
                       ...                  % timestamps relative to the experiment starts
                       'state', [],... % state at the current frame
                       'time_frame', []); % Time relative to block start

trial(1:length(tgt.trial)) = struct('trial_start', [], ... % trial time relative to the start of the experiment
                      'time_press', [], ... % time of press relative to time_start
                      'index_image', [], ... % image index
                      'index_press', [], ...  % which finger pressed
                      'intended_finger', [], ...
                      'correct', [], ... % index_press == intended_finger
                      'frames', frames, ...
                      'between_data', [], ... % data dump for between trials
                      'within_data', [], ... % data dump for within the trial
                      'sub_swap', [],...
                      'guesses', []);
% fill in trial-specific information
for ii = 1:length(tgt.trial)
    trial(ii).index_image = tgt.image_index(ii);
    trial(ii).intended_finger = tgt.intended_finger(ii);
    if (tgt.image_index(ii) == tgt.swap_index_1(ii)) || (tgt.image_index(ii) == tgt.swap_index_2(ii))
        trial(ii).sub_swap = true;
    else
        trial(ii).sub_swap = false;
    end
end
dat = struct('trial', trial, ...
             'id', id, ...
             'shapes', tgt.image_type(1), ...
             'swaps', tgt.swapped(1), ...
             'block_start', [], ... % absolute start time
             'tgt', table2struct(tgt), ...
             'presses', []); % time of the last beep, relative to the onset of audio
clear trial frame
