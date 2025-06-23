function Plot_Capacity(SNR, C_A_Info, C_B_Info, C_A_Ideal, C_B_Ideal, C_A_Adaptive, C_B_Adaptive, Scenario, Pulse_Shape)
    
    plot(SNR, C_A_Info, "LineWidth", 3, "DisplayName", "Benchmark I", "Color", [0, 0.4470, 0.7410])
    hold on
    plot(SNR, C_B_Info, "LineWidth", 3, "DisplayName", "Benchmark II", "Color", [0.8500, 0.3250, 0.0980])
    hold on
    plot(SNR, C_A_Ideal, "LineWidth", 3, "DisplayName", "Benchmark III", "Color", [0.9290, 0.6940, 0.1250])
    hold on
    plot(SNR, C_B_Ideal, "LineWidth", 3, "DisplayName", "Benchmark IV", "Color", [0.4940, 0.1840, 0.5560])
    hold on
    plot(SNR, C_A_Adaptive, "LineWidth", 3, "DisplayName", "Adaptive LMMSE - Antenna Space", "Color", [0.4660, 0.6740, 0.1880])
    hold on
    plot(SNR, C_B_Adaptive, "LineWidth", 3, "DisplayName", "Adaptive LMMSE - Windowed Beamspace", "Color", [0.3010, 0.7450, 0.9330])
    % title(Scenario + " secenario (" + Pulse_Shape + ")", "FontSize", 40, "Color", "k")
    % title(Scenario + " scenario", "FontSize", 60, "Color", "k")
    grid on
    legend("FontSize", 28, "Location", "northwest", "FontName", "Times New Roman")
    xticks(SNR)
    ax = gca;
    ax.GridLineWidth = 2;
    ax.XAxis.FontSize = 30;
    ax.YAxis.FontSize = 30;
    xlabel("Beamformed SNR", "FontSize",30, "FontWeight", "bold")
    ylabel("Spectral Efficiency", "FontSize", 30, "FontWeight", "bold")
    xsecondarylabel("dB")
    ysecondarylabel("Gbits/sec")
end
