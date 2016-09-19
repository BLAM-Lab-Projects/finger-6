% make all target files for AVMA imaging experiment
subjname = 'AAA';
tgt_path = ['../../data/',subjname,'/'];

if(~exist(tgt_path))
    mkdir(tgt_path);
end
if(~exist([tgt_path,'/tfiles']))
    mkdir([tgt_path,'/tfiles']);
end
tgt_path = [tgt_path,'/tfiles/'];

numTrainingBlocks = 3;
numPracticeBlocks = 10;
numSwitchTrainingBlocks = 3;
numTRblocks = 6;

% build target files
%% Day 1 - pre-scan FreeRT

% initial familiarization with task using hand stimuli
WriteRtTgt(tgt_path, 'day', 1, 'block', 1, 'swapped', 0,...
               'image_type', 0, 'repeats', 10, 'ind_finger', [1:5 1:5], 'ind_img',1:10);

% initial training on both symbol sets
for symbSet = 1:2
    for blk = 1:numTrainingBlocks
        WriteRtTgt(tgt_path, 'day', 1, 'block', blk, 'swapped', 0,...
               'image_type', symbSet, 'repeats', 20);
    end
end

%% Day 1 - scan session



%% Day 1 - post-scan TR
for blk = 1:numTRblocks
WriteTrTgt(tgt_path, ...
                'day', 1, 'block', blk, 'swapped', 0,...
                'image_type', 1, 'repeats', 20, 'easy_block', 0,...
                'ind_finger', 6:10, 'ind_img', 1:5, 'mintime', .5, 'maxtime', .95);
end

%% Day 2-4 training
for day = 2:4
    for blk = 1:numPracticeBlocks
        WriteRtTgt(tgt_path, 'day', day, 'block', blk, 'swapped', 0,...
            'image_type', 1, 'repeats', 20);
    end
end

%% Day 5 pre-scan
for day = 2:4
    for blk = 1:numTrainingBlocks
        for symbSet = 1:2
            WriteRtTgt(tgt_path, 'day', 5, 'block', blk, 'swapped', [1 3],...
            'image_type', 1, 'repeats', 20);
        end
    end
end
