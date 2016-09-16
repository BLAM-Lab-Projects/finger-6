tgt_path = 'c:/Users/fmri/Desktop/finger-6/misc/tfiles/';

for blk = 1:8
    WriteTrTgt(tgt_path, 'day', 1, 'block', blk, 'swapped', 0,...
               'image_type', 0, 'repeats', 3, 'times', 0.25:0.1:0.95);
end
