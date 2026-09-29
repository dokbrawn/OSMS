clc; clear all; close all;

f = 5; 
T_duration = 1;
Fs_cont = 10000; 

t_cont = 0 : 1/Fs_cont : T_duration - 1/Fs_cont;
x_analog = 2 * sin(2*pi*f*t_cont + pi/6);
max_amp = max(abs(x_analog)); 

bits_array = [3, 4, 5, 6];
colors_q = ['r', 'g', 'b', 'm'];

N_win = 4096; 
start_idx = floor(length(t_cont)/2);
seg_ideal = x_analog(start_idx : start_idx + N_win - 1);

figure('Name', 'Квантование АЦП');

for i = 1:length(bits_array)
    n_bits = bits_array(i);
    levels = 2^n_bits;
    max_level = levels - 1;
    
    x_shifted = x_analog + max_amp;
    x_scaled = (x_shifted / (2 * max_amp)) * max_level;
    x_q_int = round(x_scaled);
    x_q_int(x_q_int > max_level) = max_level;
    x_q_int(x_q_int < 0) = 0;
    x_quantized_full = (x_q_int / max_level) * (2 * max_amp) - max_amp;
    
    seg_quant = x_quantized_full(start_idx : start_idx + N_win - 1);
    
    mse = mean((x_analog - x_quantized_full).^2);
    
    fprintf('\nАЦП %d бит | Уровней: %d | MSE: %.5f\n', n_bits, levels, mse);
    
    [Amp_i, fa_i] = manual_dft(seg_ideal, Fs_cont);
    [Amp_q, fa_q] = manual_dft(seg_quant, Fs_cont);
    
    subplot(2, 2, i);
    plot(fa_i, Amp_i, 'k--', 'LineWidth', 1.5); hold on;
    plot(fa_q, Amp_q, colors_q(i), 'LineWidth', 1.5);
    grid on; xlabel('Частота, Гц'); ylabel('Амплитуда');
    title(sprintf('%d бит (MSE=%.4f)', n_bits, mse));
    xlim([0 50]); ylim([0 2.5]);
    legend('Идеал', sprintf('%d бит', n_bits), 'Location', 'best');
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