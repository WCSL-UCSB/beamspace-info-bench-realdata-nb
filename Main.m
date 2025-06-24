clc; close all; clear;

% Load configuration
run('Config.m');

% Create a dataset using of all locations data in the given sector.
% It also provides the number of paths of each location and their LoS angle of arrivals
[Dataset, Path_Numbers, LoS_AOA] = Make_Data(params.MPC.path, params.Locations, params.MPC.sectorNumber, params.Reference_Rotation);

[C_A_Info, C_B_Info, C_A_Info_S, C_B_Info_S] = Capacity_INFO(params.SNR, params.Trials, params.N, params.K,params.W, params.fc, ...
    params.Bw, params.df, Dataset, Path_Numbers, LoS_AOA, params.Min_Angle, params.Window_Type);
disp("Information theoretic benchmarks are generated!")


[C_A_Ideal_LMMSE, C_B_Ideal_LMMSE, C_A_Ideal_LMMSE_S, C_B_Ideal_LMMSE_S] = Capacity_Ideal_LMMSE(params.SNR, params.Trials, params.N,...
    params.K, params.W, params.fc, Dataset, Path_Numbers, LoS_AOA, params.Min_Angle, params.Es);
disp("Ideal LMMSE benchmarks are generated!")


[C_A_Adaptive_LMMSE, C_B_Adaptive_LMMSE, C_A_Adaptive_LMMSE_S, C_B_Adaptive_LMMSE_S] = Capacity_Adaptive_LMMSE(params.SNR, params.Trials,...
    params.N, params.K, params.W, params.T_A, params.T_B, params.D, params.Q, params.Constellation, params.fc, params.Bw, ...
    Dataset, Path_Numbers, LoS_AOA, params.Min_Angle, params.Es, params.Pulse_Shape, params.RC_T, params.RC_B, params.ISI_Factor);
disp("Adaptive LMMSE capacity analyses are generated!")


figure(1)
Plot_Capacity(params.SNR, C_A_Info, C_B_Info, C_A_Ideal_LMMSE * params.Bw, C_B_Ideal_LMMSE * params.Bw, C_A_Adaptive_LMMSE * params.Bw, ...
    C_B_Adaptive_LMMSE * params.Bw, "Multi path", params.Pulse_Shape)

figure(2)
Plot_Capacity(params.SNR, C_A_Info_S, C_B_Info_S, C_A_Ideal_LMMSE_S * params.Bw, C_B_Ideal_LMMSE_S * params.Bw, C_A_Adaptive_LMMSE_S * params.Bw, ...
    C_B_Adaptive_LMMSE_S * params.Bw, "Single path", params.Pulse_Shape)