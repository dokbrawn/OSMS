clc; clear; close all;

f_GHz = 1.8;
f_MHz = f_GHz * 1000;
BW_UL_Hz = 10e6;
BW_DL_Hz = 20e6;
Ptx_BS_dBm = 46;
Ptx_UE_dBm = 24;
Gant_BS_dBi = 21;
MIMO_gain_dB = 3;
Feeder_loss_dB = 2 + 0.4 + 0.5;
Penetration_margin_dB = 15;
IM_margin_dB = 1;
NF_BS_dB = 2.4;
NF_UE_dB = 6;
SINR_req_DL_dB = 2;
SINR_req_UL_dB = 4;
h_BS_m = 30;
h_MS_m = 1.5;
Area_macro_km2 = 100;
Area_micro_km2 = 4;
wi_h_building = 20;
wi_w_street = 20;
wi_b_dist = 30;
wi_phi_deg = 50;

[MAPL_UL_dB, MAPL_DL_dB] = calc_link_budget(Ptx_BS_dBm, Ptx_UE_dBm, Gant_BS_dBi, MIMO_gain_dB, Feeder_loss_dB, Penetration_margin_dB, IM_margin_dB, NF_BS_dB, NF_UE_dB, BW_UL_Hz, BW_DL_Hz, SINR_req_UL_dB, SINR_req_DL_dB);

fprintf('Бюджет канала\n');
fprintf('MAPL_UL: %.2f дБ\n', MAPL_UL_dB);
fprintf('MAPL_DL: %.2f дБ\n\n', MAPL_DL_dB);

d_km = linspace(0.001, 6, 600);

PL_Hata_f = arrayfun(@(d) model_COST231_Hata(d, f_MHz, h_BS_m, h_MS_m, 'U', 'f'), d_km);
PL_Hata_h = arrayfun(@(d) model_COST231_Hata(d, f_MHz, h_BS_m, h_MS_m, 'U', 'hbs'), d_km);
PL_WI = arrayfun(@(d) model_Walfish_Ikegami(d, f_MHz, h_BS_m, h_MS_m, wi_h_building, wi_w_street, wi_b_dist, wi_phi_deg), d_km);

[r_hf_ul, r_hf_dl, R_hf, N_hf] = find_radius_and_area(d_km, PL_Hata_f, MAPL_UL_dB, MAPL_DL_dB, Area_macro_km2, 'km');
[r_hh_ul, r_hh_dl, R_hh, N_hh] = find_radius_and_area(d_km, PL_Hata_h, MAPL_UL_dB, MAPL_DL_dB, Area_macro_km2, 'km');
[r_wi_ul, r_wi_dl, R_wi, N_wi] = find_radius_and_area(d_km, PL_WI, MAPL_UL_dB, MAPL_DL_dB, Area_macro_km2, 'km');

figure('Name', 'Макросоты');
hold on; grid on; box on;

plot(d_km, PL_Hata_f, 'b-', 'LineWidth', 1.5, 'DisplayName', 'COST231-Hata (методичка, log10(f))');
plot(d_km, PL_Hata_h, 'b--', 'LineWidth', 1.5, 'DisplayName', 'COST231-Hata, log10(hBS)');
plot(d_km, PL_WI, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Walfish-Ikegami');

yline(MAPL_UL_dB, 'k:', sprintf('MAPL_{UL} = %.1f дБ', MAPL_UL_dB), 'LineWidth', 1.5, 'HandleVisibility', 'off');
yline(MAPL_DL_dB, 'k-.', sprintf('MAPL_{DL} = %.1f дБ', MAPL_DL_dB), 'LineWidth', 1.5, 'HandleVisibility', 'off');
xline(1, 'm-', 'd = 1 км', 'LineWidth', 1, 'LabelOrientation', 'horizontal', 'HandleVisibility', 'off');

idx = d_km <= r_hf_ul;
plot(d_km(idx), PL_Hata_f(idx), '-', 'Color', [0 0.4 1], 'LineWidth', 4, 'HandleVisibility', 'off');
idx = d_km <= r_hf_dl;
plot(d_km(idx), PL_Hata_f(idx), '-', 'Color', [0 0.2 0.8], 'LineWidth', 4, 'HandleVisibility', 'off');
idx = d_km <= r_wi_ul;
plot(d_km(idx), PL_WI(idx), '-', 'Color', [1 0.2 0.2], 'LineWidth', 4, 'HandleVisibility', 'off');
idx = d_km <= r_wi_dl;
plot(d_km(idx), PL_WI(idx), '-', 'Color', [0.8 0 0], 'LineWidth', 4, 'HandleVisibility', 'off');

plot(r_hf_ul, MAPL_UL_dB, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'HandleVisibility', 'off');
plot(r_hf_dl, MAPL_DL_dB, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'HandleVisibility', 'off');
plot(r_wi_ul, MAPL_UL_dB, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
plot(r_wi_dl, MAPL_DL_dB, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');

text(r_hf_ul, MAPL_UL_dB - 8, sprintf('d_{UL} = %.2f км', r_hf_ul), 'FontSize', 9, 'Color', 'b', 'HorizontalAlignment', 'center');
text(r_hf_dl, MAPL_DL_dB + 8, sprintf('d_{DL} = %.2f км', r_hf_dl), 'FontSize', 9, 'Color', 'b', 'HorizontalAlignment', 'center');
text(r_wi_ul, MAPL_UL_dB + 8, sprintf('d_{UL} = %.2f км', r_wi_ul), 'FontSize', 9, 'Color', 'r', 'HorizontalAlignment', 'center');
text(r_wi_dl, MAPL_DL_dB - 8, sprintf('d_{DL} = %.2f км', r_wi_dl), 'FontSize', 9, 'Color', 'r', 'HorizontalAlignment', 'center');

xlabel('Расстояние, км');
ylabel('Потери пути PL, дБ');
title(sprintf('Модели распространения для макросот, f = %.1f ГГц', f_GHz));
legend('Location', 'southeast');
xlim([0 6]);
ylim([0 max([max(PL_Hata_h), max(PL_WI), MAPL_DL_dB]) * 1.1]);

fprintf('Макросоты:\n');
fprintf('Hata (log10(f)):    d_UL=%.3f км, d_DL=%.3f км, R=%.3f км, N=%d\n', r_hf_ul, r_hf_dl, R_hf, N_hf);
fprintf('Hata (log10(hBS)):  d_UL=%.3f км, d_DL=%.3f км, R=%.3f км, N=%d\n', r_hh_ul, r_hh_dl, R_hh, N_hh);
fprintf('Walfish-Ikegami:    d_UL=%.3f км, d_DL=%.3f км, R=%.3f км, N=%d\n\n', r_wi_ul, r_wi_dl, R_wi, N_wi);

d_m = linspace(1, 2000, 400);
PL_UMi = arrayfun(@(d) model_UMiNLOS(d, f_GHz), d_m);

[r_mi_ul, r_mi_dl, R_mi, N_mi] = find_radius_and_area(d_m, PL_UMi, MAPL_UL_dB, MAPL_DL_dB, Area_micro_km2, 'm');

figure('Name', 'Микросоты UMiNLOS');
hold on; grid on; box on;

plot(d_m, PL_UMi, '-', 'LineWidth', 1.5, 'Color', [0.5 0.5 0.5], 'DisplayName', sprintf('UMiNLOS (%.1f ГГц)', f_GHz));
yline(MAPL_UL_dB, '-', sprintf('MAPL_{UL} = %.1f дБ', MAPL_UL_dB), 'Color', [0 0 1], 'LineWidth', 1.5, 'HandleVisibility', 'off');
yline(MAPL_DL_dB, '--', sprintf('MAPL_{DL} = %.1f дБ', MAPL_DL_dB), 'Color', [0 0.6 0.6], 'LineWidth', 1.5, 'HandleVisibility', 'off');

idx = d_m <= r_mi_ul;
plot(d_m(idx), PL_UMi(idx), '-', 'LineWidth', 4, 'Color', [0 0 1], 'HandleVisibility', 'off');
idx = d_m <= r_mi_dl;
plot(d_m(idx), PL_UMi(idx), '-', 'LineWidth', 4, 'Color', [0 0.6 0.6], 'HandleVisibility', 'off');

plot(r_mi_ul, MAPL_UL_dB, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'HandleVisibility', 'off');
plot(r_mi_dl, MAPL_DL_dB, 'o', 'MarkerSize', 8, 'MarkerFaceColor', [0 0.6 0.6], 'Color', [0 0.6 0.6], 'HandleVisibility', 'off');

text(r_mi_ul + 20, MAPL_UL_dB - 8, sprintf('d_{UL} = %.0f м', r_mi_ul), 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'b');
text(r_mi_dl + 20, MAPL_DL_dB - 8, sprintf('d_{DL} = %.0f м', r_mi_dl), 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0 0.5 0.5]);

xlabel('Расстояние, м');
ylabel('Потери сигнала, дБ');
title('Определение радиуса UL и DL (микросоты)');
legend('Location', 'southeast');
xlim([0 max(r_mi_ul, r_mi_dl) * 1.5]);
ylim([0 max([max(PL_UMi(d_m <= max(r_mi_ul, r_mi_dl) * 1.5)), MAPL_DL_dB]) * 1.1]);

fprintf('Микросоты:\n');
fprintf('UMiNLOS: d_UL=%.1f м, d_DL=%.1f м, R=%.1f м, N=%d\n', r_mi_ul, r_mi_dl, R_mi, N_mi);

function [MAPL_UL, MAPL_DL] = calc_link_budget(Ptx_BS, Ptx_UE, Gain_BS, MIMO_Gain, Feeder_Loss, Pen_Margin, IM_Margin, NF_BS, NF_UE, BW_UL, BW_DL, SINR_UL, SINR_DL)
    TN_UL = -174 + 10*log10(BW_UL);
    TN_DL = -174 + 10*log10(BW_DL);
    RxSens_UE = NF_UE + TN_DL + SINR_DL;
    RxSens_BS = NF_BS + TN_UL + SINR_UL;
    MAPL_DL = Ptx_BS - Feeder_Loss + Gain_BS + MIMO_Gain - IM_Margin - Pen_Margin - RxSens_UE;
    MAPL_UL = Ptx_UE - Feeder_Loss + Gain_BS + MIMO_Gain - IM_Margin - Pen_Margin - RxSens_BS;
end

function [r_ul, r_dl, R_min, Num_Bs] = find_radius_and_area(distances, path_losses, MAPL_UL, MAPL_DL, total_area, unit)
    r_ul = interp_cross(distances, path_losses, MAPL_UL);
    r_dl = interp_cross(distances, path_losses, MAPL_DL);
    R_min = min(r_ul, r_dl);
    if strcmp(unit, 'm')
        R_km = R_min / 1000;
    else
        R_km = R_min;
    end
    S_site = 1.95 * R_km^2;
    Num_Bs = ceil(total_area / S_site);
end

function r = interp_cross(distances, path_losses, limit)
    idx = find(path_losses >= limit, 1, 'first');
    if isempty(idx)
        r = NaN; return;
    end
    if idx == 1
        r = distances(1); return;
    end
    x1 = distances(idx-1); y1 = path_losses(idx-1);
    x2 = distances(idx);   y2 = path_losses(idx);
    r = x1 + (limit - y1) * (x2 - x1) / (y2 - y1);
end

function PL = model_COST231_Hata(d_km, f_MHz, h_bs, h_ms, clutter_type, slope_mode)
    d_km = max(d_km, 0.001);
    if f_MHz >= 1500
        A = 46.3; B = 33.9;
    else
        A = 69.55; B = 26.16;
    end
    if strcmp(clutter_type, 'DU') || strcmp(clutter_type, 'U')
        a_hms = 3.2 * (log10(11.75 * h_ms))^2 - 4.97;
    else
        a_hms = (1.1 * log10(f_MHz)) * h_ms - (1.56 * log10(f_MHz) - 0.8);
    end
    if strcmp(clutter_type, 'DU')
        L_clutter = 3;
    elseif strcmp(clutter_type, 'U')
        L_clutter = 0;
    elseif strcmp(clutter_type, 'SU')
        L_clutter = -(2 * (log10(f_MHz/28))^2 + 5.4);
    elseif strcmp(clutter_type, 'RURAL')
        L_clutter = -(4.78 * (log10(f_MHz))^2 - 18.33 * log10(f_MHz) + 40.94);
    elseif strcmp(clutter_type, 'ROAD')
        L_clutter = -(4.78 * (log10(f_MHz))^2 - 18.33 * log10(f_MHz) + 35.94);
    else
        error('Unknown type');
    end
    s_low = (47.88 + 13.9 * log10(f_MHz) - 13.9 * log10(h_bs)) / log10(50);
    if strcmp(slope_mode, 'f')
        s_hi = 44.9 - 6.55 * log10(f_MHz);
    else
        s_hi = 44.9 - 6.55 * log10(h_bs);
    end
    if d_km >= 1
        s_param = s_hi;
    else
        s_param = s_low;
    end
    PL = A + B * log10(f_MHz) - 13.82 * log10(h_bs) - a_hms + s_param * log10(d_km) + L_clutter;
end

function PL = model_Walfish_Ikegami(d_km, f_MHz, h_bs, h_ms, h_build, w_street, b_dist, phi_deg)
    d_km = max(d_km, 0.001);
    dh = h_build;
    L0 = 32.44 + 20*log10(f_MHz) + 20*log10(d_km);
    if phi_deg < 35
        Lori = -10 + 0.354*phi_deg;
    elseif phi_deg < 55
        Lori = 2.5 + 0.075*phi_deg;
    else
        Lori = 4.0 - 0.114*phi_deg;
    end
    L2 = -16.9 - 10*log10(w_street) + 10*log10(f_MHz) + 20*log10(dh - h_ms) + Lori;
    if h_bs > dh
        L11 = -18*log10(1 + h_bs - dh);
        ka = 54;
        kd = 18;
    else
        L11 = 0;
        if d_km > 0.5
            ka = 54 - 0.8*(h_bs - dh);
        else
            ka = 54 - 0.8*(h_bs - dh)*d_km/0.5;
        end
        kd = 18 - 15*(h_bs - dh)/dh;
    end
    kf = -4 + 0.7*(f_MHz/925 - 1);
    L1 = L11 + ka + kd*log10(d_km) + kf*log10(f_MHz) - 9*log10(b_dist);
    if L1 + L2 > 0
        PL = L0 + L1 + L2;
    else
        PL = L0;
    end
end

function PL = model_UMiNLOS(d_m, f_GHz)
    d_safe = max(d_m, 1);
    PL = 26 * log10(f_GHz) + 22.7 + 36.7 * log10(d_safe);
end
