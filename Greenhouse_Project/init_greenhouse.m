%% init_greenhouse.m
% Parameters for Sustainable Greenhouse Model
clear; clc;

% ---- Simulation parameters ----
dt = 1;            % Time step [hour]
t_end = 200;       % Total simulation time [hour]
time = 0:dt:t_end;

% ---- Greenhouse dynamic coefficients ----
aT = -0.05; bT = 0.5; dT = 0.2;   % Temperature dynamics
aH = -0.03; bH = 0.4; cH = 0.05;  % Humidity depends also on moisture
aW = -0.02; bW = 0.6;             % Soil moisture
aC = -0.04; bC = 0.5;             % CO2 concentration
aB = -0.01;                       % Biomass (growth)
alphaT = 0.03; alphaH = 0.02; alphaC = 0.04; alphaL = 0.05;

% ---- Setpoints (desired environmental targets) ----
Tsp = 25;     % °C
Hsp = 70;     % %
Csp = 900;    % ppm
Wmin = 0.4;   % minimal soil moisture
Wmax = 0.8;   % maximum soil moisture

% ---- Initial conditions ----
T = 20; H = 60; W = 0.6; C = 600; B = 1;

% ---- PID controller gains ----
Kp_T = 1.5; Ki_T = 0.1; Kd_T = 0.2;
Kp_H = 1.2; Ki_H = 0.1; Kd_H = 0.15;
Kp_C = 1.0; Ki_C = 0.05; Kd_C = 0.1;

% ---- Pre-allocate logs for plotting ----
T_log = T; H_log = H; W_log = W; C_log = C; B_log = B;

disp('✅ Greenhouse parameters initialized.'); %[output:977c4108]


%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:977c4108]
%   data: {"dataType":"text","outputData":{"text":"✅ Greenhouse parameters initialized.\n","truncated":false}}
%---
