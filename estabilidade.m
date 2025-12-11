clc; clear; close all;

%% -------------------------------------------------------------
%  DEMONSTRAÇÃO COMPLETA DA FUNÇÃO DE TRANSFERÊNCIA DO ABS
% --------------------------------------------------------------
%
% A seguir apresentamos a dedução da função de transferência
% usada para modelar o slip (λ) em função do torque de frenagem (Tb).
%
% PASSO 1: DEFINIÇÃO DO SLIP
%   λ = (v - R*w) / v
% Para pequenas variações e velocidade quase constante v ≈ v0,
% podemos escrever:
%   dλ/dt = -(R/v0)*dw/dt
%
% PASSO 2: DINÂMICA DA RODA
%   J * dw/dt = -Tb + R*Fx
%
% PASSO 3: MODELO DE ATRITO (linearização)
%   Fx = μ(λ)*Fn
% Perto do ponto de operação λ0 = 0.2,
% podemos linearizar:
%   μ(λ) ≈ μ(λ0) + kμ*(λ - λ0)
%
% Como μ(λ0) gera apenas constante, o termo dinâmico é:
%   Fx ≈ kμ * Fn * λ
%
% PASSO 4: COMBINAÇÃO DAS EQUAÇÕES
% Substituindo Fx na equação rotacional:
%   J*dw/dt = -Tb + R*(kμ*Fn*λ)
%
% Agora substitui-se dw/dt na expressão de dλ/dt:
%
%  dλ/dt = -(R/v0)*(dw/dt)
%
%  dλ/dt = -(R/v0)*(1/J)*(-Tb + R*kμ*Fn*λ)
%
% Expansão:
%  dλ/dt = (R/(J*v0))*Tb - (R^2 * kμ * Fn)/(J*v0) * λ
%
% Isso tem a forma clássica:
%  dλ/dt = -a * λ + K * Tb
%
% Portanto:
%   a = (R^2 * kμ * Fn)/(J * v0)
%   K = R / v0
%
% PASSO 5: TRANSFORMADA DE LAPLACE
% Transformando:
%   s*Λ(s) = -a Λ(s) + K Tb(s)
%
% Isolando Λ(s)/Tb(s):
%
%   G(s) = Λ(s)/Tb(s) = K / (s + a)
%
% Essa é a função de transferência do slip em malha aberta.
% --------------------------------------------------------------


%% -------------------------------------------------------------
%  1. PARÂMETROS FÍSICOS REAIS
% -------------------------------------------------------------
g = 32.18;        % gravidade (ft/s^2)
m = 50;           % massa em slugs
R = 1.25;         % raio (ft)
J = 5;            % inércia da roda (slug*ft^2)
v0 = 88;          % velocidade inicial (ft/s)
k_mu = 2.0;       % inclinação da curva de atrito no ponto λ0
Fn = m * g;       % força normal (lb)

fprintf("\n=== PARÂMETROS DO MODELO ===\n");
fprintf("Fn = %.2f lb\n", Fn);


%% -------------------------------------------------------------
%  2. CÁLCULO DO GANHO E DO POLO DA FUNÇÃO DE TRANSFERÊNCIA
% -------------------------------------------------------------
K_num = R / v0;                     % ganho estático (K)
pole_a = (R^2 * k_mu * Fn) / (J * v0); % polo da planta (a)

fprintf("\n=== FUNÇÃO DE TRANSFERÊNCIA ===\n");
fprintf("G(s) = %.5f / (s + %.4f)\n", K_num, pole_a);
fprintf("Polo calculado: %.4f (estável)\n", -pole_a);


%% -------------------------------------------------------------
%  3. RESPOSTA AO DEGRAU (ANALÍTICA)
%     y(t) = (K/a)*(1 - exp(-a*t))
% -------------------------------------------------------------
t = 0:0.001:0.5;
y_step = (K_num/pole_a) * (1 - exp(-pole_a * t));

figure('Color','w', 'Position', [100 100 600 400]);
plot(t, y_step, 'b', 'LineWidth', 2);
grid on;
title('Resposta ao Degrau da Planta (Malha Aberta)', 'FontSize', 12);
xlabel('Tempo (s)', 'FontSize', 11);
ylabel('Slip (λ)', 'FontSize', 11);
xlim([0 0.5]);
saveas(gcf, 'step_real.png');


%% -------------------------------------------------------------
%  4. DIAGRAMA DE BODE (MANUAL)
% -------------------------------------------------------------
w = logspace(-1, 3, 1000); % frequências de 0.1 a 1000 rad/s
s = 1j * w;

G_jw = K_num ./ (s + pole_a);

mag_db = 20 * log10(abs(G_jw));
phase_deg = (180/pi) * angle(G_jw);

figure('Color','w', 'Position', [100 100 600 500]);

subplot(2,1,1);
semilogx(w, mag_db, 'b', 'LineWidth', 2);
grid on;
title('Diagrama de Bode - Magnitude', 'FontSize', 12);
ylabel('Magnitude (dB)', 'FontSize', 11);
xlim([0.1 1000]);

subplot(2,1,2);
semilogx(w, phase_deg, 'r', 'LineWidth', 2);
grid on;
title('Diagrama de Bode - Fase', 'FontSize', 12);
ylabel('Fase (graus)', 'FontSize', 11);
xlabel('Frequência (rad/s)', 'FontSize', 11);
xlim([0.1 1000]);
yticks([-90 -45 0]);
saveas(gcf, 'bode_real.png');


%% -------------------------------------------------------------
%  5. LUGAR DAS RAÍZES (MANUAL)
% -------------------------------------------------------------
figure('Color','w', 'Position', [100 100 600 400]);
hold on;

% Eixos
plot([-20 5], [0 0], 'k', 'LineWidth', 1);
plot([0 0], [-3 3], 'k', 'LineWidth', 1);

% Ramo do lugar das raízes
plot([-pole_a -100], [0 0], 'b-', 'LineWidth', 3);

% Polo
plot(-pole_a, 0, 'rx', 'MarkerSize', 14, 'LineWidth', 2.5);

text(-pole_a, 0.5, sprintf('\\leftarrow Polo = %.2f', -pole_a), ...
     'FontSize', 11, 'FontWeight', 'bold');

title('Lugar das Raízes (Root Locus)', 'FontSize', 12);
xlabel('Eixo Real (σ)', 'FontSize', 11);
ylabel('Eixo Imaginário (jω)', 'FontSize', 11);
axis([-20 2 -2 2]);
grid on; box on;

saveas(gcf, 'root_locus_real.png');

disp('Sucesso! Imagens geradas: step_real.png, bode_real.png, root_locus_real.png.');
