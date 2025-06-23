function sampled_pulse = RaisedCos_Pulse(ISI_factor, symbols, delay, RC_T, RC_B)

    % Length of the symbols sequence
    Len = size(symbols, 2);
    
    % Pulse interval based on the number of ISI at each sampling time (in sampling units)
    t =  -ISI_factor:ISI_factor;

    % Shifted pulse interval with delay of each path
    time = delay -t;

    % Calculating the raised cosine values at each sampling time
    pulse = RC(time, RC_T, RC_B);

    % Convolutoin of each symbol seqeunce with it's shifted pulse
    sampled_pulse = Row_Wise_Conv(symbols, pulse);

    % If the  "RowWise_Conv" function returned nan
    if sum(isnan(sampled_pulse)) == 1
        disp("Size mismatch!")
        return
    end

    % Keeping the proper sampling points or proper interval of the convlolution output
    sampled_pulse = sampled_pulse(:, ISI_factor + 1 : ISI_factor + Len);

end