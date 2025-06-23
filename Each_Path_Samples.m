function [sampled_pulse_training, sampled_pulse_inference] = Each_Path_Samples(delays, inference_delays, pulse_shape, training_symbols, user_symbols, RC_T, RC_B, ISI_factor)

    % Sampled values of each path at each sampling points based on the pulse shape and the symbols sequence
    if pulse_shape == "Rect"
        sampled_pulse_training = Rectangular_Pulse(training_symbols, delays);
        sampled_pulse_inference = Rectangular_Pulse(user_symbols, inference_delays);
    elseif pulse_shape == "RC"
        sampled_pulse_training = RaisedCos_Pulse(ISI_factor, training_symbols, delays, RC_T, RC_B);
        sampled_pulse_inference = RaisedCos_Pulse(ISI_factor, user_symbols, inference_delays, RC_T, RC_B);
    end

end