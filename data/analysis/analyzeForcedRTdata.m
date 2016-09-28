% analyze forced RT data
clear all
load ../timedresp

figure(2); clf; hold on
plot([tr_dat.trial.time_preparation],[tr_dat.trial(find([tr_dat.trial.intended_finger]>0)).index_press]-[tr_dat.trial(find([tr_dat.trial.intended_finger]>0)).intended_finger],'.')

d.RT = [tr_dat.trial.time_preparation];
d.success = [tr_dat.trial(find(~isnan([tr_dat.trial.correct]))).correct];



%% sliding window
figure(3); clf; hold on
w = .05;
times = 0:.01:1;
for i=1:length(times);
    igood = find(d.RT>times(i)-w/2 & d.RT<times(i)+w/2);
    phit(i) = sum(d.success(igood))/length(igood);
    Nwindow(i) = length(igood)
end
subplot(3,1,[1 2]); hold on
plot(times,phit)
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