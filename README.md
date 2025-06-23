# Capacity Benchmarks for Massive mmWave MU-MIMO

**Windowed-Beamspace vs. Antenna-Space Processing**

Fully-digital mmWave arrays with dozens (even hundreds) of antennas unlock enormous spatial‑multiplexing gains—but only if baseband complexity can be tamed.
This codebase quantifies the price‑performance trade‑offs of low‑complexity **windowed beamspace** detection versus conventional **antenna‑space** processing, using **real 28 GHz urban channel measurements** and the analytic benchmarks introduced in our 2025 Asilomar paper.

---

## Quick Start

```matlab
% 1. Clone the repo and open it in MATLAB
addpath(genpath(pwd));

% 2. Point to the mmWave MPC data (download separately)
Path_MPC = "/path/to/MPC/files";

% 3. Run the driver script
run main_capacity_benchmarks.m
```

You will see progress messages for each trial, then the capacity curves.

---

## Repository Map

| File / Folder                    | Purpose                                                                                                                           |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **`main_capacity_benchmarks.m`** | Entry‑point: sets simulation parameters, loads the measurement data set, calls the capacity functions, and generates the figures. |
| **`Capacity_Ideal_LMMSE.m`**     | Benchmarks III‑IV: ideal‑CSI LMMSE (antenna‑space & beamspace).                                                                   |
| **`Capacity_Adaptive_LMMSE.m`**  | Adaptive windowed‑beamspace LMMSE with short training.                                                                            |
| **`Capacity_INFO.m`**            | Information‑theoretic upper bounds (Benchmarks I‑II).                                                                             |
| **`Channel_Generate.m`**         | Builds the channel matrix \$H(f)\$ from measured path delays, gains and AoAs.                                                     |
| **`Find_Users.m`**               | Selects **K** users with at least the specified angular separation.                                                               |
| **Pulse utilities**              | `Each_Path_Samples.m`, `RaisedCos_Pulse.m`, `Rectangular_Pulse.m`, etc.                                                           |
| **`Plot_Capacity.m`**            | Publication‑ready plotting (fonts, colours, legend placement).                                                                    |

---

## Data Set

* **Source** 28 GHz channel‑sounding campaign (downtown Boulder, CO; 50 receiver snapshots).
* **Format expected** MATLAB `.mat` “MPC” files, one per location.
* **Pre‑processing** `Make_Data.m` rotates AoAs to the array broadside, normalises delays to the dominant path, and discards paths whose AoA ∉ \[−90°, 90°].

> *Want to try a different measurement set?*
> Update `Make_Data.m`. 

---

## Reproducing the Paper Figures

1. Set `Trials = 50` and `K = 16` (adjust down if RAM is limited).
2. Run the driver twice:

* `Window_Type = "Fixed"` – frequency‑independent beamspace window.
* `Window_Type = "Floating"` – recomputed per sub‑carrier.
  3. Cached `.mat` files let you re‑run only the plotting block to overlay scenarios.

The default parameters (`N = 64`, `W = 4`, `BW = 1 GHz`, …) match Figures 4a/4b of the paper.

---

## Requirements
* Signal Processing Toolbox (for `hadamard`, `toeplitz`, …)

---

## Citing This Work

```bibtex
@inproceedings{cebeci2025scaling,
  title     = {Scaling mmWave MU-MIMO: Information-Theoretic Guidance using Real-World Data},
  author    = {Canan Cebeci and Oveys Delafrooz Noroozi and Upamanyu Madhow},
  booktitle = {Proc. IEEE Asilomar Conf. Signals, Systems and Computers},
  year      = {2025}
}
```

---

## Contact

For questions, suggestions, or requests to use the code email `{ccebeci}{oveys}@ucsb.edu`.

---
## Acknowledgement

This work was supported in part by the Center for Ubiquitous Connectivity (CUbiC), 
sponsored by Semiconductor Research Corporation (SRC) and Defense Advanced Research Projects Agency (DARPA) 
under the JUMP 2.0 program, and in part by the National Science Foundation under grant CNS-21633.
