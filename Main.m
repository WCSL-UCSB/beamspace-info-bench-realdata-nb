clear
clc
close all

% MPC Data's path on your local device
Path_MPC = "/Users/oveysdelafrooz/Documents/PHD/TASK/Capacity/MPC files";

% Name of each location's data based on the dateset
Locations = "MPC" + ["1581", "1582", "1583", "1584","1585","1586","1587","1588","1589",...
             "1590", "1591", "1592", "1593","1594","1595","1596","1597","1598","1599",...
             "1600", "1601", "1602", "1603","1604","2314","2315","2316","2317","2318",...
             "2319","2320","2321","2322","2323","2324","2325","2326", "2327", ...
             "2328","2329","2330","2331","2332","2333","2334","2335", "2336", ...
             "2337","2338","2339"] + ".mat";

% ******************************** Basic parameters ********************************

Reference_Rotation = 12.5288; % Angle differnece between azimuth reference (0 degree) and broadside (in degree)

Sector = "sector01"; % The sector that we want to use

N = 64; % Number of antennas

K= 16; % umber of Users

SNR = -5:1:10; % SNR range (in dB)

Train_Coef = 10;

D = 50; % Number of inference symbols

W = 4; % Beamspace of window size

T_A = Train_Coef*N; % Number of training symbols
T_B = Train_Coef*W;

fc = 28; % Carrier frequency (in GHz)

Bw = 1; % Band width (in GHz)

df = 0.1;

Min_Angle = 0; % Minimum angular distance between adjacent users (in degree)

RC_T = 1; % Raised cosine pulse symbol rate factor

RC_B = 1; % Raised cosine roll-off factor

ISI_Factor = 10; % The number of symbols that interfere with the desired symbol

Trials = 50; % Number of trials

% ******************************** Loading the dataset ********************************

% This function creats a dataset using of all locations data in the given sector.
% It also provides the number of paths of each location and their LoS angle of arrivals
[Dataset, Path_Numbers, LoS_AOA] = Make_Data(Path_MPC, Locations, Sector, Reference_Rotation);

% ******************************** Simulation parameters ********************************

Constellation = [-1-1i, -1+1i, 1-1i, 1+1i ].'; % Constellation points(QPSK)

Es = mean(abs(Constellation).^2); % Average energy of the symbols

Q = log2(length(Constellation)); % Number of bits per symbol

Pulse_Shape = "Rect";

Window_Type = "Floating";


% [C_A_Info, C_B_Info, C_A_Info_S, C_B_Info_S] = Capacity_INFO(SNR, Trials, N, K, W, fc, Bw, df, Dataset, Path_Numbers, LoS_AOA, Min_Angle, Window_Type);
% [C_A_Info, C_B_Info, C_A_Info_S, C_B_Info_S] = Capacity_INFO(SNR, Trials, N, K, W, fc, Bw, df, Dataset, Path_Numbers, LoS_AOA, Min_Angle, "Floating");
% disp("Information theoretic benchmarks are generated!")
% 
[C_A_Ideal_LMMSE, C_B_Ideal_LMMSE, C_A_Ideal_LMMSE_S, C_B_Ideal_LMMSE_S] = Capacity_Ideal_LMMSE(SNR, Trials, N, K, W, fc, Dataset, Path_Numbers, LoS_AOA, Min_Angle, Es);
disp("Ideal LMMSE benchmarks are generated!")
% 
% [C_A_Adaptive_LMMSE, C_B_Adaptive_LMMSE, C_A_Adaptive_LMMSE_S, C_B_Adaptive_LMMSE_S] = Capacity_Adaptive_LMMSE(SNR, Trials, N, K, W, T_A, T_B, D, Q, Constellation, fc, Bw, ...
%     Dataset, Path_Numbers, LoS_AOA, Min_Angle, Es, Pulse_Shape, RC_T, RC_B, ISI_Factor);
% disp("Adaptive LMMSE capacity analyses are generated!")

% save("C_A_INFO.mat", "C_A_Info")
% save("C_B_Info.mat", "C_B_Info")
% save("C_A_Ideal_LMMSE.mat", "C_A_Ideal_LMMSE")
% save("C_B_Ideal_LMMSE.mat", "C_B_Ideal_LMMSE")
% save("C_A_Adaptive_LMMSE.mat", "C_A_Adaptive_LMMSE")
% save("C_B_Adaptive_LMMSE.mat", "C_B_Adaptive_LMMSE")
% 
% save("C_A_INFO_S.mat", "C_A_Info_S")
% save("C_B_Info_S.mat", "C_B_Info_S")
% save("C_A_Ideal_LMMSE_S.mat", "C_A_Ideal_LMMSE_S")
% save("C_B_Ideal_LMMSE_S.mat", "C_B_Ideal_LMMSE_S")
% save("C_A_Adaptive_LMMSE_S.mat", "C_A_Adaptive_LMMSE_S")
% save("C_B_Adaptive_LMMSE_S.mat", "C_B_Adaptive_LMMSE_S")



% C_A_Info = load("C_A_INFO.mat").C_A_Info;
% C_B_Info = load("C_B_INFO.mat").C_B_Info;
% 
% C_A_Ideal_LMMSE = load("C_A_Ideal_LMMSE.mat").C_A_Ideal_LMMSE;
% C_B_Ideal_LMMSE = load("C_B_Ideal_LMMSE.mat").C_B_Ideal_LMMSE;
% 
% C_A_Adaptive_LMMSE = load("C_A_Adaptive_LMMSE.mat").C_A_Adaptive_LMMSE;
% C_B_Adaptive_LMMSE = load("C_B_Adaptive_LMMSE.mat").C_B_Adaptive_LMMSE;
% 
% 
% C_A_Info_S = load("C_A_Info_S.mat").C_A_Info_S;
% C_B_Info_S = load("C_B_INFO_S.mat").C_B_Info_S;
% 
% C_A_Ideal_LMMSE_S = load("C_A_Ideal_LMMSE_S.mat").C_A_Ideal_LMMSE_S;
% C_B_Ideal_LMMSE_S = load("C_B_Ideal_LMMSE_S.mat").C_B_Ideal_LMMSE_S;
% 
% C_A_Adaptive_LMMSE_S = load("C_A_Adaptive_LMMSE_S.mat").C_A_Adaptive_LMMSE_S;
% C_B_Adaptive_LMMSE_S = load("C_B_Adaptive_LMMSE_S.mat").C_B_Adaptive_LMMSE_S;


% figure(1)
% Plot_Capacity(SNR, C_A_Info, C_B_Info, C_A_Ideal_LMMSE*Bw, C_B_Ideal_LMMSE*Bw, C_A_Adaptive_LMMSE*Bw, C_B_Adaptive_LMMSE*Bw, "Multi path", Pulse_Shape)
% 
% figure(2)
% Plot_Capacity(SNR, C_A_Info_S, C_B_Info_S, C_A_Ideal_LMMSE_S*Bw, C_B_Ideal_LMMSE_S*Bw, C_A_Adaptive_LMMSE_S*Bw, C_B_Adaptive_LMMSE_S*Bw, "Single path", Pulse_Shape)