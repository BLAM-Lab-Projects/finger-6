% Offset the boilerplate stuff to make the main loop easier/shorter to read

%% Add paths
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

win = PobWindow('screen', 0, ...
                'color', [0 0 0], ...
                'rect', win_size);

%% Set up audio
aud = PobAudio;
snd0 = GenClick(1046, 0.45, 3);
% 0.02 is the size of one beep (fixed!)
last_beep = (length(snd0) - 0.02 * 44100)/44100;
snd1 = audioread('misc/sounds/smw_coin.wav');

aud.Add('slave', 1);
aud.Add('slave', 2);
aud.Add('buffer', 1, 'audio', [snd0; snd0]);
aud.Add('buffer', 2, 'audio', [snd1, snd1]');
aud.Map(1, 1);
aud.Map(2, 2);
% audio warmup
aud.Play(1, 0);
aud.Stop(1);
%time_out = aud.Play(index, time);

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
             'rel_x_scale', 0.25, ...
             'rel_y_scale', nan);
end

%% Set up text
helptext = ['This experiment is\nTimed Response.\n', ...
            'Here is more text'];

info_txt = PobText('value', helptext, 'size', 50, ...
                   'color', [255 255 255], ...
                   'rel_x_pos', 0.5, ...
                   'rel_y_pos', 0.5,...
                   'style', 'bold');

%% Set up responses & feedback
kbrd = BlamForceboard(1:5);

feedback = PobRectangle();

feedback.Add(1, 'rel_x_pos', 0.5, ...
             'rel_y_pos', 0.5, ...
             'rel_x_scale', 0.3, ...
             'rel_y_scale', nan, ...
             'fill_color', [255 255 255], ...
             'fill_alpha', 0, ...
             'frame_color', [255 255 255]);
         
feedback_txt = PobText('value', '', 'size', 50, ...
                   'color', [255, 30, 63], ...
                   'rel_x_pos', 0.5, ...
                   'rel_y_pos', 0.2,...
                   'style', 'bold');
%% Register relative to window
imgs.Register(win.pointer);
imgs.Prime();
% imgs.Draw(index); % to draw
info_txt.Register(win.pointer);
feedback.Register(win.pointer);
feedback_txt.Register(win.pointer);
feedback.Prime();

frames(1:350) = struct('push_data', [], ... % complete push data (timestamps, etc...)
                       ...                  % timestamps relative to the experiment starts
                       'state', [],... % state at the current frame
                       'image', 0, ... % image on during this frame?
                       'beep4', 0, ... % 4th beep during this frame?
                       'time_frame', []); % Time relative to block start

trial(1:length(tgt.trial)) = struct('trial_start', [], ... % trial time relative to the start of the experiment
                      'time_image', [], ... % image onset relative to time_start
                      'time_image_real', [], ... % image onset, accounting for rounding
                      'prop_image', [], ... % time of image proportional to last beep
                      'time_press', [], ... % time of press relative to time_start
                      'time_preparation', [], ... % time_press - time_image
                      'index_image', [], ... % image index
                      'index_press', [], ...  % which finger pressed
                      'intended_finger', [], ...
                      'correct', [], ... % index_press == index_finger
                      'frames', frames, ... % data for individual frames
                      'between_data', [], ... % data dump for between trials
                      'within_data', [], ... % data dump for within the trial
                      'sub_swap', [], ... % whether this trial contained swapped indices (t/f)
                      'catch_trial', []); % boolean (t/f)
% fill in trial-specific information
for ii = 1:length(tgt.trial)
    trial(ii).index_image = tgt.image_index(ii);
    trial(ii).intended_finger_finger = tgt.intended_finger(ii);
    trial(ii).time_prep = tgt.image_time(ii);
    trial(ii).time_image = last_beep - tgt.image_time(ii); % relative to end beep train
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
             'last_beep', last_beep, ...
             'presses', []); % time of the last beep, relative to the onset of audio
clear trial frame
