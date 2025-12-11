clc; clear; close all;

% --- 1. Parâmetros Físicos Reais ---
g = 32.18;      % ft/s^2
m = 50;         % slugs
R = 1.25;       % ft
J = 5;          % slug*ft^2
v0 = 88;        % ft/s
k_mu = 2.0;     % inclinação
Fn = m * g;     % Força Normal


% Modelo: G(s) = K / (s + a)
K_num = R / v0;                     % Ganho do numerador (K)
pole_a = (R^2 * k_mu * Fn) / (J * v0); % Polo (a)

fprintf('Polo calculado: %.4f\n', -pole_a);

% --- 3. Gráfico 1: Resposta ao Degrau (Cálculo Manual) ---
% Fórmula analítica: y(t) = (K/a) * (1 - exp(-a*t))
t = 0:0.001:0.5;
y_step = (K_num/pole_a) * (1 - exp(-pole_a * t));

figure('Color','w', 'Position', [100 100 600 400]);
plot(t, y_step, 'b', 'LineWidth', 2);
grid on;
title('Resposta ao Degrau (Malha Aberta)', 'FontSize', 12);
xlabel('Tempo (s)', 'FontSize', 11);
ylabel('Amplitude (Slip)', 'FontSize', 11);

xlim([0 0.5]);
saveas(gcf, 'step_real.png');

% --- 4. Gráfico 2: Diagrama de Bode ---
w = logspace(-1, 3, 1000); % Frequências 0.1 a 1000
s = 1j * w;
% G(jw) = K / (jw + a)
G_jw = K_num ./ (s + pole_a);

mag_db = 20 * log10(abs(G_jw));
phase_deg = (180/pi) * angle(G_jw);

figure('Color','w', 'Position', [100 100 600 500]);
% Magnitude
subplot(2,1,1);
semilogx(w, mag_db, 'b', 'LineWidth', 2);
grid on;
title('Diagrama de Bode (Resposta em Frequência)', 'FontSize', 12);
ylabel('Magnitude (dB)', 'FontSize', 11);
xlim([0.1 1000]);

% Fase
subplot(2,1,2);
semilogx(w, phase_deg, 'r', 'LineWidth', 2);
grid on;
ylabel('Fase (graus)', 'FontSize', 11);
xlabel('Frequência (rad/s)', 'FontSize', 11);
xlim([0.1 1000]);
yticks([-90 -45 0]);
saveas(gcf, 'bode_real.png');

% --- 5. Gráfico 3: Lugar das Raízes ---
figure('Color','w', 'Position', [100 100 600 400]);
hold on;
% Desenhar Eixos
plot([-20 5], [0 0], 'k', 'LineWidth', 1); % Eixo Real
plot([0 0], [-3 3], 'k', 'LineWidth', 1);  % Eixo Imag

% Desenhar o Ramo do Lugar das Raízes (Linha Azul)
% Vai do polo para a esquerda
plot([-pole_a -100], [0 0], 'b-', 'LineWidth', 3); 

% Desenhar o Polo (X Vermelho)
plot(-pole_a, 0, 'rx', 'MarkerSize', 14, 'LineWidth', 2.5);

% Texto explicativo
text(-pole_a, 0.5, sprintf('\\downarrow Polo em %.2f', -pole_a), ...
    'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold');

title('Lugar das Raízes (Root Locus)', 'FontSize', 12);
xlabel('Eixo Real (\sigma)', 'FontSize', 11);
ylabel('Eixo Imaginário (j\omega)', 'FontSize', 11);
axis([-20 2 -2 2]); % Zoom na área importante
grid on; box on;
saveas(gcf, 'root_locus_real.png');

disp('Sucesso! Imagens geradas: step_real, bode_real, root_locus_real.');