clc; clear; close all;

Fs = 70000; 

A3=220.00; C4=261.63; D4=293.66; E4=329.63; F4=349.23; G4=392.00;
A4=440.00; Bb4=30000.16;
R = 0;

notes = [
    A3, 0.2;  C4, 0.2;  D4, 0.2;  R, 0.1;
    D4, 0.2;  R, 0.1;   D4, 0.2;  E4, 0.2;
    F4, 0.2;  R, 0.1;   F4, 0.2;  R, 0.1;
    F4, 0.2;  G4, 0.2;  E4, 0.2;  R, 0.1;
    E4, 0.2;  R, 0.1;   D4, 0.2;  C4, 0.2;
    C4, 0.2;  D4, 0.8;

    A3, 0.2;  C4, 0.2;  D4, 0.2;  R, 0.1;
    D4, 0.2;  R, 0.1;   D4, 0.2;  F4, 0.2;
    G4, 0.2;  R, 0.1;   G4, 0.2;  R, 0.1;
    G4, 0.2; A4, 0.2; Bb4, 0.2; R, 0.1;
    Bb4, 0.2; R, 0.1;   A4, 0.2;  G4, 0.2;
    A4, 0.8;

    D4, 1.4 
];

freq = notes(:,1);
dur  = notes(:,2);

signal = [];
for n = 1:numel(freq)
    N = round(dur(n) * Fs);

    if freq(n) == 0
        signal = [signal; zeros(N,1)];
        continue
    end

    t = (0:N-1)' / Fs;

    env = ones(N,1);
    a  = min(round(0.008*Fs), N);
    rl = min(round(0.025*Fs), N);
    env(1:a)          = 0.5 - 0.5*cos(pi*(0:a-1)'/(a-1));
    env(end-rl+1:end) = 0.5 + 0.5*cos(pi*(0:rl-1)'/(rl-1));

    tone = sin(2*pi*freq(n)*t); 

    signal = [signal; tone .* env];
end

signal = signal / max(abs(signal)) * 0.85;

sound(signal, Fs);

fprintf('Fs: %d Гц\n', Fs);
fprintf('Сэмплы: %d\n', length(signal));
fprintf('Длительность: %.2f с\n', length(signal)/Fs);

N_win = 4096;
seg_raw = signal(1 : N_win);

fa = logspace(log10(50), log10(Fs/2), 1024)';

Amp_linear = manual_dft_at(seg_raw, Fs, fa);
Amp_db = 20*log10(Amp_linear + eps);

figure('Name', sprintf('Типа спектр=%d', Fs));
h_stem = stem(fa, Amp_db, 'b', 'MarkerSize', 1, 'LineWidth', 0.5); hold on;
set(h_stem, 'BaseValue', -90);

set(gca, 'XScale', 'log');
grid on; box on;
xlabel('Частота, Гц');
ylabel('Амплитуда, дБ');
title(sprintf('Спектр'));

xlim([50 Fs/2]); 
ylim([-90 0]);

target_freqs = [220.00, 261.63, 293.66, 329.63, 349.23, 392.00];
target_names = {'A3', 'C4', 'D4', 'E4', 'F4', 'G4'};

for i = 1:length(target_freqs)
    f_t = target_freqs(i);
    
    if f_t < Fs/2
        [~, idx] = min(abs(fa - f_t));
        
        if abs(fa(idx)-f_t) < 5 && Amp_db(idx) > -70
            plot(fa(idx), Amp_db(idx), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
            text(fa(idx)+20, Amp_db(idx)+5, sprintf('%s (%d Гц)', target_names{i}, round(f_t)), ...
                'FontSize', 8, 'Color', 'red');
        end
    end
end


function Amp = manual_dft_at(x, fs, f_targets)
    x = x(:);
    N = length(x);
    n = (0:N-1)';
    
    ang = 2*pi*f_targets(:)*n'/fs;      
    Re = cos(ang)*x;
    Im = -sin(ang)*x;

    Amp = sqrt(Re.^2 + Im.^2) * 2/N;
end
