clc; clear; close all;

Fs      = 44100;
Fs_play = 44100;
semi    = 0;
df      = 0;
M       = 1;
bits    = 16;
bpm     = 116;

A3=220.00; C4=261.63; D4=293.66; E4=329.63; F4=349.23; G4=392.00;
A4=440.00; Bb4=466.16; C5=523.25; D5=587.33; E5=659.26; F5=698.46;
R = 0;

freq = [ A3, C4, D4, R, D4, R, D4, E4, F4, R, F4, R, F4, G4, E4, R, E4, R, D4, C4, C4, D4 ];
dur  = [ 1,  1,  1,  1, 1,  1, 1,  1,  1,  1, 1,  1, 1,  1,  1,  1, 1,  1, 1,  1,  1,  1  ];

amps = [1 0.32 0.16 0.07];
step = 60 / bpm / 4;
signal = [];

for n = 1:numel(freq)
    N = round(dur(n) * step * Fs);
    if freq(n) == 0
        signal = [signal; zeros(N,1)];
        continue
    end
    t = (0:N-1)' / Fs;
    f_base = freq(n) * 2^(semi/12);

    env = ones(N,1);
    a = min(round(0.008*Fs), N);
    r = min(round(0.025*Fs), N);
    env(1:a)         = 0.5 - 0.5*cos(pi*(0:a-1)'/(a-1));
    env(end-r+1:end) = 0.5 + 0.5*cos(pi*(0:r-1)'/(r-1));

    tone = zeros(N,1);
    for k = 1:numel(amps)
        fk = k*f_base + df;
        if fk > 0 && fk < Fs/2
            tone = tone + amps(k) * sin(2*pi*fk*t);
        end
    end
    signal = [signal; 0.22 * tone .* env];
end
signal = signal / max(abs(signal)) * 0.85;

sig_d = signal(1:M:end);
Fs_d  = Fs / M;
q = 2^(bits-1);
sig_d = round(sig_d * q) / q;

sound(sig_d, Fs_d * Fs_play / Fs);