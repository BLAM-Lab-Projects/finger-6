function WriteScanTgt(out_path,sess,block,symbkey)
% Make target files AVMA scanner task
%
%    WriteScanTgt(path, subjname, session, block, image_type);
% 
%   copy-paste test:
	% WriteScanTgt('c:/Users/fmri/Desktop/finger-6/misc/tfiles/','AAA',1,1,0);
%
    
    
% Target file structure:
% 1. Sess
% 2. Block
% 3. TrialNum
% 4. TRNum
% 5. Stimulus Type (0 = hand, 1 = symbol)
% 6. Stimulus Number (1 to 5)
% 7. Finger Number (1 to 5)
% 8. Stimulus Delay (delay between start of TR and presentation of stimulus)
% 9. Go-Cue Delay (delay between stimulus presentation and Go-Cue
% 10. Trial Type (0 = NoGo, 1 = Go)

TRlength = 1; % length of TR in seconds
TRs_per_trial = 7;
TRs_per_rest = 10;

go_delay = 2.5; % minimum go-cue delay

Nreps = 2;
Nsymb = 10;
Nrest = 4;
Ntrials = Nreps*Nsymb+Nrest;

% build target file with all reps

fing_index = [1:5 1:5];
% rearrange fing_index to point to appropriate finger


combos = [zeros(10,1) fing_index' symbkey'; ones(10,1) fing_index' symbkey'];

%combos(:,3) = (combos(:,2));
combos = repmat(combos,Nreps,1);

tFile = zeros(size(combos,1),10);
tFile(:,6:7) = combos(:,[2 3]);
tFile(:,10) = combos(:,1);
tFile(:,4) = TRs_per_trial;

% add rest trials
rest_trials = zeros(Nrest,10);
rest_trials(:,4) = TRs_per_rest;
tFile = [tFile; rest_trials];

% scramble trial order
Ntrials = size(tFile,1);
tFile = tFile(randperm(Ntrials),:);
tFile = [tFile; rest_trials(1,:)];

Ntrials = Ntrials+1;

% include trial num etc
tFile(:,1) = sess;
tFile(:,2) = block;
tFile(:,3) = 1:Ntrials; % trial number
tFile(:,4) = cumsum(tFile(:,4));%4+(0:Ntrials-1)*TRs_per_trial; % TR number
tFile(:,5) = 1;
tFile(:,8) = 0;%TRlength*rand(Ntrials,1); % randomly jitter stimulus presentation time relative to TR start time
tFile(:,9) = go_delay; % exponential distribution ~ mean(1s)

filename = ['scan_','sess',num2str(sess), '_bk', num2str(block), '.tgt'];
    headers = {'sess','block','trial', 'trnum', 'image_type', 'finger_index', 'image_index',  ...
               'stim_delay', 'go_delay', 'trial_type'};

	fid = fopen([out_path, filename], 'wt');
	csvFun = @(str)sprintf('%s, ', str);
	xchar = cellfun(csvFun, headers, 'UniformOutput', false);
	xchar = strcat(xchar{:});
	xchar = strcat(xchar(1:end-1), '\n');
	fprintf(fid, xchar);
	fclose(fid);
    dlmwrite([out_path, filename], tFile, '-append','precision',4);
    