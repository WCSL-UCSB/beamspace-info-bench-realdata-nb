function Capacity = Flat_Fading_Capacity(H, noise_variance, K)

    Capacity = real(log2(det(eye(K) + H' * H / noise_variance)));
    
end