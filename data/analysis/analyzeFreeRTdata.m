% analyze AVMA free RT data
clear all
load ../freeresp

time_bins = .2:.02:.6;
figure(1); clf; hold on
subplot(3,1,1); hold on
hist([dat.trial.time_press],time_bins);
xlabel('RT')

subplot(3,1,2); hold on
hist([dat.trial(find([dat.trial.correct])).time_press],time_bins)
xlabel('RT')

subplot(3,1,3); hold on
hist([dat.trial(find(~[dat.trial.correct])).time_press],time_bins)
xlabel('RT')

figure(2); clf; hold on
plot([dat.trial.time_press],'k.-','markersize',30)
plot(find(~[dat.trial.correct]),[dat.trial(find(~[dat.trial.correct])).time_press],'r.','markersize',30)
ylabel('RT')
xlabel('trial Num')