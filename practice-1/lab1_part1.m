clc; clear; close all;

f = 5;
T = 1;
y_func = @(t) 2*sin(2*pi*f*t + pi/6);

tc = linspace(0, T, 10000);
yc = y_func(tc);

figure;
plot(tc, yc, 'LineWidth', 1.5);
grid on; xlabel('Время, с'); ylabel('Амплитуда');
title('Непрерывный сигнал y(t)');

fmax = f; 
fs_min = 2 * fmax;

fprintf('\nМаксимальная частота: %.2f Гц\n', fmax);
fprintf('Минимальная частота дискретизации: %.2f Гц\n', fs_min);

process_signal(y_func, tc, yc, T, fs_min, 'fs_min');
process_signal(y_func, tc, yc, T, 4*fs_min, 'fs_x4');


function process_signal(func, t_cont, y_cont, duration, fs, label)
    N = round(duration * fs);
    td = (0:N-1) / fs;
    samples = func(td);

    fprintf('\n%s = %.0f Гц\n', label, fs);
    fprintf('Число отсчётов N = %d\n', N);

    figure;
    plot(t_cont, y_cont, 'LineWidth', 1.5); hold on;
    stem(td, samples, 'filled', 'MarkerSize', 8);
    grid on; xlabel('Время, с'); ylabel('Амплитуда');
    title(sprintf('Оцифровка при fs = %.0f Гц', fs));
    legend('Оригинал', 'Отсчёты', 'Location', 'best');
    hold off;

    [Amp, fa] = manual_dft(samples, fs);

    bw = fa(find(Amp >= 0.05*max(Amp), 1, 'last'));
    
    fprintf('Ширина спектра: %.2f Гц\n', bw);
    fprintf('Память отсчётов: %d байт\n', N*8);       
    fprintf('Память спектра: %d байт\n', numel(fa)*2*8); 

    figure;
    stem(fa, Amp, 'filled', 'MarkerSize', 8);
    grid on; xlabel('Частота, Гц'); ylabel('Амплитуда');
    title(sprintf('Амплитудный спектр, fs = %.0f Гц', fs));
    xlim([0 max(fa)]);

    yr = interp1(td, samples, t_cont, 'linear', 'extrap');

    figure;
    plot(t_cont, y_cont, 'LineWidth', 1.5); hold on;
    plot(td, samples, '-ro', 'LineWidth', 1.5, 'MarkerFaceColor', 'r', 'MarkerSize', 8);
    grid on; xlabel('Время, с'); ylabel('Амплитуда');
    title(sprintf('Восстановление сигнала, fs = %.0f Гц', fs));
    legend('Оригинал', 'По отсчётам', 'Location', 'best');
    hold off;
end


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