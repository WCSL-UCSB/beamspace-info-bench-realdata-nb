function [Capacity_Antenna_Multi_Path, Capacity_Beam_Multi_Path, Capacity_Antenna_Single_Path, Capacity_Beam_Single_Path] = Capacity_Adaptive_LMMSE(SNR, Trials, N, K, W, T_A, T_B, D, Q, Constellation, fc, Bw, Dataset, Path_Numbers, LoS_AOA, Min_Angle, Es, Pulse_Shape, RC_T, RC_B, ISI_Factor)

    Capacity_Antenna_Multi_Path = zeros(size(SNR));
    Capacity_Beam_Multi_Path = zeros(size(SNR));

    Capacity_Antenna_Single_Path = zeros(size(SNR));
    Capacity_Beam_Single_Path = zeros(size(SNR));

    % Generating hadamard matrix with size of the training sequence
    Hadmard_A = hadamard(T_A);
    Hadmard_B = hadamard(T_B);

    % Keeping as many rows as the number of users to create the training sequence of each user (this is an orthogonal matrix)
    Training_Sequence_A = Hadmard_A(1:K, :);
    Training_Sequence_B = Hadmard_B(1:K, :);

    for t = 1:Trials
        % This function tries to find a set of K random location indices recursively in which the minimum angular
        % distance between each adjacent pair of them is more than the "Min_Angle".
        RandIdcs = Find_Users(LoS_AOA, Min_Angle, K, 0);
        % ******************************** Note box *********************************
        % The last argument of "FindUsers" function should be always zero. This function finds user indices recursively, and 
        % the last argument is a counter which indicates the nubmer of recursions. So in the first call it must be zero. 
        % Using this parameter it can stop the execution when the number of recursions is larger than the whole number of locations.
        % ******************************** Note box *********************************
    
        % If it wasn't possible to find K usres with angular distance larger than Min_Angle, skip this loop and go to the second trial 
        if isnan(RandIdcs)
            disp("Trial number " + num2str(t) + " has been skipped")
            disp(" ")
            continue;
        end
    
        % Index of each user's LoS path
        User_Idx = [1, 1 + cumsum(Path_Numbers(RandIdcs(1:end-1)))];
    
        % selecting the K random locations of the dataset as the K users
        Data = cell2mat(Dataset(RandIdcs, :));

        All_Paths_Numbers = sum(Path_Numbers(RandIdcs));
    
        % Bits = randi([0 1], D*K, Q); % The transmitted bit string of each user
        % Idx = bi2de(Bits(:,:),'left-msb')+1; % Mapping index from bits to constellation points
        % User_Symbols = reshape(Constellation(Idx), [K, D]); % The corresponding transmitted symbols of each user
        % 
        % % Repeating each user's symbol sequence as many as the number of its paths.
        % User_Symbols = repelem(User_Symbols, Path_Numbers(RandIdcs), 1);

        Bits = randi([0 1], D*All_Paths_Numbers, Q); % The transmitted bit string of each user
        Idx = bi2de(Bits(:,:),'left-msb')+1; % Mapping index from bits to constellation points
        User_Symbols = reshape(Constellation(Idx), [All_Paths_Numbers, D]); % The corresponding transmitted symbols of each user
    
        % Repeating each user's training sequence as many as the number of its paths.
        Training_Symbols_A = repelem(Training_Sequence_A, Path_Numbers(RandIdcs), 1);
        Training_Symbols_B = repelem(Training_Sequence_B, Path_Numbers(RandIdcs), 1);

        % This function returns the channel coefficients and the delay between antenna elements for each path.
        H_Antenna = Channel_Generate(N, Data, fc, fc);

        H_Antenna_Single = H_Antenna(:, User_Idx);

        % Fourier transform of channel matrix across antenna elements
        H_Beam = dftmtx(N) * H_Antenna / sqrt(N);

        H_Beam_Single = H_Beam(:, User_Idx);
    
        % Finding the W largest bins in beamspace for each user
        [~, window_indices] = maxk(H_Beam_Single, W, 1);
    
        % Sorting the indices to be in ascending order
        window_indices = sort(window_indices);

        % This function receives path delays and the delay between antenna elements
        % and returns the delay of each path to arrive at each antenna element.
        Delays = Data(:, 1) * Bw;
        Inference_Delays = floor(Delays + 1) - floor(Delays);
    
        [Sampled_Pulse_Training_A, sampled_pulse_inference_A] = Each_Path_Samples(Delays, Inference_Delays, Pulse_Shape, Training_Symbols_A, User_Symbols, RC_T, RC_B, ISI_Factor);
        [Sampled_Pulse_Training_B, sampled_pulse_inference_B] = Each_Path_Samples(Delays, Inference_Delays, Pulse_Shape, Training_Symbols_B, User_Symbols, RC_T, RC_B, ISI_Factor);

        Signal_Training_A = H_Antenna * Sampled_Pulse_Training_A;
        Signal_Training_B = H_Beam * Sampled_Pulse_Training_B;

        Signal_Training_Single_A = H_Antenna_Single * Sampled_Pulse_Training_A(User_Idx, :);
        Signal_Training_Single_B = H_Beam_Single * Sampled_Pulse_Training_B(User_Idx, :);

        Average_Es_A = round(mean(abs(sampled_pulse_inference_A) .^ 2, 2));
        Average_Es_B = round(mean(abs(sampled_pulse_inference_B) .^ 2, 2));

        SINR_A = zeros(length(SNR), K);
        SINR_B = zeros(length(SNR), K);

        SINR_Single_A = zeros(length(SNR), K);
        SINR_Single_B = zeros(length(SNR), K);

        for s = 1:length(SNR)

            % Noise variance for training symbols with a given SNR
            N0_Train = N * 10^(-SNR(s)/10);
    
            % Noise variance for interference symbols with a given SNR
            N0 = Es * N0_Train;
    
            % Noise matrix for training part
            Noise_Training_A = sqrt(N0_Train/2) * (normrnd(0,1,[N,T_A]) + 1i*normrnd(0,1,[N,T_A]));
            Noise_Training_B = sqrt(N0_Train/2) * (normrnd(0,1,[N,T_B]) + 1i*normrnd(0,1,[N,T_B]));

            % Total received signal for training sequence in beamspace
            Y_Training_A = Signal_Training_A + Noise_Training_A;
            Y_Training_B = Signal_Training_B + Noise_Training_B;

            Y_Training_Single_A = Signal_Training_Single_A + Noise_Training_A;
            Y_Training_Single_B = Signal_Training_Single_B + Noise_Training_B;

            R_A = (Y_Training_A * Y_Training_A') / T_A;
            R_S_A = (Y_Training_Single_A * Y_Training_Single_A') / T_A;
            R_B = (Y_Training_B * Y_Training_B') / T_B;
            R_S_B = (Y_Training_Single_B * Y_Training_Single_B') / T_B;

            for k = 1:K

                P_k_A = Y_Training_A * Training_Symbols_A(User_Idx(k), :)' / T_A;
                C_k_A = R_A\P_k_A;
                Cov_k_A = C_k_A' * C_k_A;

                total_energy_k_A = (abs(C_k_A' * H_Antenna) .^ 2) * Average_Es_A;
                desired_k_A = (abs(C_k_A' * H_Antenna(:, User_Idx(k))) .^ 2 ) * Average_Es_A(User_Idx(k));
                interference_k_A = total_energy_k_A - desired_k_A;
                SINR_A(s, k) = desired_k_A ./ (interference_k_A + Cov_k_A * N0);

% ******************************************************************************************************************
                Window = zeros(W, N);
                Window(:, window_indices(:, k)') = eye(W);

                R_k_B = Window * R_B * Window';
                P_k_B = Window * Y_Training_B * Training_Symbols_B(User_Idx(k), :)' / T_B;
                C_k_B = R_k_B\P_k_B;
                Cov_k_B = C_k_B' * C_k_B;

                total_energy_k_B = (abs(C_k_B' * Window * H_Beam) .^ 2) * Average_Es_B;
                desired_k_B = (abs(C_k_B' * Window * H_Beam(:, User_Idx(k))) .^ 2) * Average_Es_B(User_Idx(k));
                interference_k_B = total_energy_k_B - desired_k_B;
                SINR_B(s, k) = desired_k_B ./ (interference_k_B + Cov_k_B * N0);

% ******************************************************************************************************************

                P_k_S_A = Y_Training_Single_A * Training_Symbols_A(User_Idx(k), :)' / T_A;
                C_k_S_A = R_S_A\P_k_S_A;
                Cov_k_S_A = C_k_S_A' * C_k_S_A;

                total_energy_k_S = (abs(C_k_S_A' * H_Antenna_Single) .^ 2) * Average_Es_A(User_Idx);
                desired_k_S = (abs(C_k_S_A' * H_Antenna_Single(:, k)) .^ 2) * Average_Es_A(User_Idx(k));
                interference_k_S = total_energy_k_S - desired_k_S;
                SINR_Single_A(s, k) = desired_k_S ./ (interference_k_S + Cov_k_S_A * N0);

% ******************************************************************************************************************

                R_k_S_B = Window * R_S_B * Window';
                P_k_S_B = Window * Y_Training_Single_B * Training_Symbols_B(User_Idx(k), :)' / T_B;
                C_k_S_B = R_k_S_B\P_k_S_B;
                Cov_k_S_B = C_k_S_B' * C_k_S_B;

                total_energy_k_S_B = (abs(C_k_S_B' * Window * H_Beam_Single) .^ 2) * Average_Es_B(User_Idx);
                desired_k_S_B = (abs(C_k_S_B' * Window * H_Beam_Single(:, k)) .^ 2) * Average_Es_B(User_Idx(k));
                interference_k_S_B = total_energy_k_S_B - desired_k_S_B;
                SINR_Single_B(s, k) = desired_k_S_B ./ (interference_k_S_B + Cov_k_S_B * N0);

            end
        end
        Capacity_Antenna_Multi_Path = Capacity_Antenna_Multi_Path + sum(log2(1+SINR_A), 2).'/Trials/K;
        Capacity_Beam_Multi_Path = Capacity_Beam_Multi_Path + sum(log2(1+SINR_B), 2).'/Trials/K;

        Capacity_Antenna_Single_Path = Capacity_Antenna_Single_Path + sum(log2(1+SINR_Single_A), 2).'/Trials/K;
        Capacity_Beam_Single_Path = Capacity_Beam_Single_Path + sum(log2(1+SINR_Single_B), 2).'/Trials/K;

        fprintf('Trial %d is completed, %d trials left.\n', t, Trials - t);
    end
end