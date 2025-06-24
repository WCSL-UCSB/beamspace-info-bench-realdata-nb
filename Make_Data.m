function [dataset, path_numbers, LoS_AoAs]= Make_Data(path_MPC, locations, sector, reference_rotation)

    % It's gonna be our final output
    data = [];

    % It's gonna show the number of paths that each loacation has (it's not complete yet)
    path_numbers = [];

    % It's gonna show the angle of arrival of each location's Los path  (it's not complete yet)
    LoS_AoAs = [];
    
    for l = locations

        % Loading the l'th location data
        location_data = load(path_MPC + "/" + l);

        % Using Sector 1 of l'th location data
        array = getfield(location_data.MPC_params, sector);


        % Rotating the azimuth angles to be respect to the broadside (in degree)
        array(:, 2) = mod(array(:,2) + reference_rotation, 360);

        % Converting the angle of arrivals in the range of [270, 360] to the range of [-90, 0], then the total range is [-90, 90]
        array(array(:, 2) >= 270, 2) = array(array(:, 2) >= 270, 2) - 360;

        % Finding the minimum delay path and considering it as LoS
        [~, min_idx] = min(array(:,1));

        % Calculating the delay of each path respect to the LoS (in ns)
        % array(:,1) = array(:,1) - floor(array(min_idx, 1));

        array(:,1) = array(:,1) - floor(array(min_idx, 1));

        % Calculating the strength of each path respect to the LoS (in dB)
        array(:,4) = array(min_idx, 4) - array(:,4);

        % LoS path's angle of arrival
        LoS_AoA = array(min_idx, 2);

        % If the LoS path has proper angle of arrival
        if (LoS_AoA <= 90) || (LoS_AoA >= -90)

            % Keeping the paths that have proper angle of arrival
            idx1 = array(:, 2) >= -90; 
            idx2 = array(:, 2) <= 90;
            array = array(and(idx1, idx2), :);

            % Inserting the prepared loacation data into the final dataset
            data = [data; array];
    
            % Saving the number of proper paths of each loacation data
            path_numbers = [path_numbers, length(array)];

            % Saving the LoS angle of arrivals
            LoS_AoAs = [LoS_AoAs, LoS_AoA];
        end
    end
    
    % Converting the dataset matrix into a cell that each element of that contains one location's data
    dataset = mat2cell(data, path_numbers);

end