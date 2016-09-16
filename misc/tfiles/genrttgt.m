tgt_path = 'c:/Users/fmri/Desktop/finger-6/misc/tfiles/';

for blk = 1
    WriteRtTgt(tgt_path, 'day', 1, 'block', blk, 'swapped', 0,...
               'image_type', 0, 'repeats', 20);
end
