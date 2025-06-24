% MPC Data's path on your local device
% Dynamically get path information
mainScriptPath = mfilename('fullpath');
[params.folderPath, ~, ~] = fileparts(mainScriptPath); % Extract the folder path

params.MPC.path = fullfile(params.folderPath, "NISTDowntownMeasurements", "measurements", ...
                    "Boulder_Downtown", "Measurements", ...
                    "BoulderDowntown_28GHz_LOS", "MPC files");
params.MPC.delayColumn = 1;
params.MPC.azimuthColumn = 2;
params.MPC.elevationColumn = 3;
params.MPC.pathlossColumn = 4;
params.MPC.sectorNumber = 'sector01';

% Name of each location's data based on the dateset
params.Locations = "MPC" + ["1581", "1582", "1583", "1584","1585","1586","1587","1588","1589",...
             "1590", "1591", "1592", "1593","1594","1595","1596","1597","1598","1599",...
             "1600", "1601", "1602", "1603","1604","2314","2315","2316","2317","2318",...
             "2319","2320","2321","2322","2323","2324","2325","2326", "2327", ...
             "2328","2329","2330","2331","2332","2333","2334","2335", "2336", ...
             "2337","2338","2339"] + ".mat";

% ******************************** Basic parameters ********************************

params.Reference_Rotation = 12.5288; % Angle differnece between azimuth reference (0 degree) and broadside (in degree)

params.Sector = "sector01"; % The sector that we want to use

params.N = 64; % Number of antennas

params.K= 16; % umber of Users

params.SNR = -5:1:10; % SNR range (in dB)

params.Train_Coef = 10;

params.D = 50; % Number of inference symbols

params.W = 4; % Beamspace of window size

params.T_A = params.Train_Coef * params.N; % Number of training symbols
params.T_B = params.Train_Coef * params.W;

params.fc = 28; % Carrier frequency (in GHz)

params.Bw = 1; % Band width (in GHz)

params.df = 0.1;

params.Min_Angle = 0; % Minimum angular distance between adjacent users (in degree)

params.RC_T = 1; % Raised cosine pulse symbol rate factor

params.RC_B = 1; % Raised cosine roll-off factor

params.ISI_Factor = 10; % The number of symbols that interfere with the desired symbol

params.Trials = 50; % Number of trials

% ******************************** Simulation parameters ********************************

params.Constellation = [-1-1i, -1+1i, 1-1i, 1+1i ].'; % Constellation points(QPSK)

params.Es = mean(abs(params.Constellation).^2); % Average energy of the symbols

params.Q = log2(length(params.Constellation)); % Number of bits per symbol

params.Pulse_Shape = "Rect";

params.Window_Type = "Floating";
