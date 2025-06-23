function start = StartSampling(user_idx, delays, tau, N, all_paths_number)

    idx = user_idx + (N-1) * all_paths_number * sign(1-heaviside(tau(user_idx)'));
    start = round(max(delays(idx)));
end