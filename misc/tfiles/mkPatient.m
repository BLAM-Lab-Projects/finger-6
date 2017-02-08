subjname = 'cb02';
rng(sum(uint8(subjname)));

tgt_path = ['C:/Users/fmri/Desktop/finger-6/misc/tfiles/',subjname,'/'];

if(~exist(tgt_path))
    mkdir(tgt_path);
end

% generate key assignments for this subject
if(~exist([tgt_path, 'symbkey.mat']));
    symbkey = randperm(4);
    save([tgt_path, 'symbkey.mat'], 'symbkey');
else
    load([tgt_path, 'symbkey']);
end
% figure out swaps
symbkey_switched = symbkey;
if strcmp(subjname, 'patient007')
    %???
end

% 200 trials of practice
WriteRtTgt(tgt_path, 'day', 1, 'block', 1, 'swapped', 0,...
    'image_type', 0, 'repeats', 25, 'ind_finger', 2:5, ...
    'ind_img', 7:10);
WriteRtTgt(tgt_path, 'day', 1, 'block', 2, 'swapped', 0,...
    'image_type', 0, 'repeats', 25, 'ind_finger', 2:5, ...
    'ind_img', 7:10);
% extra practice (optional?)
WriteRtTgt(tgt_path, 'day', 1, 'block', 3, 'swapped', 0,...
    'image_type', 0, 'repeats', 25, 'ind_finger', 2:5, ...
    'ind_img', 7:10);

% practice forced RT
WriteTrTgt(tgt_path, 'day', 1, 'block', 4, 'swapped', 0, ...
    'image_type', 0, 'repeats', 24, 'easy_block', 1, ...
    'ind_finger', 2:5, 'ind_img', 7:10, 'mintime', 0.9, 'maxtime', 0.9);
WriteTrTgt(tgt_path, 'day', 1, 'block', 5, 'swapped', 0, ...
    'image_type', 0, 'repeats', 24, 'easy_block', 1, ...
    'ind_finger', 2:5, 'ind_img', 7:10, 'mintime', 0.9, 'maxtime', 0.9);

% real forced RT
WriteTrTgt(tgt_path, 'day', 1, 'block', 6, 'swapped', 0, ...
    'image_type', 0, 'repeats', 24, ...
    'ind_finger', 2:5, 'ind_img', 7:10, 'mintime', 0.3, 'maxtime', 0.9);
WriteTrTgt(tgt_path, 'day', 1, 'block', 7, 'swapped', 0, ...
    'image_type', 0, 'repeats', 24, ...
    'ind_finger', 2:5, 'ind_img', 7:10, 'mintime', 0.3, 'maxtime', 0.9);
WriteTrTgt(tgt_path, 'day', 1, 'block', 8, 'swapped', 0, ...
    'image_type', 0, 'repeats', 24, ...
    'ind_finger', 2:5, 'ind_img', 7:10, 'mintime', 0.3, 'maxtime', 0.9);
WriteTrTgt(tgt_path, 'day', 1, 'block', 9, 'swapped', 0, ...
    'image_type', 0, 'repeats', 24, ...
    'ind_finger', 2:5, 'ind_img', 7:10, 'mintime', 0.3, 'maxtime', 0.9);


% 200 practice on symbols
WriteRtTgt(tgt_path, 'day', 1, 'block', 10, 'swapped', 0,...
    'image_type', 1, 'repeats', 25, 'ind_finger', 2:5, ...
    'ind_img', symbkey);
WriteRtTgt(tgt_path, 'day', 1, 'block', 11, 'swapped', 0,...
    'image_type', 1, 'repeats', 25, 'ind_finger', 2:5, ...
    'ind_img', symbkey);
% extra practice (optional?)
WriteRtTgt(tgt_path, 'day', 1, 'block', 12, 'swapped', 0,...
    'image_type', 1, 'repeats', 25, 'ind_finger', 2:5, ...
    'ind_img', symbkey);

% Practice forced RT w/symbols
WriteTrTgt(tgt_path, 'day', 1, 'block', 13, 'swapped', 0, ...
    'image_type', 1, 'repeats', 13, 'easy_block', 1, ...
    'ind_finger', 2:5, 'ind_img', symbkey, 'mintime', 0.9, 'maxtime', 0.9);

% real forced RT w/symbols
WriteTrTgt(tgt_path, 'day', 1, 'block', 14, 'swapped', 0, ...
    'image_type', 1, 'repeats', 24, ...
    'ind_finger', 2:5, 'ind_img', symbkey, 'mintime', 0.3, 'maxtime', 0.9);
WriteTrTgt(tgt_path, 'day', 1, 'block', 15, 'swapped', 0, ...
    'image_type', 1, 'repeats', 24, ...
    'ind_finger', 2:5, 'ind_img', symbkey, 'mintime', 0.3, 'maxtime', 0.9);
WriteTrTgt(tgt_path, 'day', 1, 'block', 16, 'swapped', 0, ...
    'image_type', 1, 'repeats', 24, ...
    'ind_finger', 2:5, 'ind_img', symbkey, 'mintime', 0.3, 'maxtime', 0.9);
WriteTrTgt(tgt_path, 'day', 1, 'block', 17, 'swapped', 0, ...
    'image_type', 1, 'repeats', 24, ...
    'ind_finger', 2:5, 'ind_img', symbkey, 'mintime', 0.3, 'maxtime', 0.9);

