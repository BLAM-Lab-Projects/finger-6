function WriteScanTgt(out_path,subjname,sess,block,image_type)
% Make target files AVMA scanner task
%
%    WriteScanTgt(path, subjname, session, block, image_type);
% 
%   copy-paste test:
	% WriteScanTgt('~/Documents/BLAM/finger-5/misc/tfiles/','AAA',1,1,0);
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

TRlength = 2; % length of TR in seconds
min_go_delay = 2; % minimum go-cue delay
max_go_delay = 4; % maximum go-cue delay

% load symbol key if it already exists for this subject
if(~exist([subjname,'_key.mat']))
    symbkey = randperm(5); % symbol/key mapping press symbkey(i) for symbol i
    eval(['save ',subjname,'_key']);
else
    eval(['load ',subjname,'_key']);
end

Nreps = 24;
Nsymb = 5;
Ntrials = Nreps*Nsymb;

subblock = zeros(Nreps,9);

% build target file with all reps
tFile = [];
for i=1:Nsymb
    subblock(:,6) = i;
    subblock(:,7) = symbkey(i);
    tFile = [tFile; subblock];
end

% scramble trial order
tFile = tFile(randperm(Ntrials),:);

% include trial num etc
tFile(:,1) = sess;
tFile(:,2) = block;
tFile(:,3) = 1:Ntrials; % trial number
tFile(:,4) = 4+(0:Ntrials-1)*5; % TR number
tFile(:,5) = image_type;
tFile(:,8) = TRlength*rand(Ntrials,1); % randomly jitter stimulus presentation time relative to TR start time
go_delays = exprnd(1,Ntrials,1);
go_diff = max_go_delay-min_go_delay;
while(sum(go_delays>go_diff)>0)
    go_delays(go_delays>go_diff) = exprnd(.5,sum(go_delays>go_diff),1);
end
tFile(:,9) = min_go_delay + go_delays; % exponential distribution ~ mean(1s)


filename = ['scan_','sess',num2str(sess), '_bk', num2str(block),...
                '_sh', num2str(image_type), '.tgt'];
    headers = {'sess','block','trial', 'trnum', 'image_type', 'image_index', 'finger_index',  ...
               'stim_delay', 'go_delay'};

	fid = fopen([out_path, filename], 'wt');
	csvFun = @(str)sprintf('%s, ', str);
	xchar = cellfun(csvFun, headers, 'UniformOutput', false);
	xchar = strcat(xchar{:});
	xchar = strcat(xchar(1:end-1), '\n');
	fprintf(fid, xchar);
	fclose(fid);
    dlmwrite([out_path, filename], tFile, '-append','precision',4);
    
    figure(1); clf;
    hist(tFile(:,9));