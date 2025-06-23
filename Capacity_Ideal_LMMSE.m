function [Capacity_Antenna_Multi_Path, Capacity_Beam_Multi_Path, Capacity_Antenna_Single_Path, Capacity_Beam_Single_Path] = Capacity_Ideal_LMMSE(SNR, Trials, N, K, W, fc, Dataset, Path_Numbers, LoS_AOA, Min_Angle, Es)

    % generate channel matrix
    Capacity_Antenna_Multi_Path = zeros(size(SNR));
    Capacity_Beam_Multi_Path = zeros(size(SNR));
    Capacity_Antenna_Single_Path = zeros(size(SNR));
    Capacity_Beam_Single_Path = zeros(size(SNR));
    
    for t = 1:Trials
    
        % This function tries to find a set of K random location indices recursively in which the minimum angular
        % distance between each adjacent pair of them is more than the "Min_Angle".
        Rand_Idcs = Find_Users(LoS_AOA, Min_Angle, K, 0);

        % ******************************** Note box *********************************
        % The last argument of "FindUsers" function should be always zero. This function finds user indices recursively, and 
        % the last argument is a counter which indicates the nubmer of recursions. So in the first call it must be zero. 
        % Using this parameter it can stop the execution when the number of recursions is larger than the whole number of locations.
        % ******************************** Note box *********************************
    
        % If it wasn't possible to find K usres with angular distance larger than Min_Angle, skip this loop and go to the second trial 
        if isnan(Rand_Idcs)
            disp("Trial number " + num2str(t) + " has been skipped")
            disp(" ")
            continue;
        end
    
        % Index of each user's LoS path
        User_Idx = [1, 1 + cumsum(Path_Numbers(Rand_Idcs(1:end-1)))];
    
        % selecting the K random locations of the dataset as the K users
        Data = cell2mat(Dataset(Rand_Idcs, :));
    
        H_Antenna = Channel_Generate(N, Data, fc, fc);
        H_Antenna_Single = H_Antenna(:, User_Idx);
    
        H_Beam = dftmtx(N) * H_Antenna / sqrt(N);
        H_Beam_Single = H_Beam(:, User_Idx);

        [~, Window_Idx] = maxk(H_Beam_Single, W, 1);
        Window_Idx = sort(Window_Idx);
    
        SINR_Antenna = zeros(size(SNR, 2), K);
        SINR_Beam = zeros(size(SNR, 2), K);

        SINR_Antenna_Single = zeros(size(SNR, 2), K);
        SINR_Beam_Single = zeros(size(SNR, 2), K);
    
        for s=1:length(SNR)
    
            N0 = Es * N * 10^(-SNR(s)/10);
            R_A = Es * (H_Antenna * H_Antenna') + eye(N) * N0;
            R_A_S = Es * (H_Antenna_Single * H_Antenna_Single') + eye(N) * N0;
            R_B = Es * (H_Beam * H_Beam') + eye(N) * N0;
            R_B_S = Es * (H_Beam_Single * H_Beam_Single') + eye(N) * N0;
            
            for k = 1:K
                P_k_A = Es * H_Antenna(:, User_Idx(k));
                C_k_A = R_A\P_k_A;
                CH_A = C_k_A' * H_Antenna;
                Desired_A = Es * abs(CH_A(User_Idx(k))) .^ 2;
                Interference_A = Es * sum(abs(CH_A).^2) - Desired_A;
                Cov_A = C_k_A' * C_k_A;
                Noise_Interference_A = Interference_A + N0 * Cov_A;
                SINR_Antenna(s, k) = Desired_A ./ Noise_Interference_A;

                P_k_A_S = Es * H_Antenna_Single(:, k);
                C_k_S = R_A_S\P_k_A_S;
                CH_A_S = C_k_S' * H_Antenna_Single;
                Desired_A_S = Es * abs(CH_A_S(k)) .^ 2;
                Interference_A_S = Es * sum(abs(CH_A_S).^2) - Desired_A_S;
                Cov_S_A = C_k_S' * C_k_S;
                Noise_Interference_A = Interference_A_S + N0 * Cov_S_A;
                SINR_Antenna_Single(s, k) = Desired_A_S ./ Noise_Interference_A;


                Window = zeros(W, N);
                Window(:, Window_Idx(:, k)') = eye(W);
                H_Windowed = Window * H_Beam;
    
                P_k_B = Es * H_Windowed(:, User_Idx(k));
                R_k_B = Window * R_B * Window';
                C_k_B = R_k_B\P_k_B;
    
                CH_B = C_k_B' * H_Windowed;
                Desired_B = Es * abs(CH_B(User_Idx(k))) .^ 2;
                Interference_B = Es * sum(abs(CH_B).^2) - Desired_B;
                Cov_B = C_k_B' * C_k_B;
                Noise_Interference_B = Interference_B + N0 * Cov_B;
                SINR_Beam(s, k) = Desired_A ./ Noise_Interference_B;


                H_Windowed_Single = Window * H_Beam_Single;
                P_k_B_S = Es * H_Windowed_Single(:, k);
                R_k_B_S = Window * R_B_S * Window';
                C_k_B_S = R_k_B_S\P_k_B_S;
    
                CH_B_S = C_k_B_S' * H_Windowed_Single;
                Desired_B_S = Es * abs(CH_B_S(k)) .^ 2;
                Interference_B_S = Es * sum(abs(CH_B_S).^2) - Desired_B_S;
                Cov_B_S = C_k_B_S' * C_k_B_S;
                Noise_Interference_B_S = Interference_B_S + N0 * Cov_B_S;
                SINR_Beam_Single(s, k) = Desired_B_S ./ Noise_Interference_B_S;
            end
        end
    
        Capacity_Antenna_Multi_Path = Capacity_Antenna_Multi_Path + sum(log2(1+SINR_Antenna), 2).'/Trials/K;
        Capacity_Beam_Multi_Path = Capacity_Beam_Multi_Path + sum(log2(1+SINR_Beam), 2).'/Trials/K;

        Capacity_Antenna_Single_Path = Capacity_Antenna_Single_Path + sum(log2(1+SINR_Antenna_Single), 2).'/Trials/K;
        Capacity_Beam_Single_Path = Capacity_Beam_Single_Path + sum(log2(1+SINR_Beam_Single), 2).'/Trials/K;
    end
end










