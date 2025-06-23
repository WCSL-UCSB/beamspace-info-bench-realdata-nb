function idx = Find_Users(angles, min_angle, K, Try)

    L = length(angles); % Number of locations

    Remains = 1:L; % Remaining location indices 

    idx = []; % Proper user indices (It's not completed)

    % If the number of recurssions is less than whole number of locations
    if Try <= L
        % While we havn't found K users and the number of recurssions doesn't exeeded
        while length(idx) < K && ~sum(isnan(idx))
            % New random location index from the remaining locations
            r = randsample(Remains, 1);

            % For the second and beyond iterations, the new random location should be compatible with the previous ones. 
            if length(idx) >= 1

                % While the angular distance between the new random picked location is larger than at least one of the previous locations
                while sum(abs(angles(idx) - angles(r)) < min_angle) > 0

                    % Remove the new random picked location from the remaining locations
                    Remains = Remains(Remains ~= r);

                    % If there was some remaining locations
                    if ~isempty(Remains)

                        % Pick another random location
                        r = randsample(Remains, 1);

                    % Else, break the while
                    else
                        break;
                    end
                end
            end

            % Adding the selected location index to the final location indices 
            idx = [idx, r];

            % Remove the new random picked location from the remaining locations
            Remains = Remains(Remains ~= r);

            % If there is no remaining locations while we havn't picked K loacations
            if isempty(Remains) && length(idx) < K

                % Increase the recurssion counter
                Try = Try+1;

                % Try to find the K proper locations with different first random location
                idx = Find_Users(angles, min_angle, K, Try);
            end
        end
    else
        % When the number of recurssions exeeds the number of locations.
        disp("It's not possible to find " + num2str(K) + " users with angular distance larger than " + num2str(min_angle) + " degrees")
        
        % Return nan as a flag
        idx = nan;
    end
end