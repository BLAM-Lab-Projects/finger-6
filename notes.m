block_start = GetSecs;
trial_start_rel = (current_time) - block_start;
trial_start_abs = GetSecs;

trial_end_rel = trial_start_rel + length_beep + 0.2
trial_end_abs = trial_start_abs + length_beep + 0.2

image_start_rel = trial_start_rel + (image_time);
image_start_abs = trial_start_abs + (image_time);

