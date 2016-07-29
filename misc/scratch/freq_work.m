
% length is 2206, L/2 = 1103
beep1 = MakeBeep(800, 0.05, 44100);
beep1 = ones(1, 44100*0.05);

% space to result clicks *centered* on a period of 0.5s
% this one is correct??
space1 = zeros(1, (0.5 * 44100) - 2206);

% space to result clicks *spaced by* a period of 0.5s
space2 = zeros(1, 0.5 * 44100);

click1 = [beep1, space1, beep1, space1, beep1, space1];
click2 = [beep1, space2, beep1, space2, beep1, space2];

L1 = length(click1);
L2 = length(click2);

N1 = 2^nextpow2(L1);
N2 = 2^nextpow2(L2);

Y1 = fft(click1, N1);
Y2 = fft(click2, N2);

f1 = 44100 * (0:(N1/2))/N1;
f2 = 44100 * (0:(N2/2))/N2;

P1 = abs(Y1/N1);
P2 = abs(Y2/N2);

plot(f1, P1(1:N1/2 + 1));
hold on
plot(f2, P2(1:N2/2 + 1), 'r');

