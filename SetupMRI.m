% Offset the boilerplate stuff to make the main loop easier/shorter to read

%% Add paths
Screen('Preference', 'SkipSyncTests', 1); 
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

win = PobWindow('screen', max(Screen('screens')), ...
                'color', [0 0 0], ...
                'rect', win_size);

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
             'rel_x_scale', 0.35, ...
             'rel_y_scale', nan);
end

%% Set up text
helptext = ['This experiment is \nthe MRI one.\n', ...
            'Waiting for the initial TR.'];

info_txt = PobText('value', helptext, 'size', 40, ...
                   'color', [255 255 255], ...
                   'rel_x_pos', 0.5, ...
                   'rel_y_pos', 0.5, ...
                   'style', 'bold');

%% Set up responses & feedback

% use entire right hand
if ~simulate_resp
kbrd = BlamForceboard(1:5);
end

feedback = PobRectangle();

feedback.Add(1, 'rel_x_pos', 0.5, ...
             'rel_y_pos', 0.5, ...
             'rel_x_scale', 0.4, ...
             'rel_y_scale', nan, ...
             'fill_color', [255 255 255], ...
             'fill_alpha', 0, ...
             'frame_color', [255 255 255]);
feedback2 = PobRectangle();

feedback2.Add(1, 'rel_x_pos', 0.5, ...
             'rel_y_pos', 0.5, ...
             'rel_x_scale', 0.4, ...
             'rel_y_scale', nan, ...
             'fill_color', [255 255 255], ...
             'fill_alpha', 0, ...
             'frame_color', [255 255 255], ...
             'frame_stroke', 30);
%% Register relative to window
imgs.Register(win.pointer);
feedback.Register(win.pointer);
% feedback2.Register(win.pointer);
imgs.Prime();
feedback.Prime();
% feedback2.Prime();

info_txt.Register(win.pointer);

%% TR obj (plus other keys)
if ~simulate
    tr = BlamTr();
else
    % do something else?
end

%% Data storage

tr_struct = struct('times', zeros(1, max(tgt.trnum)),...
                   'count', zeros(1, max(tgt.trnum)));

trial(1:length(tgt.trial)) = struct('trial_start', [], ... x
    'between_data', [], ...x
    'within_data', [], ...x
    'image_index', [], ...x
    'finger_index', [], ...x
    'stim_delay', [], ...x
    'stim_time', [], ...x
    'go_delay', [], ...x
    'go_time', [], ...x
    'trnum', [], ...x
    'trial_type', [], ...x
    'press_index', [], ...x
    'press_time', []); % which finger was pressedx

for ii = 1:length(tgt.trial)
    trial(ii).image_index = tgt.image_index(ii);
    trial(ii).finger_index = tgt.finger_index(ii);
    trial(ii).trnum = tgt.trnum(ii);
    trial(ii).stim_delay = tgt.stim_delay(ii);
    trial(ii).go_delay = tgt.go_delay(ii);
    trial(ii).trial_type = tgt.trial_type(ii);
end

dat = struct('trial', trial, ...
    'id', id, ...
    'session', tgt.sess(1), ...
    'shapes', tgt.image_type(1), ...
    'block_start', [], ...x
    'presses', [], ...x
    'tr', tr_struct);
