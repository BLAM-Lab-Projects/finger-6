Notes on behavioral data files:

scan_practice.mat contains a practice block with a simulated trigger (i.e. no images were collected).
scan2.mat actually used the tgtfile for day 2, session 1. However, this does not affect results, as
there are no differences in the file structure or task between days.
scan6.mat does not exist because the MATLAB program errored before the scan finished.

Presses for digit 4 (index 4) are not present, due to an issue with one of the cables (now fixed).

----------------------------
Notes on structure of data files:

.mat files contain a single nested struct (`dat`).

dat
  - trial (1 - 45, one for each trial). Index via dat.trial(n)
    - trial_start: absolute start of the trial in seconds
    - between_data: force transducer data that occurred between the previous and current trial (explanation below)
    - within_data: force transducer data during the current trial (explanation below)
    - image_index: index of the image (1 - 10)
    - intended_finger: requested finger (== to press_index for correctness)
    - stim_delay: delay in seconds from the trial onset to the stimulus onset
    - stim_time: absolute time of stimulus/image presentation
    - go_delay: delay in seconds from the stimulus onset for the go/no-go cue
    - go_time: absolute go/no-go cue time in seconds
    - trnum: TR count that starts the trial
    - trial_type: (1/0) 1 is go, 0 is no-go
    - press_index: actual index of the key pressed (1 - 5)
    - correct: (1/0 == true/false) whether intended_finger == press_index
  - id: Subject id (unused)
  - session: Session id (should be ~1 to 8)
  - shapes: (1/0) 1 is symbol cue, 0 is (unused) hand cue
  - block_start: absolute start of the block in seconds
  - presses: n x 7 matrix of presses for the entire run (explanation below)
  - tr
    - times: Absolute times of every TR during the run
    - count: Cumulative sum of TRs during the run (sanity check)
  - tgt: table containing info for each trial (copy of the .tgt file)

----------------------------
Notes on push data:

between_data, within_data, and presses all have the same structure:
(:, 1) is the calculated absolute time (ideally comparable to absolute times elsewhere in dat).
(:, 2) is the timestamp from the NI-DAQ box (as a sanity check for the first column)
(:, 3:7) contain voltage traces for each of the five force transducers