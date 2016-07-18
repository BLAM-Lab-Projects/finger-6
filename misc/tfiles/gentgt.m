tgt_path = '~/Documents/BLAM/finger-5/misc/tfiles/';

for blk = 1:8
    WriteTrTgt(tgt_path, 'day', 1, 'block', blk, 'swapped', 0,...
               'image_type', 0, 'repeats', 3);
end
