function [Capacity_Multi_Path, Capacity_Single_Path] = Capacity_Adaptive_LMMSE_Beam(SNR, Trials, N, K, W, T, D, Q, Constellation, fc, Bw, Dataset, Path_Numbers, LoS_AOA, Min_Angle, Es, Pulse_Shape, RC_T, RC_B, ISI_Factor)

    Capacity_Multi_Path = zeros(size(SNR));
    Capacity_Single_Path = zeros(size(SNR));

    % Generating hadamard matrix with size of the training sequence
    Hadmard = hadamard(T);
    
    % Keeping as many rows as the number of users to create the training sequence of each user (this is an orthogonal matrix)
    Training_Sequence = Hadmard(1:K, :);

    for t = 1:Trials
        % This function tries to find a set of K random location indices recursively in which the minimum angular
        % distance between each adjacent pair of them is more than the "Min_Angle".
        randIdcs = Find_Users(LoS_AOA, Min_Angle, K, 0);
        % ******************************** Note box *********************************
        % The last argument of "FindUsers" function should be always zero. This function finds user indices recursively, and 
        % the last argument is a counter which indicates the nubmer of recursions. So in the first call it must be zero. 
        % Using this parameter it can stop the execution when the number of recursions is larger than the whole number of locations.
        % ******************************** Note box *********************************
    
        % If it wasn't possible to find K usres with angular distance larger than Min_Angle, skip this loop and go to the second trial 
        if isnan(randIdcs)
            disp("Trial number " + num2str(t) + " has been skipped")
            disp(" ")
            continue;
        end
    
        % Index of each user's LoS path
        User_Idx = [1, 1 + cumsum(Path_Numbers(randIdcs(1:end-1)))];
    
        % selecting the K random locations of the dataset as the K users
        Data = cell2mat(Dataset(randIdcs, :));
    
        Bits = randi([0 1], D*K, Q); % The transmitted bit string of each user
        Idx = bi2de(Bits(:,:),'left-msb')+1; % Mapping index from bits to constellation points
        User_Symbols = reshape(Constellation(Idx), [K, D]); % The corresponding transmitted symbols of each user
    
        % Repeating each user's symbol sequence as many as the number of its paths.
        User_Symbols = repelem(User_Symbols, Path_Numbers(randIdcs), 1);
    
        % Repeating each user's training sequence as many as the number of its paths.
        Training_Symbols = repelem(Training_Sequence, Path_Numbers(randIdcs), 1);
    
        % This function returns the channel coefficients and the delay between antenna elements for each path.
        H = Channel_Generate(N, Data, fc, fc);
    
        % Fourier transform of channel matrix across antenna elements
        H_beam = dftmtx(N) * H / sqrt(N);

        H_beam_single = H_beam(:, User_Idx);
    
        % Finding the W largest bins in beamspace for each user
        [~, window_indices] = maxk(H_beam_single, W, 1);
    
        % Sorting the indices to be in ascending order
        window_indices = sort(window_indices);

        % This function receives path delays and the delay between antenna elements
        % and returns the delay of each path to arrive at each antenna element.
        Delays = Data(:, 1) * Bw;
    
        [Sampled_Pulse_Training, sampled_pulse_inference] = Each_Path_Samples(Delays, Delays, Pulse_Shape, Training_Symbols, User_Symbols, RC_T, RC_B, ISI_Factor);

        Signal_Training = H_beam * Sampled_Pulse_Training;

        Signal_Training_Single = H_beam_single * Sampled_Pulse_Training(User_Idx, :);

        SINR = zeros(length(SNR), K);
        SINR_single = zeros(length(SNR), K);

        for s = 1:length(SNR)

            % Noise variance for training symbols with a given SNR
            N0_Train = N * 10^(-SNR(s)/10);
    
            % Noise variance for interference symbols with a given SNR
            N0 = Es * N0_Train;
    
            % Noise matrix for training part
            Noise_Training = sqrt(N0_Train/2) * (normrnd(0,1,[N,T]) + 1i*normrnd(0,1,[N,T]));
    
            % Total received signal for training sequence in beamspace
            Y_Training = Signal_Training + Noise_Training;

            Y_Training_Single = Signal_Training_Single + Noise_Training;
            
            R = (Y_Training * Y_Training') / T;
            R_Single = (Y_Training_Single * Y_Training_Single') / T;

            for k = 1:K

                Window = zeros(W, N);
                Window(:, window_indices(:, k)') = eye(W);

                R_k = Window * R * Window';
                P_k = Window * Y_Training * Training_Symbols(User_Idx(k), :)' / T;
                C_k = R_k\P_k;
                Cov_k = C_k' * C_k;

                total_energy_k = (abs(C_k' * Window * H_beam) .^ 2) * (abs(sampled_pulse_inference) .^ 2);
                desired_k = abs(C_k' * Window * H_beam(:, User_Idx(k)) * sampled_pulse_inference(User_Idx(k), :)) .^ 2;
                interference_k = total_energy_k - desired_k;
                SINR(s, k) = sum(desired_k ./ (interference_k + Cov_k * N0 * ones(1, D))) / D;


                R_k_S = Window * R_Single * Window';
                P_k_S = Window * Y_Training_Single * Training_Symbols(User_Idx(k), :)' / T;
                C_k_S = R_k_S\P_k_S;
                Cov_k_S = C_k_S' * C_k_S;

                total_energy_k_S = (abs(C_k_S' * Window * H_beam_single) .^ 2) * (abs(sampled_pulse_inference(User_Idx, :)) .^ 2);
                desired_k_S = abs(C_k_S' * Window * H_beam_single(:, k) * sampled_pulse_inference(User_Idx(k), :)) .^ 2;
                interference_k_S = total_energy_k_S - desired_k_S;
                SINR_single(s, k) = sum(desired_k_S ./ (interference_k_S + Cov_k_S * N0 * ones(1, D))) / D;


            end
        end
        Capacity_Multi_Path = Capacity_Multi_Path + sum(log2(1+SINR), 2).'/Trials/K;
        Capacity_Single_Path = Capacity_Single_Path + sum(log2(1+SINR_single), 2).'/Trials/K;
        disp(t)
    end
    figure(3)
    plot(SNR, Capacity_Multi_Path, "LineWidth", 4, "Color","r")
    hold on
    plot(SNR, Capacity_Single_Path, "LineWidth", 2, "Color","b")
end