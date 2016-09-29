% Offset the boilerplate stuff to make the main loop easier/shorter to read

%% Add paths
Screen('Preference', 'SkipSyncTests', 1); 
Screen('Preference','VisualDebugLevel', 0);
addpath(genpath('Psychoobox'));
addpath(genpath('ptbutils'));
tgt = ParseTgt(file_name, ',');
HideCursor;
tgt = struct2table(tgt); % R2013b ++!

% break it up into segments
split_str = regexp(file_name, '/', 'split');

% return values of particular portions
% use name as stand-in for id
id = split_str{end - 1};
tgt_name = split_str{end};

% lop off extension
tgt_name = regexprep(tgt_name, '.tgt', '');

% data directory
data_dir = ['data/', id, '/'];
% final file name (explicitly append .mat?)
data_name = [data_dir, id, '_passive_', tgt_name, '_', datestr(now, 'hhMMSS'), '.mat'];

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
             'rel_x_scale', 0.25, ...
             'rel_y_scale', nan);
end

%% Set up text
helptext = ['This experiment is \nthe passive MRI one.\n', ...
            'Waiting for the initial TR.'];

info_txt = PobText('value', helptext, 'size', 40, ...
                   'color', [255 255 255], ...
                   'rel_x_pos', 0.5, ...
                   'rel_y_pos', 0.5, ...
                   'style', 'bold');

%% Set up feedback

feedback = PobRectangle();

feedback.Add(1, 'rel_x_pos', 0.5, ...
             'rel_y_pos', 0.5, ...
             'rel_x_scale', 0.3, ...
             'rel_y_scale', nan, ...
             'fill_color', [255 255 255], ...
             'fill_alpha', 0, ...
             'frame_color', [255 255 255]);

go_cue =  PobText('value', '+', 'size', 160, ...
                   'color', [255 255 255], ...
                   'rel_x_pos', 0.5, ...
                   'rel_y_pos', 0.5, ...
                   'style', 'bold');
%% Register relative to window
imgs.Register(win.pointer);
feedback.Register(win.pointer);
go_cue.Register(win.pointer);
imgs.Prime();
feedback.Prime();

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

trial(1:length(tgt.trial)) = struct('trial_start', [], ... 
    'between_data', [], ...
    'within_data', [], ...
    'image_index', [], ...
    'stim_on_time', [], ...
    'stim_off_time', [], ...
    'trnum', [], ...x
    'trial_type', []); % which finger was pressed

for ii = 1:length(tgt.trial)
    trial(ii).image_index = tgt.image_index(ii);
    trial(ii).trnum = tgt.trnum(ii);
    trial(ii).trial_type = tgt.trial_type(ii);
end

dat = struct('trial', trial, ...
    'id', id, ...
    'session', tgt.sess(1), ...
    'shapes', tgt.image_type(1), ...
    'block_start', [], ...x
    'presses', [], ...x
    'tr', tr_struct, ...
    'tgt', tgt);
