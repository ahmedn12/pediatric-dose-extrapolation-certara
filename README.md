# Pediatric Dose Extrapolation — Ontogeny + Certara Open-Source Stack
**mrgsolve · tidyvpc · ggcertara · Certara.RsNLME · SimCYP Methodology | R**

## Overview
Pediatric dose extrapolation for morphine using SimCYP-equivalent ontogeny
methodology, implemented entirely with Certara open-source R tools. Compares
simple allometric weight scaling against the full ontogeny-adjusted approach,
quantifying the dose reduction required in neonates and infants due to
immature CYP3A4 and UGT2B7 enzyme activity.

---

## Why Ontogeny Matters — The Core Problem

```
Naive weight-based dose (wrong):
  CL_child = CL_adult × (WT/70)^0.75
  → Assumes all enzymes are fully mature at birth

Ontogeny-adjusted dose (correct — SimCYP methodology):
  CL_child = CL_adult × (WT/70)^0.75 × OF(age)
  → OF(age): 0 at birth → 1.0 at enzyme maturity
  → Neonatal CYP3A4 is only ~5% of adult activity
  → UGT2B7 is ~30% at birth
  → Net CL in neonate: ~20% of allometric prediction
  → Result: naive mg/kg dosing OVERDOSES neonates
```

---

## Ontogeny Functions (Johnson 2006 / Salem 2013)

The same Hill-type sigmoid equations used internally in SimCYP:

```r
OF(age) = Fmax × age^hill / (age50^hill + age^hill)
```

| Enzyme | age50 | Hill | Significance for morphine |
|---|---|---|---|
| CYP3A4 | 0.407y (~5m) | 1.48 | ~40% of morphine metabolism |
| UGT2B7 | 0.119y (~6w) | 1.30 | ~60% of morphine metabolism |
| CYP2D6 | 0.234y (~3m) | 1.40 | Codeine conversion |
| GFR | 0.18y (~2m) | 2.00 | Renal elimination component |

---

## Key Results

| Age group | CYP3A4 (%) | UGT2B7 (%) | CL vs allometric | Dose vs naive |
|---|---|---|---|---|
| Neonate (0-1m) | ~5% | ~30% | ~20% | ↓ 80% ⚠ |
| Infant (6m) | ~55% | ~75% | ~67% | ↓ 33% |
| Toddler (1.5y) | ~75% | ~87% | ~82% | ↓ 18% |
| Child (3y) | ~87% | ~93% | ~91% | ↓ 9% |
| Child (8y) | ~96% | ~98% | ~97% | Standard ✓ |
| Adult | 100% | 100% | 100% | Reference |

**Clinical implication:** Standard 0.1 mg/kg morphine IV overdoses neonates
by ~5× when based on weight alone — the mechanistic basis of reported
neonatal morphine toxicity events.

---

## Certara Open-Source Tool Stack

| Package | Role | Free? |
|---|---|---|
| **mrgsolve** | Pediatric population simulation (C++) | ✓ |
| **tidyvpc** | VPC with binless AQR/LOESS method | ✓ (CRAN) |
| **ggcertara** | Certara-standard GOF plot theme | ✓ (GitHub) |
| **Certara.RsNLME** | Phoenix NLME engine from R | ✓ |
| **rxode2** | ODE solver for PBPK | ✓ (CRAN) |

Note: The Simcyp R package (which interfaces with Simcyp Simulator) requires
a paid Simcyp license. This project replicates the SimCYP pediatric
methodology using the free Certara ecosystem + published ontogeny parameters.

---

## Features
- Ontogeny functions: CYP3A4, UGT2B7, CYP2D6, GFR (Johnson 2006, Salem 2013)
- Maturation milestone calculator (age at 50% / 90% adult activity)
- Pediatric physiology table (ICRP 2002): 11 age groups, birth to adult
- Adult morphine PopPK baseline (Lotsch 2005)
- mrgsolve pediatric model with inline C++ ontogeny equations
- Population simulation: N=200 per age group, 7 age groups
- Allometric vs ontogeny CL comparison
- Dose adjustment factor by age
- tidyvpc VPC (binless AQR method — Certara standard)
- Dose recommendation table with safety flags
- Exports: dose_recs CSV, simulation PI data

## Files
- `pediatric_dose_extrapolation_certara.ipynb` — R implementation

## Installation
```r
# Core packages (CRAN)
install.packages(c('mrgsolve', 'rxode2', 'tidyvpc',
                   'tidyverse', 'patchwork', 'knitr', 'kableExtra'))

# Certara packages
install.packages('Certara.R')
library(Certara.R)
install_certara_packages()

# ggcertara (GitHub)
remotes::install_github('certara/ggcertara')
```

---

## Regulatory Context

**FDA Guidance: General Clinical Pharmacology — Pediatric Studies (2014)**
- PBPK-based pediatric dose selection is FDA-accepted
- Ontogeny functions must be based on published, verified data
- Model validation: predicted vs observed PK in each age group

**ICH E11(R1): Clinical Investigation in Pediatric Populations (2017)**
- Model-informed pediatric dose selection can reduce clinical studies
- Extrapolation acceptable when PK-PD relationship is similar to adults

**FDA PREA (Pediatric Research Equity Act)**
- Requires pediatric studies for most new drugs
- PBPK modeling can substitute for some age groups if validated

---

## Connection to Other Projects

| Project | Connection |
|---|---|
| `popPK-nlmixr2-theophylline` | Same allometric scaling (WT^0.75) used as covariate |
| `pkpd-mrgsolve-warfarin` | Same mrgsolve omega block IIV structure |
| `topical-be-pbpk` | Population variability approach (same MC method) |
| OSP morphine-pediatric-scaling | This project adds ontogeny to OSP allometric model |

---

## References

1. Johnson TN, Rostami-Hodjegan A, Tucker GT. Prediction of CYP3A4 metabolic
   activity: ontogeny and variability. Clin Pharmacokinet 2006;45(9):931-956
2. Salem F, Johnson TN, Hodgkinson ABJ et al. UGT2B7 ontogeny.
   AAPS J 2013;15(2):554-563
3. Holford N, Ma SC, Ploeger BA. Clinical trial simulation: a review.
   Clin Pharmacol Ther 2012;88(2):166-182
4. FDA Guidance: General Clinical Pharmacology Considerations for
   Pediatric Studies (2014)
5. ICH E11(R1): Clinical Investigation of Medicinal Products in the
   Pediatric Population (2017)
6. Fidler M, Vandemeulebroecke M et al. tidyvpc. CPT:PSP 2019

---

## Author
Nadia Tasnim Ahmed, PhD
Pharmaceutical Data Scientist | Pediatric Pharmacometrics · PBPK · Certara Tools
github.com/ahmedn12
