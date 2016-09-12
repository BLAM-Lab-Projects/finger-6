

frames(1:350) = struct('push_data', [], ... % complete push data (timestamps, etc...)
                       ...                  % timestamps relative to the experiment starts
                       'state', []); % state at the current frame

trial(1:length(NNN)) = struct('time_start', [], ... % trial time relative to the start of the experiment
                      'time_image', [], ... % image onset relative to time_start
                      'time_press', [], ... % time of press relative to time_start
                      'time_preparation', [], ... % time_press - time_image
                      'index_image', [], ... % image index
                      'index_press', [], ...  % which finger pressed
                      'index_finger', [], ...
                      'correct', [], ... % index_press == index_finger
                      'frames', frames);
dat = struct('trial', trial, ...
             'id', [], ...
             'shapes', [], ...
             'swaps', [], ...
             'time_start', []);