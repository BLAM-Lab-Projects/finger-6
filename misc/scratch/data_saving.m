% splitting tfile specification for data name

% original string
file_name = 'misc/tfiles/Alex/rt_dy1_bk99.tgt';

% break it up into segments
split_str = regexp(file_name, '/', 'split');

% return values of particular portions
% use name as stand-in for id
name = split_str{end - 1};
tgt_name = split_str{end};

% lop off extension
tgt_name = regexprep(tgt_name, '.tgt', '');

% data directory
data_dir = ['data/', name, '/'];
% final file name (explicitly append .mat?)
data_name = [data_dir, name, '_', tgt_name, '.mat'];

% save example
if ~exist(data_dir, 'dir')
    mkdir(data_dir);
end
save(data_name, 'dat');