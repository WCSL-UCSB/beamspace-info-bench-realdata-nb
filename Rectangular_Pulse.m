function sampled_pulse = Rectangular_Pulse(symbols, delay)

    % Length of the symbols sequence
    Len = size(symbols, 2);

    % Defining sampling times
    t = 0:Len-1;

    % Shifted sampling times with delay of each path
    time = delay - t;

    % Initial zero pulse
    pulse = zeros(size(time));

    % path indices that have delay less than the length of the symbol sequence
    idx = 1:length(delay);
    idx1 = idx(floor(delay) < length(t));

    % Time indeces that should be one based on the proper path delays (less than the length of the symbol sequence)
    idx2 = floor(delay(floor(delay) < length(t)))' + 1;
    
    % Linear index based on MATLAB counting manner
    linearIdx = (idx2 - 1) * length(delay) + idx1;

    % Put ones at proper indices to create shifted delay functions
    pulse(linearIdx) = 1;
    pulse = pulse(:, any(pulse, 1));
    

    % Convolutoin of each symbol seqeunce with it's shifted delta pulse
    sampled_pulse = Row_Wise_Conv(symbols, pulse);


    % If the  "RowWise_Conv" function returned nan
    if sum(isnan(sampled_pulse)) == 1
        disp("Size mismatch!")
        return
    end

    % Keeping the proper sampling points or proper interval of the convlolution output
    sampled_pulse = sampled_pulse(:, 1 : Len);
end