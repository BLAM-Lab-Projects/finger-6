
dat3 = dat2.trial(3).within_data(:, 3:7);
timestamps = dat2.trial(3).within_data(:, 1);

max_channel = max(dat3);
per_channel_max = zeros(1, length(max_channel));
% find peak indices for each channel
% need to also find duration of press
for ii = 1:length(max_channel)
     per_channel_max(ii) = find(max_channel(ii) == dat3(:, ii), 1);
end

% max overall
supermax_index = max_channel == max(max_channel);

% times of each max
times = timestamps(per_channel_max);

% need a way to weed out non-presses, based on velocity threshold?
% max of a flat trace isn't very meaningful...