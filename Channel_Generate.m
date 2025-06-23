function H = Channel_Generate(N, data, fc, f)
    

    n=(0:N-1);

    delay_relative = data(:, 1);
    
    path_loss_relative = data(:, 4);
    
    
    aoa_azimuth = data(:,2);
    
    amplitude_path = sqrt(db2pow(path_loss_relative));

    theta = aoa_azimuth * pi/180;

    spatial_freq = -pi * (f/fc) * sin(theta);

    array_response = (exp(1i * n .* spatial_freq)).';
    complex_gain = amplitude_path .* exp(-1i * 2*pi * f * delay_relative);
    % complex_gain = amplitude_path;
    H = array_response * diag(complex_gain);
