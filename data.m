

frames(1:350) = struct('push_data', [], ... % complete push data (timestamps, etc...)
                       ...                  % timestamps relative to the experiment starts
                       'state', [],... % state at the current frame
                       'image', 0, ... % image on during this frame?
                       'beep4', 0, ... % 4th beep during this frame?
                       'time_frame', []); % Time relative to block start

trial(1:length(tgt.trial)) = struct('time_start', [], ... % trial time relative to the start of the experiment
                      'time_image', [], ... % image onset relative to time_start
                      'time_press', [], ... % time of press relative to time_start
                      'time_preparation', [], ... % time_press - time_image
                      'index_image', [], ... % image index
                      'index_press', [], ...  % which finger pressed
                      'index_finger', [], ...
                      'correct', [], ... % index_press == index_finger
                      'frames', frames, ...
                      'between_data', [], ... % data dump for between trials
                      'within_data', []); % data dump for within the trial
dat = struct('trial', trial, ...
             'id', [], ...
             'shapes', [], ...
             'swaps', [], ...
             'time_start', [], ... % absolute start time
             'tgt', table2struct(tgt));