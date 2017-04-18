%% NB: blocks 7 & 8 have adjusted max time
subjname = 'cb05';
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

% practice free RT
WriteRtTgt(tgt_path, 'day', 1, 'block', 1, 'swapped', 0,...
    'image_type', 0, 'repeats', 20, 'ind_finger', 2:5, ...
    'ind_img', 7:10);


% practice timing only
WriteTrTgt(tgt_path, 'day', 1, 'block', 2, 'swapped', 0, ...
    'image_type', 0, 'repeats', 50, 'easy_block', 1, ...
    'ind_finger', 2, 'ind_img', 7, 'mintime', 0.9, 'maxtime', 0.9, 'catchtrials', false);

% practice timing w/multiple targets
WriteTrTgt(tgt_path, 'day', 1, 'block', 3, 'swapped', 0, ...
    'image_type', 0, 'repeats', 20, 'easy_block', 1, ...
    'ind_finger', 2:5, 'ind_img', 7:10, 'mintime', 0.9, 'maxtime', 0.9, 'catchtrials', false);

% practice timing with catch trials (optional)
WriteTrTgt(tgt_path, 'day', 1, 'block', 4, 'swapped', 0, ...
    'image_type', 0, 'repeats', 20, 'easy_block', 1, ...
    'ind_finger', 2:5, 'ind_img', 7:10, 'mintime', 0.9, 'maxtime', 0.9, 'catchtrials', true);

% four forced RT (full monty)
WriteTrTgt(tgt_path, 'day', 1, 'block', 5, 'swapped', 0, ...
    'image_type', 0, 'repeats', 20, ...
    'ind_finger', 2:5, 'ind_img', 7:10, 'mintime', 0.3, 'maxtime', 0.9);
WriteTrTgt(tgt_path, 'day', 1, 'block', 6, 'swapped', 0, ...
    'image_type', 0, 'repeats', 20, ...
    'ind_finger', 2:5, 'ind_img', 7:10, 'mintime', 0.3, 'maxtime', 0.9);
WriteTrTgt(tgt_path, 'day', 1, 'block', 7, 'swapped', 0, ...
    'image_type', 0, 'repeats', 20, ...
    'ind_finger', 2:5, 'ind_img', 7:10, 'mintime', 0.3, 'maxtime', 0.9);
WriteTrTgt(tgt_path, 'day', 1, 'block', 8, 'swapped', 0, ...
    'image_type', 0, 'repeats', 20, ...
    'ind_finger', 2:5, 'ind_img', 7:10, 'mintime', 0.3, 'maxtime', 0.9);
	
% symbols
WriteRtTgt(tgt_path, 'day', 1, 'block', 9, 'swapped', 0,...
    'image_type', 1, 'repeats', 20, 'ind_finger', 2:5, ...
    'ind_img', symbkey);
WriteRtTgt(tgt_path, 'day', 1, 'block', 10, 'swapped', 0,...
    'image_type', 1, 'repeats', 20, 'ind_finger', 2:5, ...
    'ind_img', symbkey);
% extra practice (optional?)
WriteRtTgt(tgt_path, 'day', 1, 'block', 11, 'swapped', 0,...
    'image_type', 1, 'repeats', 20, 'ind_finger', 2:5, ...
    'ind_img', symbkey);

% Practice forced RT w/symbols
WriteTrTgt(tgt_path, 'day', 1, 'block', 12, 'swapped', 0, ...
    'image_type', 1, 'repeats', 13, 'easy_block', 1, ...
    'ind_finger', 2:5, 'ind_img', symbkey, 'mintime', 0.9, 'maxtime', 0.9, 'catchtrials', true);

% four forced RT (full monty)
WriteTrTgt(tgt_path, 'day', 1, 'block', 13, 'swapped', 0, ...
    'image_type', 1, 'repeats', 20, ...
    'ind_finger', 2:5, 'ind_img', symbkey, 'mintime', 0.3, 'maxtime', 0.9);
WriteTrTgt(tgt_path, 'day', 1, 'block', 14, 'swapped', 0, ...
    'image_type', 1, 'repeats', 20, ...
    'ind_finger', 2:5, 'ind_img', symbkey, 'mintime', 0.3, 'maxtime', 0.9);
WriteTrTgt(tgt_path, 'day', 1, 'block', 15, 'swapped', 0, ...
    'image_type', 1, 'repeats', 20, ...
    'ind_finger', 2:5, 'ind_img', symbkey, 'mintime', 0.3, 'maxtime', 0.9);
WriteTrTgt(tgt_path, 'day', 1, 'block', 16, 'swapped', 0, ...
    'image_type', 1, 'repeats', 20, ...
    'ind_finger', 2:5, 'ind_img', symbkey, 'mintime', 0.3, 'maxtime', 0.9);
		