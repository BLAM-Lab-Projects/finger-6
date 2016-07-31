
Fs = 44100;
beep1 = MakeBeep(1046, 0.05, Fs);
%beep1 = ones(1, Fs*0.01);

% this is correct (blue on the spectrogram, set the period to 0.5
% for easy spotting)
space1 = zeros(1, (0.5 * Fs) - length(beep1));

% space to result clicks *spaced by* a period of 0.5s
space2 = zeros(1, 0.5 * Fs);

click1 = [beep1, space1, beep1, space1, beep1, space1];
click2 = [beep1, space2, beep1, space2, beep1, space2];

L1 = length(click1);
L2 = length(click2);

N1 = 2^nextpow2(L1);
N2 = 2^nextpow2(L2);

Y1 = fft(click1, N1);
Y2 = fft(click2, N2);

f1 = Fs * (0:(N1/2))/N1;
f2 = Fs * (0:(N2/2))/N2;

P1 = abs(Y1/N1);
P2 = abs(Y2/N2);

plot(f1, P1(1:N1/2 + 1));
hold on
plot(f2, P2(1:N2/2 + 1), 'r');
xlim([0, 10]);
ylim([0, 0.001]);
