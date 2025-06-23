function [Capacity_Antenna_Multi_Path, Capacity_Beam_Multi_Path, Capacity_Antenna_Single_Path, Capacity_Beam_Single_Path] = Capacity_INFO(SNR, Trials, N, K, W, fc, Bw, df, Dataset, Path_Numbers, LoS_AOA, Min_Angle, Window_Type)
    
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

        User_Path_Numbers = Path_Numbers(Rand_Idcs);
    
        % selecting the K random locations of the dataset as the K users
        Data = cell2mat(Dataset(Rand_Idcs, :));

        H_Beam_fc = dftmtx(N) * Channel_Generate(N, Data, fc, fc) / sqrt(N);
        H_Beam_fc = H_Beam_fc(:, User_Idx);

        % Finding the W largest bins in beamspace for each user
        [~, Fixed_Window] = maxk(H_Beam_fc, W, 1);
    
        % Sorting the indices to be in ascending order
        Fixed_Window = sort(Fixed_Window);

        for f = (fc - Bw/2) : df : (fc + Bw/2)

            % This function returns the channel coefficients for each path.
            H_Antenna = Channel_Generate(N, Data, fc, f);
            % Fourier transform of channel matrix across antenna elements
            H_Beam = dftmtx(N) * H_Antenna / sqrt(N);

            H_Antenna_Multi = zeros(N, K);
            H_Beam_Multi = zeros(N, K);
            for k = 1:K
                Start_Idx = User_Idx(k);
                End_Idx = User_Idx(k) + User_Path_Numbers(k) - 1;
                H_Antenna_Multi(:,k) = sum(H_Antenna(:, Start_Idx:End_Idx), 2);
                H_Beam_Multi(:,k) = sum(H_Beam(:, Start_Idx:End_Idx), 2);
            end

            H_Antenna_Single = H_Antenna(:, User_Idx);
            H_Beam_Single = H_Beam(:, User_Idx);

            % Finding the W largest bins in beamspace for each user
            [~, Floating_Window] = maxk(H_Beam_Single, W, 1);
        
            % Sorting the indices to be in ascending order
            Floating_Window = sort(Floating_Window);

            Temp_Zero_Single = zeros(size(H_Beam_Single));
            Temp_Zero_Multi = zeros(size(H_Beam_Multi));

            if Window_Type == "Fixed"
                Window_Linear_Idx = repmat((0:K-1)*N, W, 1) + Fixed_Window;
            else
                Window_Linear_Idx = repmat((0:K-1)*N, W, 1) + Floating_Window;
            end

            Temp_Zero_Single(Window_Linear_Idx) = H_Beam_Single(Window_Linear_Idx);
            Temp_Zero_Multi(Window_Linear_Idx) = H_Beam_Multi(Window_Linear_Idx);

            H_Beam_Single_Windowed = Temp_Zero_Single(any(Temp_Zero_Single, 2), :);
            H_Beam_Multi_Windowed = Temp_Zero_Multi(any(Temp_Zero_Single, 2), :);
            
            for s = 1:length(SNR)

                % Noise variance for interference symbols with a given SNR
                N0 = N * 10 ^ (-SNR(s) / 10);

                Capacity_Antenna_Multi_Path(s) = Capacity_Antenna_Multi_Path(s) + Flat_Fading_Capacity(H_Antenna_Multi, N0, K) * df / K / Trials;
                Capacity_Antenna_Single_Path(s) = Capacity_Antenna_Single_Path(s) + Flat_Fading_Capacity(H_Antenna_Single, N0, K) * df / K / Trials;

                Capacity_Beam_Multi_Path(s) = Capacity_Beam_Multi_Path(s) + Flat_Fading_Capacity(H_Beam_Multi_Windowed, N0, K) * df / K / Trials;
                Capacity_Beam_Single_Path(s) = Capacity_Beam_Single_Path(s) + Flat_Fading_Capacity(H_Beam_Single_Windowed, N0, K) * df / K / Trials;

            end
        end
    end
end