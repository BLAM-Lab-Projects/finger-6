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
helptext = ['This experiment is\nTimed Response.\n', ...
            'Here is more text'];

info_txt = PobText('value', helptext, 'size', 30, ...
                   'color', [255 255 255], ...
                   'rel_x_pos', 0.5, ...
                   'rel_y_pos', 0.5);

%% Set up responses & feedback
kbrd = BlamForceboard(6:10);
%% Register relative to window
imgs.Register(win.pointer);
imgs.Prime();
% imgs.Draw(index); % to draw
info_txt.Register(win.pointer);

%% Data storage
