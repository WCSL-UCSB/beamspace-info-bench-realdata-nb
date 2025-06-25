# Capacity Benchmarks for Massive mmWave MU-MIMO

**Windowed-Beamspace vs. Antenna-Space Processing**

Fully-digital mmWave arrays with dozens (even hundreds) of antennas unlock enormous capacity gains, but only if computational complexity can be tamed.
This codebase quantifies the capacity trade‑offs of low‑complexity **windowed beamspace** detection versus conventional **antenna‑space** processing, 
using **28 GHz urban channel measurements [1]**.

---

## Quick Start

```matlab
% 1. Clone the repo and open it in MATLAB
addpath(genpath(pwd));

% 2. Download the 28 GHz Downtown Boulder dataset
%    ↳ https://nextg.nist.gov/submissions/112   (accept the Data‑Sharing Agreement)
%    Extract the archive so that the MPC *.mat files live at:
%    <repo>/NISTDowntownMeasurements/measurements/Boulder_Downtown/Measurements/...
%         BoulderDowntown_28GHz_LOS/MPC files
%    (Config.m auto‑detects this relative path; edit params.MPC.path there if you
%     choose a different location.)

% 3. Run the driver script
run main.m
```
You will see progress messages for every trial and two figures, multi‑path and single‑path capacity curve once the Monte Carlo run finishes.

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
| **`Plot_Capacity.m`**            | Plotting (fonts, colours, legend placement).                                                                    |

---

## Data Set

* **Source** 28 GHz channel‑sounding campaign (downtown Boulder, CO; 50 receiver snapshots).
* **Format expected** MATLAB `.mat` “MPC” files, one per location.
* **Pre‑processing** `Make_Data.m` rotates AoAs to the array broadside, normalises delays to the dominant path, and discards paths whose AoA ∉ \[−90°, 90°].

> *To try a different measurement set:*
> Update `Make_Data.m`. 

---

## Reproducing the Paper Figures

1. Set `Trials = 50` and `K = 16`.

2. Run the driver:

* `Window_Type = "Fixed"`: frequency‑independent beamspace window.
* `Window_Type = "Floating"`: recomputed per sub‑carrier.

The default parameters (`N = 64`, `W = 4`, `BW = 1 GHz`, ...) match Figures 4a/4b of the paper.

---

## Requirements
* Signal Processing Toolbox (for `hadamard`, `toeplitz`, …)

---

## Citing This Work

```bibtex
@INPROCEEDINGS{10942628,
  author={Cebeci, Canan and Noroozi, Oveys Delafrooz and Madhow, Upamanyu},
  booktitle={2024 58th Asilomar Conference on Signals, Systems, and Computers}, 
  title={Scaling mmWave MU-MIMO: Information-Theoretic Guidance Using Real-World Data}, 
  year={2024},
  volume={},
  number={},
  pages={1620-1624},
  keywords={Multiuser detection;Dimensionality reduction;Training;Spectral efficiency;Signal processing algorithms;Benchmark testing;Radiofrequency integrated circuits;Millimeter wave communication;Information theory;Antenna arrays;mmWave;MU-MIMO;beamspace processing},
  doi={10.1109/IEEECONF60004.2024.10942628}}

```

---

## Contact

For questions, suggestions, or requests to use the code email `{oveys}{ccebeci}@ucsb.edu`.

---

## Reference for the channel measurement dataset

[1] R. Charbonnier, C. Lai, T. Tenoux, D. Caudill, G. Gougeon, J. Senic, C. Gentile, Y. Corre, J. Chuang, and N. Golmie, 
“Calibration of ray-tracing with diffuse scattering against 28-GHz directional urban channel measurements,” 
IEEE Transactions on Vehicular Technology, vol. 69, no. 12, pp. 14 264–14 276, 2020.

---

## Acknowledgement

This work was supported in part by the Center for Ubiquitous Connectivity (CUbiC), 
sponsored by Semiconductor Research Corporation (SRC) and Defense Advanced Research Projects Agency (DARPA) 
under the JUMP 2.0 program, and in part by the National Science Foundation under grant CNS-21633.
