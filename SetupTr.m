% Offset the boilerplate stuff to make the main loop easier/shorter to read

%% Add paths
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
% audio warmup
aud.Play(1, 0);
aud.Stop(1);
%time_out = aud.Play(index, time);

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
helptext = ['This experiment is\nTimed Response.\n', ...
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

% time is the Psychtoolbox time of the frame, push_data is the raw
% data from the force transducers, state is the state machine state,
% image is whether the image appears in this frame or not,
frame(1:300) = struct('time', [], 'push_data', [], 'state', '', ...
               'beep4', false, 'image', false);

% frame is frame # in trial, rel_start is the start of the trial relative to
% the beginning of the block, resp1 is the first response, t_resp1 is the time
% of that response, image_index is the image shown (this is swapped),
% finger_index is the requested finger, correct is whether resp1 == finger_index,
% sub_swap is whether this particular trial contains a swapped image (redundant)
% rel_image_time*last_beep is the time of the image presentation
trial(1:length(tgt.trial)) = struct('frame', frame, 'trial_start', [], ...
                                    'resp1', [], 't_resp1', [], 'image_index', ...
                                    [], 'rel_image_time', [], 'finger_index', [], ...
                                    'correct', [], 'sub_swap', [], 'prop_image_time', [],...
                                    'between_data', []);
% fill in trial-specific information
for ii = 1:length(tgt.trial)
    trial(ii).image_index = tgt.image_index(ii);
    trial(ii).finger_index = tgt.finger_index(ii);
    trial(ii).prop_image_time = tgt.image_time(ii);
    trial(ii).rel_image_time = tgt.image_time(ii)*last_beep; % relative to trial start
    if (tgt.image_index(ii) == tgt.swap_index_1(ii)) || (tgt.image_index(ii) == tgt.swap_index_2(ii))
        trial(ii).sub_swap = true;
    else
        trial(ii).sub_swap = false;
    end
end

dat = struct('trial', trial, 'id', id, 'start_time', [],...
             'shapes', tgt.image_type(1), 'tgt', table2struct(tgt));
clear trial frame
