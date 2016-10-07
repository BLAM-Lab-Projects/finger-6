%% Analysis of Timed Response, Free RT, and scanner sessions
base_dir = 'C:/Users/fmri/Desktop/finger-6/';
file_names = dir([base_dir 'data/combined_data/*.mat']);

file_names = {file_names.name};

tr_indices = ~cellfun(@isempty, strfind(file_names, 'tr_'));
rt_indices = ~cellfun(@isempty, strfind(file_names, 'rt_'));
scan_indices = ~cellfun(@isempty, strfind(file_names, 'scan'));

tr_names = file_names(tr_indices);
rt_names = file_names(rt_indices);
scan_names = file_names(scan_indices);


tr_files = cell(length(tr_names), 1);
rt_files = cell(length(rt_names), 1);
scan_files = cell(length(scan_names), 1);

%% Dump Free RT into cell array
% tic;
% for ii = 1:length(rt_names)
%     tmp = load(['data/combined_data/', rt_names{ii}]);
%     tmp.dat.day = rt_names{ii}(findstr(rt_names{ii}, 'dy') + 2);
%     tmp.dat.block = rt_names{ii}(findstr(rt_names{ii}, 'bk') + 2);
%     rt_files{ii} = tmp.dat;   
% end
% toc

%% Dump Timed Response into cell array
tic
for ii = 1:length(tr_names)
    tmp = load(['data/combined_data/', tr_names{ii}]);
    try
        tmp.dat.trial(111) = [];
    catch
        disp('No 111 trial');
    end
    tmp.dat.day = tr_names{ii}(findstr(tr_names{ii}, 'dy') + 2);
    tmp.dat.block = tr_names{ii}(findstr(tr_names{ii}, 'bk') + 2);
    empties = cellfun(@isempty, {tmp.dat.trial.trial_start});
    tmp.dat.trial(empties) = [];
    empties_img = cellfun(@isempty, {tmp.dat.trial.time_image_real});
    empties_img = find(empties_img);
    for pp = 1:length(empties_img)
        tmp.dat.trial(empties_img(pp)).time_image_real = nan;
        tmp.dat.trial(empties_img(pp)).time_preparation = nan;
    end
    
    tr_files{ii} = tmp.dat; 
    tmptable = struct2table(tmp.dat.trial);
    tmptable.id = repmat(tmp.dat.id, length(tmp.dat.trial), 1);
    tmptable.shapes = repmat(tmp.dat.shapes, length(tmp.dat.trial), 1);
    tmptable.swaps = repmat(tmp.dat.swaps, length(tmp.dat.trial), 1);
    tmptable.day = repmat(tmp.dat.day, length(tmp.dat.trial), 1);
    tmptable.block = repmat(tmp.dat.block, length(tmp.dat.trial), 1);
    tmptable.prop_image = [];
    tmptable.frames = [];
    
    for pp = 1:height(tmptable)
        tmpvar = tmptable.index_press(pp);
        if iscell(tmpvar) && length(tmpvar{1}) > 1
            p1 = tmptable.max_press(pp);
            p1 = p1{1};
            ind = max(p1) == p1;
            tmptable.max_press(pp) = {p1(ind)};
            p1 = tmptable.time_max_press(pp);
            p1 = p1{1};
            tmptable.time_max_press(pp) = {p1(ind)};
            p1 = tmptable.index_press(pp);
            p1 = p1{1};
            tmptable.index_press(pp) = {p1(ind)};
            p1 = tmptable.correct(pp);
            p1 = double(p1{1});
            tmptable.correct(pp) = {p1(ind)};   
        end 

    end
    if ~iscell(tmptable.correct(pp))
        tmptable.correct = {tmptable.correct(:)};
    end
    
    if iscell(tmpvar)
        tmptable.max_press = cell2mat(tmptable.max_press);
        tmptable.time_max_press = cell2mat(tmptable.time_max_press);
        tmptable.index_press = cell2mat(tmptable.index_press);
        tmptable.correct = cell2mat(tmptable.correct);
    end
    if ii == 1
        tr_table = tmptable;
    else
        tr_table = [tr_table; tmptable];
    end
end
toc

%% Dump scanner behaviour into cell array
% tic
% for ii = 1:length(scan_names)
%     tmp = load(['data/combined_data/', scan_names{ii}]);
%     tmp.dat.day = scan_names{ii}(findstr(scan_names{ii}, 'sess') + 4);
%     tmp.dat.block = scan_names{ii}(findstr(scan_names{ii}, 'bk') + 2);
%     scan_files{ii} = tmp.dat;   
% end
% toc

