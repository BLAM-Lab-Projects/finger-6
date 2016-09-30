% make all target files for AVMA imaging experiment
subjname = '003';
rng(sum(uint8(subjname)));

tgt_path = ['C:/Users/fmri/Desktop/finger-6/misc/tfiles/',subjname,'/'];

if(~exist(tgt_path))
    mkdir(tgt_path);
end

% generate key assignments for this subject
if(~exist([tgt_path,'symbkey.mat']));
    symbkey = [randperm(5), 5+randperm(5)];
    eval (['save ',[tgt_path 'symbkey'],' symbkey']);
else
    % commented is 'correct' way, but uncommented is how they were actually
    % generated
    %load([tgt_path, 'symbkey']);
    load misc/tfiles/symbkey;
end

symbkey_switched = symbkey;

if strcmp(subjname, '001')
    train_set = [1 7 3 9 5];
    upkeep_set = [6 2 8 4 10];
    symbkey_switched([4 5 2 3]) = symbkey_switched([2 3 4 5]);
elseif strcmp(subjname, '002')
    train_set = 1:5;
    upkeep_set = 6:10;
    symbkey_switched([4 2 10 8]) = symbkey_switched([2 4 8 10]);
elseif strcmp(subjname, '003')
    train_set = 6:10;
    upkeep_set = 1:5;
    symbkey_switched([4 2 10 8]) = symbkey_switched([2 4 8 10]);
else
    error('No matching subject id.')
end

numTrainingBlocks = 3;
numPracticeBlocks = 10;
numSwitchTrainingBlocks = 3;
numTRblocks = 6;

% build target files
%% Day 1 - pre-scan FreeRT

% initial training on both symbol sets
symbSet = 1;
ind = rand(1,5)<.5; % random number from 1:10
ind = [ind 1-ind];
o = [1:5 1:5];
training_perm = symbkey(o+5*ind);

WriteRtTgt(tgt_path, 'day', 1, 'block', 1, 'swapped', 0,...
    'image_type', symbSet, 'repeats', 20, 'ind_finger', [1:5], 'ind_img', training_perm(1:5));
WriteRtTgt(tgt_path, 'day', 1, 'block', 2, 'swapped', 0,...
    'image_type', symbSet, 'repeats', 20, 'ind_finger', [1:5], 'ind_img', training_perm(6:10));
    
WriteRtTgt(tgt_path, 'day', 1, 'block', 3, 'swapped', 0,...
    'image_type', symbSet, 'repeats', 10, 'ind_finger', [1:5 1:5], 'ind_img', symbkey);

WriteRtTgt(tgt_path, 'day', 1, 'block', 4, 'swapped', 0,...
    'image_type', symbSet, 'repeats', 10, 'ind_finger', [1:5 1:5], 'ind_img', symbkey);
    % extra practice block (for buffer)
WriteRtTgt(tgt_path, 'day', 1, 'block', 5, 'swapped', 0,...
    'image_type', symbSet, 'repeats', 10, 'ind_finger', [1:5 1:5], 'ind_img', symbkey);

%% Day 1 - timed response
for blk = 1:numTRblocks
WriteTrTgt(tgt_path, ...
                'day', 1, 'block', blk, 'swapped', 0,...
                'image_type', 1, 'repeats', 10, 'easy_block', 0,...
                'ind_finger', [1:5 1:5], 'ind_img', symbkey, 'mintime', .3, 'maxtime', .9);
end

%% Day 2 - scan session

% practice block
WriteRtTgt(tgt_path, 'day', 2, 'block', 99, 'swapped', 0, ...
    'image_type', 1, 'repeats', 5, 'ind_finger', [1:5 1:5], 'ind_img', symbkey);

for run = 1:10
    WriteScanTgt(tgt_path,1,run,symbkey);
end

%% Day 3-4 training
for day = 3:4
    for blk = 1:numPracticeBlocks
        WriteRtTgt(tgt_path, 'day', day, 'block', blk, 'swapped', 0,...
            'image_type', 1, 'repeats', 20, ...
                'ind_finger', [1:5], 'ind_img', symbkey(train_set));
    end
    
    WriteRtTgt(tgt_path, 'day', day, 'block', 11, 'swapped', 0, ...
        'image_type', 1, 'repeats', 10, ...
        'ind_finger', [1:5], 'ind_img', symbkey(upkeep_set));
end

%% Day 5 scan - or just keep same as previous?
WriteRtTgt(tgt_path, 'day', 5, 'block', 99, 'swapped', 0, ...
    'image_type', 1, 'repeats', 5, 'ind_finger', [1:5 1:5], 'ind_img', symbkey);

for run = 1:10
    WriteScanTgt(tgt_path,2,run,symbkey);
end

%% Day 5 post-scan

for blk = 1:2
    WriteRtTgt(tgt_path, 'day', 5, 'block', blk, 'swapped', 1,...
        'image_type', 1, 'repeats', 20, ...
        'ind_finger', [1:5 1:5], 'ind_img', symbkey_switched);
end

for blk = 1:numTRblocks
    WriteTrTgt(tgt_path, ...
                'day', 5, 'block', blk, 'swapped', 1,...
                'image_type', 1, 'repeats', 10, 'easy_block', 0,...
                'ind_finger', [1:5 1:5], 'ind_img', symbkey_switched,...
                'mintime', .3, 'maxtime', .9);
end
