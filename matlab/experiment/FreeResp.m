classdef FreeResp < StateMachine

    properties
    % in order of appearance...
        ref_time % reference time for the entire block
        consts % consts for the experiment
        win % window/screen for Psychtoolbox
        aud % audio
        imgs % images
        keys % keyboard
        feed % keyboard feedback
        data_summary % for easy analyses (each row is a response)
        data_long % complete data, including times of onset for everything
        %data_nested % optional? nested-style data, which allows for varying
                    % numbers of events per trial
    end

    methods
        snd1 = GenBeep(1046);

    end
