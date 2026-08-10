# 💧 Purification Water Process Algorithm (PWPA)

**Physics-Grounded Optimization via Interpretable Process Mapping**

> A novel metaheuristic optimizer that **directly maps** the three canonical stages of industrial water purification—**Sedimentation**, **Filtration**, and **Final Purification**—into transparent computational search operators.

---

## 📄 Publication

| | |
|---|---|
| **Journal** | *Royal Society Open Science*, Vol. 13, 251929 (2026) |
| **DOI** | [10.1098/rsos.251929](https://doi.org/10.1098/rsos.251929) |
| **Zenodo Archive** | [10.5281/zenodo.17237555](https://doi.org/10.5281/zenodo.17237555) |
| **Author** | Mohammad Hossein Safarpour |
| **Affiliation** | Department of Mathematics and Computer Science, Islamic Azad University, Arak, Iran |

---

## 🎯 Key Results

| Benchmark | Result |
|---|---|
| 1000-D Schwefel | Global optimum found, s.d. ≈ 105 (only algorithm to achieve this) |
| MNIST SVM Tuning | CV error reduced by **61.1%**, test accuracy **94.60%** (σ = 0.0041) |
| 30 Benchmark Functions (D = 10, 100, 1000) | Outperforms GA, PSO, GWO, HHO, COA |
| Friedman Rank | **#1** (avg. rank 1.333) |

---

## 📂 Repository Structure

```
.
├── PWPA.m                  # Main algorithm implementation (MATLAB)
├── main_benchmark.m        # Benchmark evaluation script
├── main_svm_mnist.m        # SVM hyperparameter tuning case study
├── functions/              # Benchmark function definitions
│   ├── sphere.m
│   ├── rosenbrock.m
│   ├── rastrigin.m
│   ├── griewank.m
│   ├── ackley.m
│   └── schwefel.m
├── results/                # Output tables, convergence curves, boxplots
├── README.md
└── LICENSE
```

---

## ⚙️ Algorithm Overview

| Phase | Physical Analogy | Computational Role |
|---|---|---|
| **1 – Sedimentation** | Gravitational settling | Global exploration (gravity-based attraction) |
| **2 – Filtration** | Porous-media filtering | Diversity preservation (DE-style mutation/crossover) |
| **3 – Final Purification** | Chemical neutralization | Local exploitation (convergence to top-3 centroid) |

### Recommended Parameters (validated via sensitivity analysis)

| Parameter | Value | Description |
|---|---|---|
| `F` | 0.7 | Mutation factor (filtration intensity) |
| `CR` | 1.0 | Crossover rate (filter permeability) |
| `N` | 50 | Population size (benchmarks) / 15 (SVM) |
| `T` | 100 | Max iterations (benchmarks) / 50 (SVM) |
| Complexity | `O(T × N × D)` | Asymptotically equivalent to PSO/GWO |

---

## 🚀 Quick Start (MATLAB R2023a+)

### Run PWPA on a benchmark function

```matlab
addpath('functions');
[best_pos, best_val] = PWPA(@sphere, 50, 100, 1000);  % N=50, T=100, D=1000
```

### SVM hyperparameter tuning on MNIST

```matlab
main_svm_mnist;
```

---

## 📊 Benchmark Functions

| Function | Type | Separable |
|---|---|---|
| Sphere | Unimodal | Yes |
| Rosenbrock | Unimodal | No |
| Rastrigin | Multimodal | Yes |
| Griewank | Multimodal | Yes |
| Ackley | Multimodal | No |
| Schwefel | Multimodal | No |

Tested at dimensions **D = 10, 100, 1000** over **30 independent runs**.

---

## 📈 Performance Summary (D = 1000)

| Function | PWPA Best | PWPA s.d. | Best Competitor s.d. |
|---|---|---|---|
| Sphere | 1.61e-15 | 1.80e-12 | 1.45e-10 (HHO) |
| Rastrigin | 0.00e+00 | 4.84e-09 | 2.41e-09 (HHO) |
| Griewank | 0.00e+00 | 4.74e-14 | 7.35e-14 (HHO) |
| Schwefel | −6.36e+04 | **1.05e+02** | 4.43e+03 (HHO) |

---

## 📜 Citation

```bibtex
@article{safarpour2026pwpa,
  title   = {Physics-grounded optimization via interpretable process mapping},
  author  = {Safarpour, Mohammad Hossein},
  journal = {Royal Society Open Science},
  volume  = {13},
  pages   = {251929},
  year    = {2026},
  doi     = {10.1098/rsos.251929}
}
```

---

## 📜 License

This project is released under the **MIT License**.

---

## ✉️ Contact

**Mohammad Hossein Safarpour**
📧 safarpour.mh1@gmail.com
🆔 ORCID: [0009-0008-5274-8551](https://orcid.org/0009-0008-5274-8551)

---

> ⭐ *If you find PWPA useful, please consider starring this repository and citing the paper.*
