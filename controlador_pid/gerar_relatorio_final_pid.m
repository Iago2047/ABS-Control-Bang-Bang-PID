%% 1. Configuração e Simulação
clear; close all; clc; 

% --- Caso Nominal (Massa = 50) ---
disp('1. Rodando Caso Nominal (m=50)...');
sldemo_absdata;      
m = 50;              
sim('sldemo_absbrake'); 
dados_nominal = sldemo_absbrake_output; 

% --- Caso Robusto (Massa = 100) ---
disp('2. Rodando Caso Incerteza (m=100)...');
m = 100;             
sim('sldemo_absbrake');
dados_robusto = sldemo_absbrake_output; 

%% 2. Gerar o Gráfico de Robustez (Subplot: Saída + Controle)
disp('3. Gerando Relatório de Robustez...');
figure('Name', 'Relatório Final PID - Robustez', 'Color', 'w', 'Position', [100 100 800 600]);

% --- SUBPLOT 1: Saída (Slip) vs Referência ---
subplot(2,1,1);
plot(dados_nominal.get('slp').Values.Time, dados_nominal.get('slp').Values.Data, 'b', 'LineWidth', 1.5); hold on;
plot(dados_robusto.get('slp').Values.Time, dados_robusto.get('slp').Values.Data, 'r--', 'LineWidth', 1.5);
yline(0.2, 'g-', 'Referência (0.2)', 'LineWidth', 2); 
title('Resposta de Saída (Slip) - Rastreamento');
ylabel('Slip'); legend('Nominal (m=50)', 'Incerteza (m=100)', 'Ref'); grid on; ylim([0 1]);

% --- SUBPLOT 2: Ação de Controle ---
subplot(2,1,2); 
try
    % A MANEIRA SEGURA: Buscar pelo NOME que você deu no Simulink
    % Altere 'u_smc' para o nome exato que você colocou na linha do sinal
    sig_nom = dados_nominal.get('controller out'); 
    sig_rob = dados_robusto.get('controller out');
    
    plot(sig_nom.Values.Time, sig_nom.Values.Data, 'b', 'LineWidth', 1); hold on;
    plot(sig_rob.Values.Time, sig_rob.Values.Data, 'r--', 'LineWidth', 1);
    
    ylabel('Controle (u)'); 
    xlabel('Tempo (s)'); 
    title('Esforço de Controle'); 
    legend('Nominal', 'Incerteza'); 
    grid on;
    
catch
    % Se der erro, avisa qual nome ele tentou buscar e não achou
    text(0.5, 0.5, 'ERRO: Sinal "u_smc" não encontrado no log! Verifique o Simulink.');
    warning('Certifique-se de que a linha de saída do controlador se chama "u_control" e está marcada para logar (símbolo wifi).');
end

%% Espectrograma 
% Extrair o sinal
sinal_u = dados_nominal.get('controller out');
u = sinal_u.Values.Data;
t = sinal_u.Values.Time;

% Taxa de amostragem estimada
Fs = 1/mean(diff(t));

% Janela e parâmetros do espectrograma
window = hamming(round(0.5*Fs));   % janela de 0.5 s
noverlap = round(0.45*Fs);         % alto overlap para suavizar
nfft = 2048;                       % aumenta resolução em frequência

% Gerar espectrograma em dB
[S,F,T] = spectrogram(u, window, noverlap, nfft, Fs, 'yaxis');
SdB = 20*log10(abs(S) + 1e-12);    % evita log(0)

% Plot
figure;
imagesc(T, F, SdB);
axis xy;
xlabel('Tempo (s)');
ylabel('Frequência (Hz)');
title('Espectrograma do Sinal de Controle (controller out)');

% Ajuste de contraste (ESSENCIAL)
caxis([max(SdB(:))-60, max(SdB(:))]);  % realça diferenças de energia

% Cores científicas
colormap(turbo);                      % padrão usado em artigos recentes
colorbar;

%% 4. Cálculo das Métricas de Performance (SMC)
disp('--------------------------------------------------');
disp('5. Calculando métricas de erro (RMSE, ISE, IAE, ITAE)...');

% Vamos usar o caso NOMINAL para comparar com o PID do seu colega
% (Se quiser o robusto, troque por dados_robusto)
dados_metricas = dados_nominal;

try
    % 1. Extrair os vetores de Tempo e Saída (Slip)
    % O Simulink guarda isso dentro da estrutura 'slp'
    time_vec = dados_metricas.get('slp').Values.Time;
    slip_vec = dados_metricas.get('slp').Values.Data;
    
    % 2. Definir a Referência (O alvo é 0.2)
    ref_val = 0.2;
    
    % 3. Calcular o ERRO (Referência - Real)
    error_vec = ref_val - slip_vec;
    
    % 4. Calcular as Métricas Matemáticas
    
    % RMSE (Root Mean Square Error) - Média do erro
    RMSE = sqrt(mean(error_vec.^2));
    
    % ISE (Integral Square Error) - Penaliza grandes erros
    % A função 'trapz' faz a integral numérica no MATLAB
    ISE = trapz(time_vec, error_vec.^2);
    
    % IAE (Integral Absolute Error) - Acumulado total do erro
    IAE = trapz(time_vec, abs(error_vec));
    
    % ITAE (Integral Time Absolute Error) - Penaliza erros que demoram a sumir
    ITAE = trapz(time_vec, time_vec .* abs(error_vec));
    
    % 5. Mostrar o Resultado Bonito na Tela
    fprintf('\n>>> RESULTADOS PARA A TABELA (PID NOMINAL) <<<\n');
    fprintf('RMSE : %.4f \n', RMSE);
    fprintf('ISE  : %.4f \n', ISE);
    fprintf('IAE  : %.4f \n', IAE);
    fprintf('ITAE : %.4f \n', ITAE);
    disp('--------------------------------------------------');
    
catch
    warning('Erro ao calcular. Verifique se a simulação rodou e se a variável "dados_nominal" existe.');
end