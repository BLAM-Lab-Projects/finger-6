base_dir = 'C:/Users/fmri/Desktop/finger-6/';
file_names = dir([base_dir 'data/combined_data/*.mat']);

file_names = {file_names.name};

tr_indices = ~cellfun(@isempty, strfind(file_names, 'tr_'));
rt_indices = ~cellfun(@isempty, strfind(file_names, 'rt_'));
scan_indices = ~cellfun(@isempty, strfind(file_names, 'scan'));

tr_names = file_names(tr_indices);
rt_names = file_names(rt_indices);
scan_names = file_names(scan_indices);

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
    tr_tbl = table();
    for pp = 1:length(tmp.dat.trial)
        if pp == 1
            id = {tmp.dat.id};
            day = str2double(tmp.dat.day);
            block = str2double(tmp.dat.block);
            trial = pp;
            time_image = tmp.dat.trial(pp).time_image_real - tmp.dat.trial(pp).trial_start;
            time_press = tmp.dat.trial(pp).time_press - tmp.dat.trial(pp).trial_start;
            index_image = tmp.dat.trial(pp).index_image;
            sub_swap = tmp.dat.trial(pp).sub_swap;
            catch_trial = tmp.dat.trial(pp).catch_trial;
            time_preparation = tmp.dat.trial(pp).time_preparation;
            idx = find(max(tmp.dat.trial(pp).max_press));
            intended_finger = tmp.dat.trial(pp).intended_finger(idx);
            index_press = tmp.dat.trial(pp).index_press(idx);
            correct = double(index_press(idx) == intended_finger(idx));
            max_press = tmp.dat.trial(pp).max_press(idx);
            time_max_press = tmp.dat.trial(pp).time_max_press(idx) - tmp.dat.trial(pp).trial_start; 
            tr_tbl = table(id, day, block, trial, time_image, ...
                time_press, index_image, sub_swap, catch_trial, ...
                time_preparation, correct, intended_finger, index_press, ...
                max_press, time_max_press);
        else
        warning off;
        tr_tbl.id(pp, 1) = {tmp.dat.id};
        tr_tbl.day(pp, 1) = str2double(tmp.dat.day);
        tr_tbl.block(pp, 1) = str2double(tmp.dat.block);
        tr_tbl.trial(pp, 1) = pp;
        tr_tbl.time_image(pp, 1) = tmp.dat.trial(pp).time_image_real - tmp.dat.trial(pp).trial_start;
        tr_tbl.time_press(pp, 1) = tmp.dat.trial(pp).time_press - tmp.dat.trial(pp).trial_start;
        tr_tbl.index_image(pp, 1) = tmp.dat.trial(pp).index_image;
        tr_tbl.sub_swap(pp, 1) = tmp.dat.trial(pp).sub_swap;
        tr_tbl.catch_trial(pp, 1) = tmp.dat.trial(pp).catch_trial;
        tr_tbl.time_preparation(pp, 1) = tmp.dat.trial(pp).time_preparation;
        warning on;
        % handle multi-inputs
            idx = find(max(tmp.dat.trial(pp).max_press));
            tr_tbl.correct(pp, 1) = double(tr_tbl.index_press(pp, idx) == tr_tbl.intended_finger(pp, idx));
            tr_tbl.intended_finger(pp, 1) = tmp.dat.trial(pp).intended_finger(idx);
            tr_tbl.index_press(pp, 1) = tmp.dat.trial(pp).index_press(idx);
            tr_tbl.max_press(pp, 1) = tmp.dat.trial(pp).max_press(idx);
            tr_tbl.time_max_press(pp, 1) = tmp.dat.trial(pp).time_max_press(idx) - tmp.dat.trial(pp).trial_start;  
        end
    end
    if ii == 1
        out_tbl = tr_tbl;
    else
        out_tbl = [out_tbl; tr_tbl];
    end
    
end