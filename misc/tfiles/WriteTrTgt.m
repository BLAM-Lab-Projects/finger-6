function WriteTrTgt(out_path, varargin)
    % copy-paste test:
	% WriteTrTgt('c:/Users/fmri/Desktop/finger-6/misc/tmp/');
    % More thorough example:
    % WriteTrTgt('~/Documents/BLAM/finger-5/misc/tfiles/', ...
    %            'day', 2, 'block', 4, 'swapped', [1 3],...
    %            'image_type', 1, 'repeats', 5, 'easy_block', 0,...
    %            'ind_finger', 1:5, 'ind_img', 1:5, 'mintime', 0.05,
    %            'maxtime', 0.5);
    %
    % last beep is at 1.4s (including 500ms pause)
    opts = struct('day', 1, 'block', 1, 'swapped', 0, ...
                  'image_type', 0, 'repeats', 3, ...
                  'easy_block', 0, 'ind_finger', 1:5, ...
                  'ind_img', 1:5, 'mintime', 0.05, 'maxtime', 0.5);
    opts = CheckInputs(opts, varargin{:});

    day = opts.day;
    block = opts.block;
    swapped = opts.swapped;
    image_type = opts.image_type;
    repeats = opts.repeats;
    easy_block = opts.easy_block;
    ind_finger = opts.ind_finger;
    ind_img = opts.ind_img;
    mintime = opts.mintime;
    maxtime = opts.maxtime;


    if length(ind_finger) ~= length(ind_img)
        error('Cannot handle weird mappings, make sure ind_finger and ind_img are the same length.');
    end

    if any(swapped > length(ind_finger))
        error('Swapping goes by index, not the actual value.');
    end

    if any(diff(ind_img) < 0) || any(diff(ind_img) < 0)
        error('Make sure to define indices in increasing order.')
    end

    seed = day * block;
    rand('seed', seed);

    combos = allcomb(1, ind_finger);
    combos(:, 3) = -1;
    for ii = 1:length(ind_finger)
        indices = combos(:,2) == ind_finger(ii);
        combos(indices, 3) = ind_img(ii);
    end
	combos = repmat(combos, repeats, 1);
    limit = 10000;
    maxnum = 3;
    count = 1;
    while count < limit
        combos2 = combos(randperm(size(combos, 1)), :);
        i = [find(combos2(1:end - 1, 1) ~= combos2(2:end, 1)); length(combos2)];
        l = diff([0; i]);

        if any(l > maxnum) % no more than three allowed
            count = count + 1;
        else
            break;
        end
    end

    combos = combos2;
    combo_size = size(combos, 1);

    if easy_block
        combos(:, 1) = min(times);
    end

    if any(swapped > 0) % if not zero
        combos(:, 4) = swapped(1);
        combos(:, 5) = swapped(2);
        swapped2 = 1;
        ind_img([swapped(2), swapped(1)]) = ind_img([swapped(1), swapped(2)]);
    else
        combos(:, 4:5) = 0;
        swapped2 = 0;
    end
    % combos is (times, finger, image, swap1, swap2)

    % add random prep times
    combos(:,1) = mintime+rand(size(combos(:,1)))*(maxtime-mintime);
    
    % add catch trials
    num_catch = floor(combo_size/10);
    randind = randi([-2 2], 1, num_catch);
    catchind = (10:10:combo_size) + randind;
    if catchind(end) > combo_size
        catchind(end) = combo_size;
    end
    % time, finger, img_time, indices of two swapped images
    catch_trial = [nan nan nan combos(1, 4:5)];
    combos = insertrows(combos, catch_trial, catchind);
    combo_size = size(combos, 1);

    final_output = [repmat(day, combo_size, 1) ...
                    repmat(block, combo_size, 1) ...
                    (1:combo_size)' ... % trials
                    repmat(easy_block, combo_size, 1) ...
                    repmat(swapped2, combo_size, 1) ...
                    repmat(image_type, combo_size, 1) combos];

                
    filename = ['tr_','dy',num2str(day), '_bk', num2str(block),...
                '_sw', num2str(swapped2), '_sh', num2str(image_type), '.tgt'];
    headers = {'day', 'block', 'trial', 'easy', ...
               'swapped', 'image_type','image_time', 'intended_finger',  ...
               'image_index', 'swap_index_1', 'swap_index_2'};

	fid = fopen([out_path, filename], 'wt');
	csvFun = @(str)sprintf('%s, ', str);
	xchar = cellfun(csvFun, headers, 'UniformOutput', false);
	xchar = strcat(xchar{:});
	xchar = strcat(xchar(1:end-1), '\n');
	fprintf(fid, xchar);
	fclose(fid);
    dlmwrite([out_path, filename], final_output, '-append','precision', 4);

end
