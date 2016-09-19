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
helptext = ['This experiment is \nthe MRI one.\n', ...
            'Waiting for the initial TR?'];

info_txt = PobText('value', helptext, 'size', 30, ...
                   'color', [255 255 255], ...
                   'rel_x_pos', 0.5, ...
                   'rel_y_pos', 0.5);

%% Set up responses & feedback
if attention
    % only use one response, to check if subject is paying attention
    error('Fix vigilance task.');
    kbrd = BlamForceboard(4);
else
    % use entire right hand
    kbrd = BlamForceboard(6:10);
end

feedback = PobRectangle();

feedback.Add(1, 'rel_x_pos', 0.5, ...
             'rel_y_pos', 0.5, ...
             'rel_x_scale', 0.3, ...
             'rel_y_scale', nan, ...
             'fill_color', [255 255 255], ...
             'fill_alpha', 0, ...
             'frame_color', [255 255 255]);
%% Register relative to window
imgs.Register(win.pointer);
feedback.Register(win.pointer);
imgs.Prime();
feedback.Prime();

info_txt.Register(win.pointer);

%% TR obj (plus other keys)
tr = BlamTr();

%% Data storage

tr_struct = struct('times', zeros(1, max(tgt.trnum)), 'count', zeros(1, max(tgt.trnum)));

