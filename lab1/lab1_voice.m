clc; clear all; close all;

[y, Fs] = audioread('voice.wav');
if size(y, 2) > 1
    y = y(:, 1);
end

factor = 20; 
y_down = downsample(y, factor); 
Fs_down = Fs / factor;          

player = audioplayer(y_down, Fs_down);
play(player);
pause(1); 

figure('Name', 'Временные реализации');
subplot(2,1,1);
plot((0:length(y)-1)/Fs, y, 'b');
title(sprintf('Оригинал (Fs = %d Гц)', Fs));
xlabel('Время (с)'); ylabel('Амплитуда'); grid on;
xlim([0 min(2, length(y)/Fs)]);

subplot(2,1,2);
plot((0:length(y_down)-1)/Fs_down, y_down, 'r');
title(sprintf('Прореженный (Fs = %d Гц)', Fs_down));
xlabel('Время (с)'); ylabel('Амплитуда'); grid on;
xlim([0 min(2, length(y_down)/Fs_down)]);

N_win = 1024; 

mid_o = floor(length(y) / 2);
seg_o = y(mid_o : mid_o + N_win - 1);

mid_d = floor(length(y_down) / 2);
seg_d = y_down(mid_d : mid_d + N_win - 1);

[Amp_o, fa_o] = manual_dft(seg_o, Fs);
[Amp_d, fa_d] = manual_dft(seg_d, Fs_down);

Amp_o_db = 20 * log10(Amp_o + eps);
Amp_d_db = 20 * log10(Amp_d + eps);

figure('Name', 'Спектры');

subplot(2,1,1);
semilogx(fa_o(2:end), Amp_o_db(2:end), 'b', 'LineWidth', 1);
grid on; xlabel('f, Гц'); ylabel('А, дБ');
title(sprintf('Спектр ОРИГИНАЛА (Fs=%d)', Fs));
xlim([10 fa_o(end)]); ylim([-60 20]);
line([Fs_down/2 Fs_down/2], [-60 20], 'Color', 'k', 'LineStyle', '--');
text(Fs_down/2 + 50, 10, sprintf('Новый Найквист\n%.0f Гц', Fs_down/2), 'FontSize', 8);

subplot(2,1,2);
semilogx(fa_d(2:end), Amp_d_db(2:end), 'r', 'LineWidth', 1);
grid on; xlabel('f, Гц'); ylabel('А, дБ');
title(sprintf('Спектр ПРОРЕЖЕННОГО (Fs=%d)', Fs_down));
xlim([10 fa_d(end)]); ylim([-60 20]);


function [Amp, fa] = manual_dft(x, fs)
    N = length(x);
    k = (0:floor(N/2))';
    n = 0:N-1;
    
    ang = 2*pi*k*n/N;
    
    R = cos(ang)*x(:);
    I = -sin(ang)*x(:);
    
    Amp = sqrt(R.^2 + I.^2) * 2/N;
    Amp(1) = Amp(1)/2;
    if mod(N,2)==0
        Amp(end)=Amp(end)/2;
    end
    
    fa = k*fs/N;
end