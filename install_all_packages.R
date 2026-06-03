# ============================================================
# MASTER PACKAGE INSTALLATION SCRIPT
# Nadia Tasnim Ahmed — Pharmacometrics Portfolio
# Run this ONCE in R before running any notebook
# ============================================================
# HOW TO RUN:
#   Option 1: Open in RStudio → Source
#   Option 2: In R console → source("install_all_packages.R")
#   Option 3: In terminal → Rscript install_all_packages.R
# ============================================================

cat("Starting package installation...\n")
cat("This will take 10-30 minutes on first run.\n\n")

# ── Helper: install if not already present ──────────────────
install_if_missing <- function(pkgs, repos = "https://cran.r-project.org") {
  missing <- pkgs[!pkgs %in% installed.packages()[,"Package"]]
  if (length(missing) > 0) {
    cat("Installing:", paste(missing, collapse=", "), "\n")
    install.packages(missing, repos = repos, dependencies = TRUE)
  } else {
    cat("Already installed:", paste(pkgs, collapse=", "), "\n")
  }
}

# ── 1. Core R infrastructure ────────────────────────────────
cat("\n[1/8] Core infrastructure...\n")
install_if_missing(c(
  "remotes",       # install from GitHub
  "devtools",      # developer tools
  "pak",           # fast package installer (alternative)
  "BiocManager"    # Bioconductor packages
))

# ── 2. Tidyverse + reporting ─────────────────────────────────
cat("\n[2/8] Tidyverse + reporting...\n")
install_if_missing(c(
  "tidyverse",     # dplyr, ggplot2, tidyr, purrr, readr, etc.
  "patchwork",     # combine ggplot2 panels
  "ggrepel",       # non-overlapping labels
  "scales",        # axis formatting
  "knitr",         # R Markdown
  "kableExtra",    # styled tables
  "rmarkdown",     # R Markdown rendering
  "quarto",        # Quarto documents (modern Rmd)
  "flextable",     # Word-compatible tables
  "officer",       # Word/PowerPoint from R
  "broom",         # tidy model outputs
  "MASS"           # mvrnorm + statistical methods
))

# ── 3. Pharmacometrics core ──────────────────────────────────
cat("\n[3/8] Pharmacometrics core...\n")
install_if_missing(c(
  "mrgsolve",      # C++ ODE simulation (mrgsolve.github.io)
  "rxode2",        # ODE solver for nlmixr2
  "nlmixr2",       # NLME PopPK fitting (NONMEM-compatible)
  "nlmixr2extra",  # additional nlmixr2 utilities
  "xpose",         # NONMEM/nlmixr2 diagnostic plots
  "xpose4",        # legacy NONMEM diagnostics
  "vpc",           # basic VPC
  "PKPDsim",       # PK-PD simulation
  "PKNCA"          # NCA per FDA guidance
))

# ── 4. Certara open-source packages ─────────────────────────
cat("\n[4/8] Certara open-source packages...\n")

# Step 1: Install Certara.R meta-package from CRAN
install_if_missing("Certara.R")

# Step 2: Use Certara.R to install their full suite
tryCatch({
  library(Certara.R)
  cat("Running install_certara_packages()...\n")
  install_certara_packages()
  cat("Certara suite installed.\n")
}, error = function(e) {
  cat("Certara.R auto-install failed:", conditionMessage(e), "\n")
  cat("Trying manual GitHub installs...\n")

  # Manual fallback installs from GitHub
  pkgs_github <- c(
    "certara/tidyvpc",
    "certara/ggcertara",
    "certara/vachette",
    "certara/ggquickeda",
    "certara/table1c",
    "certara/pmxpartabc",
    "certara/Certara.ModelResults"
  )
  for (pkg in pkgs_github) {
    tryCatch({
      remotes::install_github(pkg, upgrade = "never")
      cat("  Installed:", pkg, "\n")
    }, error = function(e2) {
      cat("  Failed:", pkg, "-", conditionMessage(e2), "\n")
    })
  }
})

# tidyvpc is also on CRAN — install as fallback
install_if_missing("tidyvpc")

# ── 5. Certara.RsNLME (Phoenix NLME engine) ──────────────────
cat("\n[5/8] Certara.RsNLME (Phoenix NLME)...\n")
cat("Note: RsNLME requires the NLME engine executable.\n")
cat("Download from: https://github.com/certara/R-RsNLME\n")
tryCatch({
  if (!"Certara.RsNLME" %in% installed.packages()[,"Package"]) {
    remotes::install_github("certara/R-RsNLME",
                             ref = "main", upgrade = "never")
    cat("Certara.RsNLME installed from GitHub.\n")
  } else {
    cat("Certara.RsNLME already installed.\n")
  }
}, error = function(e) {
  cat("RsNLME install note:", conditionMessage(e), "\n")
  cat("Alternative: install via Certara.R::install_certara_packages()\n")
})

# ── 6. ML / cheminformatics (Python bridge for QSPR) ─────────
cat("\n[6/8] ML / statistics...\n")
install_if_missing(c(
  "caret",         # ML framework
  "randomForest",  # Random Forest
  "xgboost",       # XGBoost
  "glmnet",        # Ridge/Lasso
  "e1071",         # SVM
  "Metrics",       # RMSE, MAE etc.
  "MLmetrics"      # additional ML metrics
))

# Note: RDKit is Python-only
# For R QSPR, use rcdk (Java-based) as alternative
tryCatch({
  install_if_missing("rcdk")    # R interface to CDK (chemistry toolkit)
  install_if_missing("rcdklibs")
  cat("rcdk installed (R alternative to RDKit for QSPR)\n")
}, error = function(e) {
  cat("rcdk note:", conditionMessage(e), "\n")
  cat("QSPR notebook uses Python/RDKit — run in Python kernel instead.\n")
})

# ── 7. Bayesian / statistical ─────────────────────────────────
cat("\n[7/8] Bayesian + statistical...\n")
install_if_missing(c(
  "brms",          # Bayesian regression via Stan
  "bayesplot",     # Bayesian diagnostics
  "posterior",     # posterior draws
  "loo",           # LOO-CV for Bayesian models
  "lme4",          # mixed effects models (TOST BE)
  "emmeans",       # estimated marginal means
  "car"            # ANOVA / regression utilities
))

# CmdStanR (for Bayesian PBPK)
cat("Installing CmdStanR...\n")
tryCatch({
  if (!"cmdstanr" %in% installed.packages()[,"Package"]) {
    install.packages("cmdstanr",
      repos = c("https://mc-stan.org/r-packages/",
                getOption("repos")))
    # Install CmdStan itself
    cmdstanr::install_cmdstan()
    cat("CmdStanR + CmdStan installed.\n")
  } else {
    cat("cmdstanr already installed.\n")
  }
}, error = function(e) {
  cat("CmdStanR note:", conditionMessage(e), "\n")
  cat("Manual install: https://mc-stan.org/cmdstanr/\n")
})

# ── 8. Reporting / NCA ───────────────────────────────────────
cat("\n[8/8] Reporting + NCA...\n")
install_if_missing(c(
  "PKNCA",         # NCA per FDA guidance
  "NonCompart",    # NCA toolkit
  "table1",        # demographics tables
  "gtsummary",     # publication-ready summary tables
  "gt"             # grammar of tables
))

# ── Jupyter R kernel (for .ipynb notebooks) ──────────────────
cat("\n[BONUS] R kernel for Jupyter notebooks...\n")
tryCatch({
  install_if_missing("IRkernel")
  IRkernel::installspec()
  cat("R kernel registered for Jupyter. Restart Jupyter to use.\n")
}, error = function(e) {
  cat("IRkernel note:", conditionMessage(e), "\n")
})

# ── Verify key packages ──────────────────────────────────────
cat("\n", strrep("=", 55), "\n")
cat("INSTALLATION COMPLETE — Verification\n")
cat(strrep("=", 55), "\n\n")

key_pkgs <- c(
  "mrgsolve", "rxode2", "nlmixr2", "tidyvpc", "ggcertara",
  "patchwork", "xpose", "PKNCA", "brms", "xgboost",
  "knitr", "kableExtra", "IRkernel"
)

for (pkg in key_pkgs) {
  status <- if (pkg %in% installed.packages()[,"Package"]) {
    ver <- as.character(packageVersion(pkg))
    paste0("✓  v", ver)
  } else {
    "✗  NOT INSTALLED"
  }
  cat(sprintf("  %-20s %s\n", pkg, status))
}

cat("\nRsNLME status:\n")
if ("Certara.RsNLME" %in% installed.packages()[,"Package"]) {
  cat("  ✓  Certara.RsNLME installed\n")
  cat("  → Still need NLME engine executable from Certara\n")
  cat("     Download: https://github.com/certara/R-RsNLME/releases\n")
} else {
  cat("  ✗  Certara.RsNLME not installed\n")
  cat("  → Run: remotes::install_github('certara/R-RsNLME')\n")
}

cat("\nPython packages (for QSPR notebook — run in terminal):\n")
cat("  pip install rdkit scikit-learn xgboost pandas numpy\n")
cat("            matplotlib scipy plotly\n")

cat("\nDone! If any packages failed, see notes above.\n")
cat("Questions? Check: https://github.com/ahmedn12\n")
