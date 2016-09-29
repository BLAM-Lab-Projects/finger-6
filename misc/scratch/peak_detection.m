
%% slower peak detection (with bells & whistles)

% assume xx is the press array (n by 7)
pks = cell(1,5);
pklocs = cell(1,5);
starttime = cell(1,5);
endtime = cell(1,5);
startind = cell(1,5);
endind = cell(1,5);

for ii = 1:size(xx, 2) - 2
    [pkval, pkloc] = findpeaks(xx(:, ii + 2), 'MinPeakHeight', 0.2, ...
        'MinPeakDistance', 50);
    if isempty(pkval)
        pkval = nan;
        pkloc = nan;
    else % if there were any presses at all
        % figure out start/stop
        inds = findchangepts(xx(:,ii + 2), 'MaxNumChanges', 2 * length(pkval), ...
            'Statistic', 'rms');      
        startind{ii} = inds(1:2:end);
        endind{ii} = inds(2:2:end);
        starttime{ii} = xx(inds(1:2:end), 1);
        endtime{ii} = xx(inds(2:2:end), 1);        
    end
    pks{ii} = pkval;
    pklocs{ii} = pkloc;
end