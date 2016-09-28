% analyze forced RT data
clear all

subjnames = {'2016_09_27_Haith_001','2016_09_27_Haith_002','2016_09_27_Haith_003'};
%subjnames = {'001','002','003'};
fnames{1} = {'001_tr_dy1_bk1_122510','001_tr_dy1_bk2_123328','001_tr_dy1_bk3_124213','001_tr_dy1_bk4_124935'};
fnames{2} = {'002_tr_dy1_bk1_142251','002_tr_dy1_bk2_143025','002_tr_dy1_bk3_143652','002_tr_dy1_bk4_144405'};
fnames{3} = {'003_tr_dy1_bk1_165141','003_tr_dy1_bk2_171116','003_tr_dy1_bk3_171826','003_tr_dy1_bk4_172608'};



for subjnum = 1:3
    RT = [];
    success = [];
    error = [];
    for block = 1:4
        F = fullfile('../',subjnames{subjnum},fnames{subjnum}{block});
        eval(['load ',F])
        % preprocess to deal with awkward trials
        
        if(length(dat.trial)==111)
            dat.trial(111) = [];
        end
        
        for i=1:length(dat.trial);
            if(isempty(dat.trial(i).index_press))
                %dat.trial(i) = [];
                dat.trial(i).good = 0;
            else
                dat.trial(i).good = 1;
            end
            if(~isempty(dat.trial(i).index_press))
                dat.trial(i).first_press = dat.trial(i).index_press(1);
                dat.trial(i).correct = dat.trial(i).correct(1);
            else
                dat.trial(i).first_press = NaN;
            end
            
            if(isnan(dat.trial(i).index_press))
                dat.trial(i).time_preparation = NaN;
            end
            
            if(isempty(dat.trial(i).time_preparation))
                dat.trial(i).time_preparation = NaN;
                dat.trial(i).correct = NaN;
            end
            
            
        end
        
        %dat.trial(111) = [];
        %plot([dat.trial.time_preparation],[dat.trial(find(~isnan([dat.trial.intended_finger]))).first_press]-[dat.trial(find(~isnan([dat.trial.intended_finger]))).intended_finger],'.')
        
        %d.error = [d.error [dat.trial(find(~isnan([dat.trial.intended_finger]))).first_press]-[dat.trial(find(~isnan([dat.trial.intended_finger]))).intended_finger]];
        error = [error [dat.trial.first_press] - [dat.trial.intended_finger]];
        RT = [RT [dat.trial.time_preparation]];
        success = [success [dat.trial.correct]];
        
    end
    d.error(subjnum,:) = error;
    d.RT(subjnum,:) = RT;
    d.success(subjnum,:) = success;
end

%%
figure(2); clf; hold on
plot(d.RT,d.error+.1*randn(size(d.error)),'.')

%% sliding window
figure(4); clf; hold on
w = .05;
times = 0:.01:1;
for subj = 1:3
    for i=1:length(times);
        igood = find(d.RT(subj,:)>times(i)-w/2 & d.RT(subj,:)<times(i)+w/2);
        phit(subj,i) = sum(d.success(subj,igood))/length(igood);
        Nwindow(subj,i) = length(igood)
    end
end
subplot(3,1,[1 2]); hold on
plot(times,phit')

plot(times([1 end]),.25*[1 1],'k:')
xlabel('RT')
ylabel('p(success)')

subplot(3,1,3); hold on
plot(times,Nwindow);
xlabel('RT')
ylabel('Number of trials in window')
%% fit model
[pOpt xplt yplt] = fitSAT(d.RT,d.success);
figure(3);
plot(xplt,yplt,'g')